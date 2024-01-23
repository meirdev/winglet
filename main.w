bring cloud;
bring http;
bring math;

bring "./winglet/api.w" as api_;
bring "./winglet/auth.w" as auth;
bring "./winglet/jwt.w" as jwt;
bring "./winglet/database/pg.w" as pg;
bring "./winglet/env.w" as env_;

let env = new env_.Env();

let api = new api_.Api();

let db = new pg.PostgreSQL(
  user: env.vars.get("PG_USER"),
  password: env.vars.get("PG_PASSWORD"),
  host: env.vars.get("PG_HOST"),
  port: env.vars.get("PG_PORT"),
  database: env.vars.get("PG_DATABASE"),
  ssl: true,
);

api.use("/p/*", inflight (req, res, next) => {
  try {
    let token = req.cookies().get("token");
    let value = jwt.jwt.verify(token ?? "", env.get("JWT_SECRET"));

    req.context.set("user", unsafeCast(value));

    next();
  } catch e {
    res.status(403);
    res.text(e);
  }
});

api.get("/", inflight (req, res) => {
  res.html("Hello");
});

api.get("/login", inflight (req, res) => {
  res.html("<a href='https://github.com/login/oauth/authorize?client_id={env.get("OAUTH_GITHUB_CLIENT_ID")}&redirect_uri={env.get("OAUTH_GITHUB_REDIRECT_URI")}'>Login with GitHub</a>");
});

api.get("/auth/github/callback", inflight (req, res) => {
  if let code = req.queries().get("code") {
    let options = auth.OAuth2ProviderOptions {
      clientId: env.get("OAUTH_GITHUB_CLIENT_ID"),
      clientSecret: env.get("OAUTH_GITHUB_CLIENT_SECRET"),
      redirectUri: env.get("OAUTH_GITHUB_REDIRECT_URI"),
    };

    let github = new auth.Github(options);

    let accessToken = github.getAccessToken(code);
    let user = github.getUser(accessToken);

    let var result = db.execute("SELECT id FROM users WHERE username = $1", [
      unsafeCast(user.get("login").asStr()),
    ]);

    if result.length == 0 {
      result = db.execute("INSERT INTO users (username, name) VALUES ($1, $2) RETURNING *", [
        unsafeCast(user.get("login").asStr()),
        unsafeCast(user.get("name").asStr()),
      ]);
    }

    let userWithId: MutMap<str> = unsafeCast(user);

    userWithId.set("_userId", unsafeCast(result.at(0).get("id")));

    let jwtToken = jwt.jwt.sign(user, env.get("JWT_SECRET"));

    res.cookie("token", jwtToken, maxAge: 8600, path: "/");
    res.redirect("http://localhost:8080/");
  } else {
    res.html("Error");
  }
});

api.get("/p/me", inflight (req, res) => {
  let user_: Json = req.context.get("user");

  let user = db.execute("SELECT * FROM users WHERE id = $1", [
    unsafeCast(user_.get("_userId")),
  ]);

  res.json(unsafeCast(user.at(0)));
});

api.listen(8080);
