pub class DotenvConfig {
  pub parsed: Map<str>;

  new() {
    this.parsed = {};
  }
}

pub struct DotenvOptions {
  path: str?;
}

pub class Dotenv {
  pub static extern "./dotenv.js" inflight config(options: DotenvOptions?): void;
  pub static extern "./dotenv.js" preflightConfig(options: DotenvOptions?): DotenvConfig;
  pub static extern "./dotenv.js" env(): Map<str>;
}
