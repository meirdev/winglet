# Winglet

<div align="center">
  <img src="./assets/logo.svg" height="300" />
  <br />
  <br />
  <p><i>A lightweight web framework designed for simplicity and minimal dependencies</i></p>
</div>

## Note

_All code in the repo has been tested with version 0.54.50 of Wing._

## Counter (Winglet + Turso)

```wing
bring http;

bring "./winglet/api.w" as api_;
bring "./winglet/database/libsql.w" as libsql;
bring "./winglet/env.w" as env_;

let api = new api_.Api();

let env = new env_.Env();

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
    let result: Array<Json> = unsafeCast(this.db.execute("SELECT * FROM counter"));
    return result.at(0).get("value").asStr();
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
```

## Examples

* [Return JSON](./example_return_json.main.w)
* [Read POST](./example_read_post.main.w)
* [Read path paramaters](./example_path_parameter.main.w)
* [Read query string](./example_query_string.main.w)
* [Use environment variables](./example_env.main.w)
* [CORS](./example_cors.main.w)
* [Custom middleware](./example_middleware.main.w)
* [File upload](./example_file_upload.main.w)
* [Auth with GitHub](./example_auth_github.main.w)
* [Auth with Facebook](./example_auth_meta.main.w)
* [Turso database](./example_turso.main.w)
* [Neon database](./example_neon.main.w)
* [HTTP streaming](./example_streaming.main.w)
* [SSE](./example_sse.main.w)
* [Reponse headers with multi values per key](./example_response_headers_multi_values_per_key.main.w)
* [Static files (Hosting in S3)](./example_static_files.main.w)

## Tests

To run tests, you need to add the environment variable `TESTING_MODE=y` before running them:

```bash
TESTING_MODE=y wing test example_query_string.main.w
```

## Roadmap

* Stability.
* More tests.
* Performence.
* Write documentation.
* Additional providers.
