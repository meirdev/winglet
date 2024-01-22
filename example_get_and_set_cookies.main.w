bring http;

bring "./winglet/api.w" as api_;

let api = new api_.Api();

api.get("/", inflight (req, res) => {
  res.cookie("username", "meir");

  res.html("<a href=\"/get\">Get cookie</a>");
});

api.get("/get", inflight (req, res) => {
  let username = req.cookies().get("username");

  res.html("cookie value: {username}");
});

api.listen(8080);

test "example" {
  let var response = http.get("http://localhost:8080/");

  assert(response.headers.get("set-cookie") == "username=meir");

  response = http.get("http://localhost:8080/get", headers: {
    "cookie": "username=meir"
  });

  assert(response.body == "cookie value: meir");
}
