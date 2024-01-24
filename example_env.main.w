bring http;

bring "./winglet/api.w" as api_;
bring "./winglet/env.w" as env_;

let api = new api_.Api();

// the default path is ./.env
let env = new env_.Env(path: "./dev.env");

// in preflight use `env.vars.get(KEY_NAME)`
log(env.vars.get("SECRET_KEY"));

api.get("/", inflight (req, res) => {
  // in inflight use `env.get(KEY_NAME)`
  res.text("{env.get("SECRET_KEY")}");
});

api.listen(8080);

test "example" {
  let response = http.get("http://localhost:8080/");

  assert(response.body == "meir456");
}
