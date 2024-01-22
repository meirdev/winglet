bring http;

bring "./winglet/api.w" as api_;

let api = new api_.Api();

api.get("/", inflight (req, res) => {
  res.html("{""}
  <form action='/greet' method='POST'>
    <label>Enter your name:</label>
    <input type='text' name='full_name' />
    <br />
    <input type='submit' value='Send' />
  </form>
  ");
});

api.post("/greet", inflight (req, res) => {
  let fullName = req.form().get("full_name");

  res.html("<h1>Hello {fullName}!</h1>");
});

api.listen(8080);

test "example" {
  let response = http.post(
    "http://localhost:8080/greet",
    body: "full_name=Meir",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    }
  );

  assert(response.body == "<h1>Hello Meir!</h1>");
}
