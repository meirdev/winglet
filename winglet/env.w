bring cloud;
bring util;

bring "./dotenv.w" as dotenv;

pub class Env {
  var env: Map<str>;

  new() {
    dotenv.Dotenv.preflightConfig();

    this.env = dotenv.Dotenv.env();
  }

  inflight new() {
    dotenv.Dotenv.config();
  }

  pub inflight get(name: str): str {
    return util.env(name);
  }
}
