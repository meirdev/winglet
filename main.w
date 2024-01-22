bring util;

bring "./winglet/database/libsql.w" as libsql;
bring "./winglet/database/pg.w" as pg;
bring "./winglet/api.w" as wingletApi;
bring "./winglet/auth.w" as auth;
bring "./winglet/env.w" as env_;
bring "./winglet/middlewares/cors.w" as corsMiddleware;

let env = new env_.Env();

let db = new libsql.LibSql(
  url: env.vars.get("TURSO_URL"),
  authToken: env.vars.get("TURSO_TOKEN"),
);

let dbPg = new pg.PostgreSQL(
  user: env.vars.get("PG_USER"),
  password: env.vars.get("PG_PASSWORD"),
  host: env.vars.get("PG_HOST"),
  port: env.vars.get("PG_PORT"),
  database: env.vars.get("PG_DATABASE"),
  ssl: true,
);

let api = new wingletApi.Api(stream: true);

let cors = new corsMiddleware.Cors();

api.use("*", inflight (req, res, next) => {
  cors.handler(req, res, next);
});

api.get("/createtable", inflight (req, res) => {
  db.connect();
  db.execute("CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, name text);");
  // db.execute("DROP TABLE users;");
  db.close();
  res.text("dfdsfs");
});

api.get("/insert", inflight (req, res) => {
  db.connect();
  let re = db.execute("INSERT INTO users (name) VALUES ('meir');");
  log("{re}");
  db.close();
  res.text("dfdsfs");
});

api.get("/select", inflight (req, res) => {
  let re = db.execute("SELECT * FROM users");
  res.json(unsafeCast(re));
});

api.get("/test-pg", inflight (req, res) => {
  // dbPg.execute("CREATE TABLE users (id SERIAL PRIMARY KEY, name text);");
  // dbPg.execute("INSERT INTO users (name) VALUES ('meir');");
  let re = dbPg.execute("SELECT * FROM users");
  res.json(unsafeCast(re));
});

api.get("/", inflight(req, res) => {
  res.json({
    "hello": "world",
  });
});

api.get("/auth/github/callback", inflight(req, res) => {
  if let code = req.queries().get("code") {
    log("{code}");

    let options = auth.OAuth2ProviderOptions {
      clientId: env.get("OAUTH_GITHUB_CLIENT_ID"),
      clientSecret: env.get("OAUTH_GITHUB_CLIENT_SECRET"),
      redirectUri: env.get("OAUTH_GITHUB_REDIRECT_URI"),
    };

    let github = new auth.Github(options);

    let accessToken = github.getAccessToken(code);
    let user = github.getUser(accessToken);

    log("authCallbackApi: user={Json.stringify(user)}");

    res.html("OK");
  } else {
    res.html("error");
  }
});

api.get("/auth/meta/callback", inflight(req, res) => {
  if let code = req.queries().get("code") {
    log("{code}");

    let options = auth.OAuth2ProviderOptions {
      clientId: env.get("OAUTH_META_CLIENT_ID"),
      clientSecret: env.get("OAUTH_META_CLIENT_SECRET"),
      redirectUri: env.get("OAUTH_META_REDIRECT_URI"),
    };

    let meta = new auth.Meta(options);

    let accessToken = meta.getAccessToken(code);
    let user = meta.getUser(accessToken);

    log("authCallbackApi: user={Json.stringify(user)}");

    res.html("OK");
  } else {
    res.html("error");
  }
});

api.get("/login", inflight(req, res) => {
  res.html("<a href='https://github.com/login/oauth/authorize?client_id={env.get("OAUTH_GITHUB_CLIENT_ID")}&redirect_uri={env.get("OAUTH_GITHUB_REDIRECT_URI")}'>Login with GitHub</a>");
});

api.get("/login-meta", inflight(req, res) => {
  res.html("<a href='https://www.facebook.com/v18.0/dialog/oauth?client_id={env.get("OAUTH_META_CLIENT_ID")}&redirect_uri={env.get("OAUTH_META_REDIRECT_URI")}'>Login with Meta</a>");
});

api.get("/hi/:name", inflight(req, res) => {
  let name = req.params.get("name");
  res.html("<p>{name}</p>");
});

api.get("/stream", inflight(req, res) => {
  res.streaming(inflight (stream) => {
    for i in 0..=10 {
      stream.write("Progress {i}/10");
      util.sleep(1s);
    }
  });
});

api.get("/events", inflight(req, res) => {
  res.sse(inflight(stream) => {
    for i in 0..10 {
      stream.write(
        id: "{i}",
        event: "ping",
        data: "Ping #{i}",
      );
      util.sleep(1s);
    }
  });
});

api.listen(8080);
