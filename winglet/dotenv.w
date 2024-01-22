pub class DotenvConfig {
  pub parsed: Map<str>;

  new() {
    this.parsed = {};
  }
}

pub class Dotenv {
  pub static extern "./dotenv.js" inflight config(): void;
  pub static extern "./dotenv.js" preflightConfig(): DotenvConfig;
  pub static extern "./dotenv.js" env(): Map<str>;
}
