pub struct Config {
  user: str?;
  password: str?;
  host: str?;
  database: str?;
  port: str?;
  ssl: bool?;
}

pub inflight class QueryResult {
  pub command: str;
  pub rows: Array<Json>;
  pub rowCount: num?;

  new() {
    this.command = "";
    this.rows = [];
    this.rowCount = nil;
  }
}

pub interface Client {
  inflight connect();
  inflight end();
  inflight query(stmt: str, args: Array<str>?): QueryResult;
}

pub class Pg {
  pub static extern "./pg.js" inflight client(config: Config): Client;
}
