pub inflight class AddressInfo {
  pub address: str;
  pub port: num;

  new() {
    this.address = "";
    this.port = 0;
  }
}

pub inflight class ClientRequest {
  pub url: str;
  pub method: str;
  pub headers: Map<Array<str>>?;
  pub headersDistinct: Map<Array<str>>?;

  new() {
    this.url = "";
    this.method = "";
    this.headers = nil;
    this.headersDistinct = nil;
  }

  pub inflight on(event: str, callback: inflight (str?): void) {
  }
}

pub inflight class ServerResponse {
  pub inflight writeHead(statusCode: num, statusMessage: str?) {
  }

  pub inflight setHeader(name: str, value: str) {
  }

  pub inflight write(chunk: str) {
  }

  pub inflight end(data: str?) {
  }
}

pub inflight class Server {
  pub inflight address(): AddressInfo {
    return new AddressInfo();
  }

  pub inflight listen(port: num) {
  }

  pub inflight close() {
  }
}
