bring cloud;
bring http;
bring math;

bring "./winglet/api.w" as api_;
bring "./winglet/database/libsql.w" as libsql;
bring "./winglet/env.w" as env_;

let api = new api_.Api();

let env = new env_.Env(path: "./dev.env");

let db = new libsql.LibSql(
  url: "http://localhost:8888",
);

new cloud.Service(inflight () => {
  db.execute("{""}
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT
  );
  ");
});

api.get("/", inflight (req, res) => {
  let users: Json = unsafeCast(db.execute("SELECT * FROM users"));

  res.json(users);
});

api.get("/:userId", inflight (req, res) => {
  let userId = req.params.get("userId");

  let users: Array<Json> = unsafeCast(db.execute("SELECT * FROM users WHERE id = '{userId}'"));

  if users.length == 0 {
    res.status(404);
  } else {
    res.json(users.at(0));
  }
});

api.post("/", inflight (req, res) => {
  if let username = req.form.get("username") {
    let user: Json = unsafeCast(db.execute("INSERT INTO users (username) VALUES ('{username}')"));

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

  let users: Array<Json> = unsafeCast(Json.parse(response.body));

  let var found = false;

  for i in 0..users.length {
    let user = users.at(i);

    if user.get("username") == username {
      found = true;
      response = http.get("http://localhost:8080/{user.get("id").asStr()}");

      assert(response.body == Json.stringify(user));
    }
  }

  assert(found);
}
