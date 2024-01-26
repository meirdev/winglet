bring "./response.w" as response;
bring "./request.w" as request;

pub struct Middleware {
  path: str;
  handler: inflight (request.Request, response.Response, inflight (): void): void;
}

pub interface IMiddleware {
  inflight handler(req: request.Request, res: response.Response, next: inflight (): void): void;
}
