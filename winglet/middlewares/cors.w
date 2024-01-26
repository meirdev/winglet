bring "../middleware.w" as middleware;
bring "../request.w" as request;
bring "../response.w" as response;

pub struct CorsOptions {
  allowOrigin: str?;
  allowHeaders: Array<str>?;
  allowMethods: Array<str>?;
  exposeHeaders: Array<str>?;
  maxAge: duration?;
  allowCredentials: bool?;
}

pub class Cors impl middleware.IMiddleware {
  options: CorsOptions?;

  new(options: CorsOptions?) {
    std.Node.of(this).hidden = true;

    this.options = options;
  }

  pub inflight handler(req: request.Request, res: response.Response, next: inflight (): void) {
    let var allowOrigin = "*";

    if this.options?.allowOrigin? {
      allowOrigin = "{this.options?.allowOrigin}";
    }

    res.header("Access-Control-Allow-Origin", allowOrigin);

    let var allowMethods = ["GET", "HEAD", "PUT", "POST", "DELETE", "PATCH"].join(", ");

    if this.options?.allowMethods? {
      allowMethods = "{this.options?.allowMethods?.join(", ")}";
    }

    res.header("Access-Control-Allow-Methods", allowMethods);

    let var allowHeaders = "*";

    if this.options?.allowHeaders? {
      allowHeaders = "{this.options?.allowHeaders?.join(", ")}";
    }

    res.header("Access-Control-Allow-Headers", allowHeaders);

    let var maxAge = "86400"; // 1 day

    if this.options?.maxAge? {
      maxAge = "{this.options?.maxAge?.seconds}";
    }

    res.header("Access-Control-Max-Age", maxAge);

    if this.options?.allowCredentials? {
      res.header("Access-Control-Allow-Credentials", "true");
    }

    if req.method() == "OPTIONS" {
      res.status(204);
      return;
    }

    next();
  }
}
