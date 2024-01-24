bring cloud;
bring util;

bring "./dotenv.w" as dotenv;

pub class Env {
  pub vars: Map<str>;

  options: dotenv.DotenvOptions?;

  new(options: dotenv.DotenvOptions?) {
    std.Node.of(this).hidden = true;

    let result = dotenv.Dotenv.preflightConfig(options);

    this.vars = result.parsed;

    this.options = options;
  }

  inflight new() {
    dotenv.Dotenv.config(this.options);
  }

  pub inflight get(name: str): str {
    return util.env(name);
  }
}
