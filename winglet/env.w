bring cloud;
bring util;

bring "./dotenv.w" as dotenv;

pub class Env {
  pub vars: Map<str>;

  new() {
    std.Node.of(this).hidden = true;

    let result = dotenv.Dotenv.preflightConfig();

    this.vars = result.parsed;
  }

  inflight new() {
    dotenv.Dotenv.config();
  }

  pub inflight get(name: str): str {
    return util.env(name);
  }
}
