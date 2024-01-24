bring http;

bring "./winglet/api.w" as api_;

let api = new api_.Api();

api.get("/", inflight (req, res) => {
  res.json({
    "hello": "world",
  });
});

api.post("/greet", inflight (req, res) => {
  let name = req.json.get("name").asStr();

  res.json("hello {name}");
});

api.listen(8080);

test "example" {
  let var response = http.get("http://localhost:8080/");

  assert(response.body == Json.stringify({"hello": "world"}));

  response = http.post(
    "http://localhost:8080/greet",
    headers: {
      "Content-Type": "application/json",
    },
    body: Json.stringify({"name": "meir"}),
  );

  assert(response.body == Json.stringify("hello meir"));
}
