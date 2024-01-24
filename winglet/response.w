bring fs;

bring "./cookie.w" as cookie;
bring "./multimap.w" as multimap;
bring "./stream.w" as stream;

struct JsonOptions {
  charset: str?;
}

struct HtmlOptions {
  charset: str?;
}

struct FileOptions {
  mediaType: str?;
  filename: str?;
}

struct RedirectOptions {
  status: num?;
}

struct CookieOptions extends cookie.CookieOptions {
}

pub inflight class Response {
  var inflight _status: num;
  var inflight _headers: multimap.MultiMap;
  var inflight _body: str;
  var inflight _stream: (inflight(stream.Stream): void)?;

  new(status: num?, headers: multimap.MultiMap?, body: str?) {
    this._status = status ?? 404;
    this._headers = headers ?? new multimap.MultiMap();
    this._body = body ?? "";
    this._stream = nil;
  }

  pub inflight getStatus(): num {
    return this._status;
  }

  pub inflight getHeaders(): multimap.MultiMap {
    return this._headers;
  }

  pub inflight getBody(): str {
    return this._body;
  }

  pub inflight getStream(): (inflight(stream.Stream): void)? {
    return this._stream;
  }

  pub inflight status(code: num): Response {
    this._status = code;

    return this;
  }

  pub inflight header(name: str, value: str): Response {
    this._headers.set(name, value);

    return this;
  }

  pub inflight body(payload: str): Response {
    this._body = payload;

    return this;
  }

  inflight setBodyWithContentType(payload: str, contentType: str, charset: str?) {
    let var value = "{contentType}";

    if charset? {
      value = value.concat("; charset={charset}");
    }

    this._headers.set("Content-Type", value);

    this._body = payload;
  }

  pub inflight json(body: Json, options: JsonOptions?): Response {
    this.setBodyWithContentType(Json.stringify(body), "application/json", options?.charset);

    return this;
  }

  pub inflight html(body: str, options: HtmlOptions?): Response {
    this.setBodyWithContentType(body, "text/html", options?.charset);

    return this;
  }

  pub inflight text(body: str, options: HtmlOptions?): Response {
    this.setBodyWithContentType(body, "text/plain", options?.charset);

    return this;
  }

  pub inflight file(path: str, options: FileOptions?): Response {
    let var mediaType = "application/octet-stream";

    if options?.mediaType? {
      mediaType = "{options?.mediaType}";
    }

    this._headers.set("Content-Type", "{mediaType}");

    let var filename = fs.basename(path);

    if options?.filename? {
      filename = "{options?.filename}";
    }

    this._headers.set("Content-Disposition", "attachment; filename=\"{filename}\"");

    this._body = fs.readFile(path);

    return this;
  }

  pub inflight redirect(location: str, options: RedirectOptions?): Response {
    this._status = options?.status ?? 301;

    this._headers.set("Location", location);

    return this;
  }

  pub inflight cookie(name: str, value: str?, options: CookieOptions?): Response {
    this._headers.set("Set-Cookie", cookie.Cookie.serialize(name, value ?? "", options));

    return this;
  }

  pub inflight streaming(stream: inflight (stream.Stream): void): Response {
    this._stream = stream;

    return this;
  }

  pub inflight sse(events: inflight (stream.StreamSSE): void): Response {
    this._headers.set("Content-Type", "text/event-stream");

    inflight class Wrapper {
      inflight var stream_: stream.Stream;

      inflight new(stream_: stream.Stream) {
        this.stream_ = stream_;
      }

      pub inflight write(data: stream.Event) {
        let var dataStr = "";

        if data?.id? {
          dataStr += "id: {data?.id}\n";
        }

        if data?.event? {
          dataStr += "event: {data?.event}\n";
        }

        dataStr += "data: {data?.data}\n\n";

        this.stream_.write(dataStr);
      }
    }

    this.streaming(inflight (stream) => {
      let wrap = new Wrapper(stream);
      events(unsafeCast(wrap));
    });

    return this;
  }
}

pub inflight class WsResponse {
  inflight var _data: str?;

  new(data: str) {
    this._data = nil;
  }

  pub inflight json(data: Json) {
    this._data = Json.stringify(data);
  }

  pub inflight text(data: str) {
    this._data = data;
  }
}
