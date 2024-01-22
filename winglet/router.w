bring "./middleware.w" as middleware;
bring "./response.w" as response;
bring "./request.w" as request;

pub inflight class Pattern {
  path: str;
  segments: MutArray<str>;

  new(path: str) {
    this.path = path;
    this.segments = this.parsePath(path);
  }

  inflight parsePath(path: str): MutArray<str> {
    let segments = MutArray<str>[];

    for segment in path.split("/") {
      if segment != "" {
        segments.push(segment);
      }
    }

    return segments;
  }

  pub inflight match(path: str): MutMap<str>? {
    let segments = this.parsePath(path);

    let params = MutMap<str>{};

    let var i = 0;

    if this.segments.length == 1 && this.segments.at(0) == "*" {
      return params;
    }

    while i < segments.length && i < this.segments.length {
      let segment = segments.at(i);
      let patternSegment = this.segments.at(i);

      if patternSegment == "*" {
        return params;
      }
      elif patternSegment.startsWith(":") {
        let name = patternSegment.substring(1);
        params.set(name, segment);
      }
      elif patternSegment != segment {
        return nil;
      }

      i += 1;
    }

    if i < segments.length || i < this.segments.length {
      return nil;
    }

    return params;
  }
}

pub struct Route {
  method: str;
  path: str;
  handler: inflight(request.Request, response.Response): void;
}

pub struct WsRoute {
  path: str;
  handler: inflight(request.WsRequest, response.WsResponse): void;
}

pub class Router {
  pub basePath: str;
  pub routes: MutArray<Route>;
  pub wsRoutes: MutArray<WsRoute>;
  pub middlewares: MutArray<middleware.Middleware>;

  new(basePath: str?) {
    this.basePath = basePath ?? "/";
    this.routes = MutArray<Route>[];
    this.wsRoutes = MutArray<WsRoute>[];
    this.middlewares = MutArray<middleware.Middleware>[];
  }

  addMiddleware(middleware: middleware.Middleware) {
    this.middlewares.push(middleware);
  }

  pub use(path: str, handler: inflight (request.Request, response.Response, inflight (): void): void) {
    this.addMiddleware(path: path, handler: handler);
  }

  addRoute(route: Route) {
    this.routes.push(route);
  }

  addWsRoute(route: WsRoute) {
    this.wsRoutes.push(route);
  }

  pub all(path: str, handler: inflight(request.Request, response.Response): void) {
    this.addRoute(method: "*", path: path, handler: handler);
  }

  pub on(methods: Array<str>, path: str, handler: inflight(request.Request, response.Response): void) {
    for method in methods {
      this.addRoute(method: method, path: path, handler: handler);
    }
  }

  pub get(path: str, handler: inflight(request.Request, response.Response): void) {
    this.addRoute(method: "GET", path: path, handler: handler);
  }

  pub post(path: str, handler: inflight(request.Request, response.Response): void) {
    this.addRoute(method: "POST", path: path, handler: handler);
  }

  pub put(path: str, handler: inflight(request.Request, response.Response): void) {
    this.addRoute(method: "PUT", path: path, handler: handler);
  }

  pub delete(path: str, handler: inflight(request.Request, response.Response): void) {
    this.addRoute(method: "DELETE", path: path, handler: handler);
  }

  pub patch(path: str, handler: inflight(request.Request, response.Response): void) {
    this.addRoute(method: "PATCH", path: path, handler: handler);
  }

  pub head(path: str, handler: inflight(request.Request, response.Response): void) {
    this.addRoute(method: "HEAD", path: path, handler: handler);
  }

  pub ws(path: str, handler: inflight(request.WsRequest, response.WsResponse): void) {
    this.addWsRoute(path: path, handler: handler);
  }
}
