bring http;

bring "./winglet/api.w" as api_;
bring "./winglet/middlewares/cors.w" as cors_;

let cors = new cors_.Cors();

let api = new api_.Api();

api.use("*", inflight (req, res, next) => {
  cors.handler(req, res, next);
});

// Try to send a request from another server
api.get("/", inflight (req, res) => {
  res.json("hello");
});

api.listen(8080);

test "example" {
  let response = http.get("http://localhost:8080/");

  assert(response.headers.get("access-control-allow-origin") == "*");
}
