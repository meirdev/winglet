bring "./http.w" as http;
bring "./http.types.w" as httpTypes;
bring "./multimap.w" as multimap;
bring "./response.w" as response;
bring "./request.w" as request;
bring "./url.w" as url;
bring "./websocket.w" as ws;

pub class HttpServer {
  onRequest: inflight (request.Request, inflight (response.Response): void): void;

  inflight pub server: httpTypes.Server;

  new(onRequest: inflight (request.Request, inflight (response.Response): void): void) {
    std.Node.of(this).hidden = true;

    this.onRequest = onRequest;
  }

  inflight new() {
    this.server = http.Http.createServer(inflight (serverRequest, serverResponse) => {
      let var body = "";

      serverRequest.on("error", inflight (chunk) => {
        log("error: {chunk}");
      });

      serverRequest.on("data", inflight (chunk) => {
        if let chunk_ = chunk {
          body = body.concat(chunk_);
        }
      });

      serverRequest.on("end", () => {
        let headers = new multimap.MultiMap();

        if let headers_ = serverRequest.headersDistinct {
          for name in headers_.keys() {
            for value in headers_.get(name) {
              headers.append(name, value);
            }
          }
        }

        let req = new request.Request(serverRequest.method, serverRequest.url, headers, body);
        req.parse();

        this.onRequest(
          req,
          inflight (res: response.Response) => {
            let headers = res.getHeaders().toMap(",");

            for key in headers.keys() {
              serverResponse.setHeader(key, headers.get(key));
            }

            try {
              serverResponse.writeHead(res.getStatus());

              if let streamFn = res.getStream() {
                streamFn(unsafeCast(serverResponse));
              } else {
                serverResponse.write(res.getBody());
              }

              serverResponse.end();
            } catch {
              serverResponse.end();
            }

            // serverResponse.writeHead(res.getStatus());
            // serverResponse.write(res.getBody());
            // serverResponse.end();
          }
        );
      });
    });

    let wsServer = ws.WebSocket.websocket(this.server);

    wsServer.on("request", inflight (request) => {
      let connection = request.accept();

      connection.on("message", inflight (message) => {
        let message_: ws.Message = unsafeCast(message);

        if message_.type == "utf8" {
          log("{message_.utf8Data}");
          connection.sendUTF("hello to you {request.resourceURL}");
        }
      });
    });

    wsServer.on("connect", inflight (request) => {
      log("connect event");
    });
  }

  pub inflight address(): str {
    let address = this.server.address();

    return "http://localhost:{address.port}";
  }

  pub inflight listen(port: num?) {
    this.server.listen(port ?? 0);
  }

  pub inflight close() {
    this.server.close();
  }
}
