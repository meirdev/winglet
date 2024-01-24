bring http;

bring "./env.w" as env_;

let env = new env_.Env();

let envWithFile = new env_.Env(path: "./dev.env") as "env-file";

test "default" {
  assert(env.get("SECRET_KEY") == "meir123");
}

test "with file" {
  assert(envWithFile.get("SECRET_KEY") == "meir456");
}
