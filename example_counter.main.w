bring http;

bring "./winglet/api.w" as api_;
bring "./winglet/database/libsql.w" as libsql;
bring "./winglet/env.w" as env_;

let api = new api_.Api();

let env = new env_.Env(path: "./dev.env");

class Counter {
  var db: libsql.LibSql;

  new() {
    this.db = new libsql.LibSql(
      url: env.vars.get("TURSO_URL"),
      authToken: env.vars.get("TURSO_TOKEN"),
    );
  }

  inflight new() {
    this.db.execute("{""}
    CREATE TABLE IF NOT EXISTS counter (
      id TEXT PRIMARY KEY,
      value INTEGER
    );
    ");

    this.db.execute("INSERT OR REPLACE INTO counter (id, value) VALUES ('{this.node.id}', 0);");
  }

  pub inflight inc() {
    this.db.execute("UPDATE counter SET value = value + 1");
  }

  pub inflight dec() {
    this.db.execute("UPDATE counter SET value = value - 1");
  }

  pub inflight set(value: num) {
    this.db.execute("UPDATE counter SET value = 0");
  }

  pub inflight peek(): str {
    let result = this.db.execute("SELECT * FROM counter");
    return result.getAt(0).get("value").asStr();
  }
}

let counter = new Counter();

api.get("/peek", inflight (req, res) => {
  res.html("{counter.peek()}");
});

api.post("/inc", inflight (req, res) => {
  counter.inc();
  res.status(200);
});

api.post("/dec", inflight (req, res) => {
  counter.dec();
  res.status(200);
});

api.post("/reset", inflight (req, res) => {
  counter.set(0);
  res.status(200);
});

api.get("/", inflight (req, res) => {
  res.html("{""}
  <html>
    <head>
      <title>Counter</title>
      <script src='https://unpkg.com/htmx.org@1.9.10' crossorigin='anonymous'></script>
    </head>
    <body>
      <div id='value' hx-get='/peek' hx-trigger='htmx:afterRequest from:#control'></div>
      <div id='control'>
        <button hx-post='/inc' hx-swap='none'>+</button>
        <button hx-post='/dec' hx-swap='none'>-</button>
      </div>
    </body>
  </html>
  ");
});

api.listen(8080);

test "counter" {
  let var response = http.get("http://localhost:8080/peek");

  assert(response.body == "0");

  response = http.post("http://localhost:8080/inc");
  response = http.get("http://localhost:8080/peek");

  assert(response.body == "1");

  response = http.post("http://localhost:8080/dec");
  response = http.get("http://localhost:8080/peek");

  assert(response.body == "0");
}
