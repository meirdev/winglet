bring http;
bring util;

bring "./winglet/api.w" as api_;

let USERNAME = "meir";
let PASSWORD = "123456";

let api = new api_.Api();

api.use("*", inflight (req, res, next) => {
  next();
  res.body(res.getBody() + " After");
});

api.use("/private/*", inflight (req, res, next) => {
  res.status(401);
  res.header("WWW-Authenticate", "Basic realm=\"Private\"");

  if let auth = req.headers().get("authorization") {
    if "Basic {util.base64Encode("{USERNAME}:{PASSWORD}")}" == auth {
      next();
    } else {
      res.html("Incorrect password or username");
    }
  }
});

api.get("/", inflight (req, res) => {
  res.html("Hello");
});

api.get("/private/page", inflight (req, res) => {
  res.html("Private Page");
});

api.listen(8080);

test "example" {
  let var response = http.get("http://localhost:8080/");

  assert(response.body == "Hello After");

  response = http.get("http://localhost:8080/private/page", headers: {
    "Authorization": "Basic bWVpcjoxMjM0NTY="
  });

  assert(response.body == "Private Page After");
}
