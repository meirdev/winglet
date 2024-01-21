bring "./http.types.w" as httpTypes;

interface Any {
}

pub inflight class Message {
  pub type: str;
  pub utf8Data: str;

  new () {
    this.type = "";
    this.utf8Data = "";
  }

  pub inflight on(event: str, cb: inflight (Any): void) {
  }
}

pub inflight class Connection {
  pub inflight on(event: str, cb: inflight (Any): void) {
  }

  pub inflight sendUTF(data: str) {
  }
}

pub inflight class Request {
  pub origin: str;
  pub resourceURL: Json;

  new() {
    this.origin = "";
    this.resourceURL = {};
  }

  pub inflight accept(acceptedProtocol: str?, allowedOrigin: str?): Connection {
    return new Connection();
  }

  pub inflight reject() {
  }
}

pub inflight class Server {
  pub inflight config: Json;
  pub inflight connections: Array<Connection>;

  new () {
    this.config = {};
    this.connections = [];
  }

  pub inflight on(event: str, cb: inflight (Request): void) {
  }
}

pub class WebSocket {
  pub static extern "./websocket.js" inflight websocket(server: httpTypes.Server): Server;
}
