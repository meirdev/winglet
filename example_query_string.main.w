bring http;

bring "./winglet/api.w" as api_;

let api = new api_.Api();

api.get("/search", inflight (req, res) => {
  let query = req.query.getAll("q");
  let foo = req.query.get("foo");

  res.html("query = {query}\nfoo = {foo}");
});

api.listen(8080);

test "example" {
  let response = http.get("http://localhost:8080/search?q=test1&q=test2&foo=bar");

  assert(response.body == "query = test1,test2\nfoo = bar");
}
