// Env var:
// OAUTH_GITHUB_CLIENT_ID
// OAUTH_GITHUB_CLIENT_SECRET
// OAUTH_GITHUB_REDIRECT_URI

bring "./winglet/api.w" as api_;
bring "./winglet/auth.w" as auth;
bring "./winglet/env.w" as env_;
bring "./winglet/request.w" as request;

let env = new env_.Env();

let api = new api_.Api();

api.get("/", inflight(req, res) => {
  res.html("<a href='https://github.com/login/oauth/authorize?client_id={env.get("OAUTH_GITHUB_CLIENT_ID")}&redirect_uri={env.get("OAUTH_GITHUB_REDIRECT_URI")}'>Login with GitHub</a>");
});

api.get("/auth/github/callback", inflight(req, res) => {
  if let code = req.queries().get("code") {
    let options = auth.OAuth2ProviderOptions {
      clientId: env.get("OAUTH_GITHUB_CLIENT_ID"),
      clientSecret: env.get("OAUTH_GITHUB_CLIENT_SECRET"),
      redirectUri: env.get("OAUTH_GITHUB_REDIRECT_URI"),
    };

    let github = new auth.Github(options);

    let accessToken = github.getAccessToken(code);
    let user = github.getUser(accessToken);

    log("authCallbackApi: user={Json.stringify(user)}");

    res.html("Hello {user.get("login").asStr()}!");
  } else {
    res.html("Error");
  }
});

api.listen(8080);

test "example" {
}
