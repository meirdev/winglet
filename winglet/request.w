// bring "./context.w" as context;
bring "./cookie.w" as cookie;
bring "./formdata.w" as formdata;
bring "./multimap.w" as multimap;
bring "./url.w" as url;

pub struct File extends formdata.File {
}

pub inflight class Request {
  var inflight _method: str;
  var inflight _path: str;
  var inflight _body: str;

  pub var inflight headers: multimap.MultiMap;

  pub var inflight params: MutMap<str>;
  pub var inflight context: MutMap<str>;

  pub var inflight pathname: str;
  pub var inflight query: multimap.MultiMap;
  pub var inflight cookies: multimap.MultiMap;
  pub var inflight form: multimap.MultiMap;
  pub var inflight files: multimap.MultiMap;
  pub var inflight json: Json;

  new(method: str, path: str, headers: multimap.MultiMap, body: str) {
    this._method = method;
    this._path = path;
    this._body = body;

    this.headers = headers;

    this.params = MutMap<str>{};
    this.context = MutMap<str>{};

    this.pathname = "";
    this.query = new multimap.MultiMap();
    this.cookies = new multimap.MultiMap();
    this.form = new multimap.MultiMap();
    this.files = new multimap.MultiMap();
    this.json = {};
  }

  inflight parseUrl() {
    let url_ = url.Url.url(this._path);

    this.query = new multimap.MultiMap();

    for name in url_.searchParams.keys() {
      for value in url_.searchParams.getAll(name) {
        this.query.append(name, value);
      }
    }

    this.pathname = url_.pathname;
  }

  inflight parseHeaders() {
    this.cookies = new multimap.MultiMap();

    for value in this.headers.getAll("cookie") {
      let cookies = cookie.Cookie.parse(value);
      for name in cookies.keys() {
        this.cookies.append(name, cookies.get(name));
      }
    }
  }

  inflight parseBody() {
    // Decodes the body according to the content-type
    try {
      this.json = {};
      this.form = new multimap.MultiMap();
      this.files = new multimap.MultiMap();

      if this.headers.has("content-type", "application/json") {
        this.json = Json.parse(this._body);
        return;
      }

      let formData = formdata.FormData.formdata(this.headers.toMap(","), this._body);

      if unsafeCast(formData) == nil {
        return;
      }

      for field in formData.fields.keys() {
        for value in formData.fields.get(field) {
          this.form.append(field, value);
        }
      }

      for field in formData.files.keys() {
        for value in formData.files.get(field) {
          this.files.append(field, unsafeCast(value));
        }
      }
    } catch e {
    }
  }

  pub inflight parse() {
    // each request is parsed when it arrives, if the user changes the initial request it is their responsibility to call the function again
    this.parseUrl();
    this.parseHeaders();
    this.parseBody();
  }

  pub inflight body(): str {
    return this._body;
  }

  pub inflight text(): str {
    return this._body;
  }

  pub inflight path(): str {
    return this.pathname;
  }

  pub inflight method(): str {
    return this._method;
  }
}

pub inflight class WsRequest {
  inflight var _data: str?;

  new(data: str) {
    this._data = nil;
  }

  pub inflight json(): Json {
    return Json.parse(this._data ?? "");
  }

  pub inflight text(): str {
    return this._data ?? "";
  }
}
