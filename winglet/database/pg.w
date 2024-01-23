bring "../database.w" as database;

pub struct Config {
  user: str?;
  password: str?;
  host: str?;
  database: str?;
  port: str?;
  ssl: bool?;
}

struct FieldInfo {
  name: str;
  dataTypeID: num;
} 

pub inflight class QueryResult {
  pub command: str;
  pub rows: Array<Json>;
  pub fields: Array<FieldInfo>;
  pub rowCount: num?;

  new() {
    this.command = "";
    this.rows = [];
    this.fields = [];
    this.rowCount = nil;
  }
}

pub interface Client {
  inflight connect();
  inflight end();
  inflight query(stmt: str, args: Array<database.T>?): QueryResult;
}

pub class Pg {
  pub static extern "./pg.js" inflight client(config: Config): Client;
}

pub class PostgreSQL impl database.IDatabase {
  config: Config;

  var inflight _client: Client?;

  new(config: Config) {
    this.config = config;
  }

  inflight new() {
    this._client = Pg.client(this.config);
    this.connect();
  }

  pub inflight connect() {
    this._client?.connect();
  }

  pub inflight close() {
    this._client?.end();
  }

  pub inflight execute(stmt: str, args: Array<database.T>?): MutArray<MutMap<database.T?>> {
    let result = this._client?.query(stmt, args);

    log("execute: result={Json.stringify(result)}");

    return unsafeCast(result?.rows);
  }
}
