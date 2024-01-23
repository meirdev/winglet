bring http;

bring "./winglet/api.w" as api_;

let api = new api_.Api();

api.get("/search", inflight (req, res) => {
  if let query = req.queries().get("q") {
    res.html("query = {query}");
  } else {
    res.html("Error");
  }
});

api.listen(8080);

test "example" {
  let response = http.get("http://localhost:8080/search?q=test");

  assert(response.body == "query = test");
}
