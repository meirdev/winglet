bring http;

bring "./winglet/api.w" as api_;

let api = new api_.Api();

api.get("/", inflight (req, res) => {
  res.getHeaders().append("X-Test", "value1");
  res.getHeaders().append("X-Test", "value2");
  res.json("ok");
});

api.listen(8080);

test "example" {
  let var response = http.get("http://localhost:8080/");

  assert(response.ok);
  assert(response.headers.get("x-test") == "value1,value2");
}
