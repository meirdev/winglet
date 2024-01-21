bring util;

bring "./winglet/api.w" as wingletApi;
bring "./winglet/middlewares/cors.w" as corsMiddleware;

let api = new wingletApi.Api();

let cors = new corsMiddleware.Cors({});

api.use("*", inflight (req, res, next) => {
  cors.handler(req, res, next);
});

api.get("/", inflight(req, res) => {
  res.json({
    "hello": "world",
  });
});

api.get("/hi/:name", inflight(req, res) => {
  let name = req.params.get("name");
  res.html("<p>{name}</p>");
});

api.listen(8080);
