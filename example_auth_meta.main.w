// Env var:
// OAUTH_META_CLIENT_ID
// OAUTH_META_CLIENT_SECRET
// OAUTH_META_REDIRECT_URI

bring "./winglet/api.w" as api_;
bring "./winglet/auth.w" as auth;
bring "./winglet/env.w" as env_;
bring "./winglet/request.w" as request;

let env = new env_.Env();

let api = new api_.Api();

api.get("/", inflight(req, res) => {
  res.html("<a href='https://www.facebook.com/v18.0/dialog/oauth?client_id={env.get("OAUTH_META_CLIENT_ID")}&redirect_uri={env.get("OAUTH_META_REDIRECT_URI")}'>Login with Meta</a>");
});

api.get("/auth/meta/callback", inflight(req, res) => {
  if let code = req.query.get("code") {
    let options = auth.OAuth2ProviderOptions {
      clientId: env.get("OAUTH_META_CLIENT_ID"),
      clientSecret: env.get("OAUTH_META_CLIENT_SECRET"),
      redirectUri: env.get("OAUTH_META_REDIRECT_URI"),
    };

    let meta = new auth.Meta(options);

    let accessToken = meta.getAccessToken(code);
    let user = meta.getUser(accessToken);

    log("authCallbackApi: user={Json.stringify(user)}");

    res.html("Hello, {user.get("name").asStr()}", charset: "utf-8");
  } else {
    res.html("Error");
  }
});

api.listen(8080);

test "example" {
}
