// You need to install the `pg` library before using: `npm i pg`

bring cloud;
bring http;
bring math;
bring util;

bring "./winglet/api.w" as api_;
bring "./winglet/database/pg.w" as pg;
bring "./winglet/env.w" as env_;

let api = new api_.Api();

let env = new env_.Env(path: "./dev.env");

let db = new pg.PostgreSQL(
  user: env.vars.get("PG_USER"),
  password: env.vars.get("PG_PASSWORD"),
  host: env.vars.get("PG_HOST"),
  port: env.vars.get("PG_PORT"),
  database: env.vars.get("PG_DATABASE"),
  ssl: env.vars.get("SSL") == "true",
);

new cloud.Service(inflight () => {
  db.execute("{""}
  CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
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

  let users: Array<Json> = unsafeCast(db.execute("SELECT * FROM users WHERE id = $1", [unsafeCast(userId)]));

  if users.length == 0 {
    res.status(404);
  } else {
    res.json(users.at(0));
  }
});

api.post("/", inflight (req, res) => {
  if let username = req.form.get("username") {
    let user: Json = unsafeCast(db.execute("INSERT INTO users (username) VALUES ($1)", [unsafeCast(username)]));

    res.status(200);
  } else {
    res.status(500);
  }
});

api.listen(8080);

test "example" {
  util.sleep(3s);

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
      response = http.get("http://localhost:8080/{user.get("id").asNum()}");

      assert(response.body == Json.stringify(user));
    }
  }

  assert(found);

  assert(false); // pg stuck if not
}
