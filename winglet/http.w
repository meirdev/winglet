bring "./http.types.w" as types;

pub class Http {
  pub static extern "./http.js" inflight createServer(requestListener: inflight (types.ClientRequest, types.ServerResponse): void): types.Server;
}
