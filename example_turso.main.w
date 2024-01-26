bring cloud;
bring http;
bring math;

bring "./winglet/api.w" as api_;
bring "./winglet/database/libsql.w" as libsql;
bring "./winglet/env.w" as env_;

let api = new api_.Api();

let env = new env_.Env(path: "./dev.env");

let db = new libsql.LibSql(
  url: env.vars.get("TURSO_URL"),
  authToken: env.vars.get("TURSO_TOKEN"),
);

new cloud.Service(inflight () => {
  db.execute("{""}
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT
  );
  ");

  db.execute("{""}
  DELETE FROM users
  ");
});

api.get("/", inflight (req, res) => {
  let users = db.execute("SELECT * FROM users");

  res.json(users);
});

api.get("/:userId", inflight (req, res) => {
  let userId = req.params.get("userId");

  let users = db.execute("SELECT * FROM users WHERE id = '{userId}'");

  if let user = users.tryGetAt(0) {
    res.json(user);
  } else {
    res.status(404);
  }
});

api.post("/", inflight (req, res) => {
  if let username = req.form.get("username") {
    let user = db.execute("INSERT INTO users (username) VALUES ('{username}')");

    res.status(200);
  } else {
    res.status(500);
  }
});

api.listen(8080);

test "example" {
  let username = "testing{math.round(math.random(1000000))}";

  let var response = http.post(
    "http://localhost:8080/",
    body: "username={username}",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    }
  );

  assert(response.ok);

  response = http.get("http://localhost:8080/");

  let users = Json.parse(response.body);

  let user = users.tryGetAt(0);

  assert(user != nil);

  if let user = user {
    response = http.get("http://localhost:8080/{user.get("id").asStr()}");
    assert(response.body == Json.stringify(user));
  }
}
