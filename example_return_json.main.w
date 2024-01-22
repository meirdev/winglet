bring http;

bring "./winglet/api.w" as api_;

let api = new api_.Api();

api.get("/", inflight (req, res) => {
  res.json({
    "hello": "world",
  });
});

api.listen(8080);

test "example" {
  let response = http.get("http://localhost:8080/");

  assert(response.body == Json.stringify({"hello": "world"}));
}
