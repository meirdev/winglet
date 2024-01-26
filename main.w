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
    let token = req.cookies.get("token");
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
  if let code = req.query.get("code") {
    let options = auth.OAuth2ProviderOptions {
      clientId: env.get("OAUTH_GITHUB_CLIENT_ID"),
      clientSecret: env.get("OAUTH_GITHUB_CLIENT_SECRET"),
      redirectUri: env.get("OAUTH_GITHUB_REDIRECT_URI"),
    };

    let github = new auth.Github(options);

    let accessToken = github.getAccessToken(code);
    let user = github.getUser(accessToken);

    let var result = db.execute("SELECT id FROM users WHERE username = $1", user.get("login").asStr());

    if result.tryGetAt(0)? {
      result = db.execute("INSERT INTO users (username, name) VALUES ($1, $2) RETURNING *", user.get("login").asStr(), user.get("name").asStr());
    }

    let userWithId: MutMap<str> = unsafeCast(user);

    userWithId.set("_userId", result.getAt(0).get("id").asStr());

    let jwtToken = jwt.jwt.sign(user, env.get("JWT_SECRET"));

    res.cookie("token", jwtToken, maxAge: 8600, path: "/").redirect("http://localhost:8080/");
  } else {
    res.html("Error");
  }
});

api.get("/p/me", inflight (req, res) => {
  let user_: Json = req.context.get("user");

  let user = db.execute("SELECT * FROM users WHERE id = $1", user_.get("_userId"));

  res.json(user.getAt(0));
});

api.put("/p/me", inflight (req, res) => {
  let user_: Json = req.context.get("user");

  let user = db.execute("UPDATE users SET name = $1, bio = $2, link = $3 WHERE id = $4 RETURNING *",
    req.json.get("name").asStr(),
    req.json.get("bio").asStr(),
    req.json.get("link").asStr(),
    user_.get("_userId"),
  );

  res.json(user.getAt(0));
});

api.get("/p/users/:username/threads", inflight (req, res) => {
  let user_: Json = req.context.get("user");

  let threads = db.execute("SELECT posts.* FROM posts LEFT JOIN users ON posts.user = users.id WHERE posts.type = $1 AND users.username = $2",
    "thread",
    req.params.get("username"),
  );

  res.json(threads);
});

api.post("/p/posts", inflight (req, res) => {
  let user_: Json = req.context.get("user");

  let post = db.execute("INSERT INTO posts (\"user\", content, type) VALUES ($1, $2, $3)",
    user_.get("_userId"),
    req.json.get("content").asStr(),
    req.json.get("type").asStr(),
  );

  res.json(post);
});

api.listen(8080);
