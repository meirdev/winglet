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
  var inflight _headers: multimap.MultiMap;

  pub var inflight params: MutMap<str>;
  pub var inflight context: MutMap<str>;

  new(method: str, path: str, body: str) {
    this._method = method;
    this._path = path;
    this._body = body;
    this._headers = new multimap.MultiMap();

    this.params = MutMap<str>{};
    this.context = MutMap<str>{};
  }

  pub inflight queries(): multimap.MultiMap {
    let ret = new multimap.MultiMap();

    let url_ = url.Url.url("http://0.0.0.0{this._path}");

    for name in url_.searchParams.keys() {
      for value in url_.searchParams.getAll(name) {
        ret.append(name, value);
      }
    }

    return ret;
  }

  pub inflight headers(): multimap.MultiMap {
    return this._headers;
  }

  pub inflight form(): multimap.MultiMap {
    // returns multimap.MultiMap<ValueOrFile>
    let ret = new multimap.MultiMap();

    let formData = formdata.FormData.formdata(this._headers.toMap(","), this._body);

    for field in formData.fields.keys() {
      for value in formData.fields.get(field) {
        ret.append(field, unsafeCast(value));
      }
    }

    return ret;
  }

  pub inflight files(): multimap.MultiMap {
    // returns multimap.MultiMap<ValueOrFile>
    let ret = new multimap.MultiMap();

    let formData = formdata.FormData.formdata(this._headers.toMap(","), this._body);

    for field in formData.files.keys() {
      for value in formData.files.get(field) {
        ret.append(field, unsafeCast(value));
      }
    }

    return ret;
  }

  pub inflight json(): Json {
    return Json.parse(this._body);
  }

  pub inflight body(): str {
    return this._body;
  }

  pub inflight text(): str {
    return this._body;
  }

  pub inflight path(): str {
    let url_ = url.Url.url("http://0.0.0.0{this._path}");

    return url_.pathname;
  }

  pub inflight method(): str {
    return this._method;
  }

  pub inflight cookies(): multimap.MultiMap {
    let ret = new multimap.MultiMap();

    for value in this._headers.getAll("cookie") {
      let cookies = cookie.Cookie.parse(value);
      for name in cookies.keys() {
        ret.append(name, cookies.get(name));
      }
    }

    return ret;
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
