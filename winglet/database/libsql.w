bring http;

pub interface IDataType {
}

pub struct ColumnType {
  name: str;
  decltype: str;
}

pub struct ColumnValue {
  type: str;
  value: IDataType?;
}

pub struct Config {
  url: str;
  authToken: str?;
  tls: bool?;
}

pub interface Client {
  inflight close();
  inflight execute(stmt: str, args: Array<str>?): Json;
}

pub class LibSql_ {
  // ERROR: "cannot be used within bundled cloud functions"
  static extern "./libSql.js" inflight client(config: Config): Client;

  config: Config;

  var inflight _client: Client?;

  new(config: Config) {
    this.config = config;
  }

  inflight new() {
    this._client = nil;
  }

  pub inflight connect() {
    this._client = LibSql_.client(this.config);
  }

  pub inflight close() {
    this._client?.close();
  }

  pub inflight execute(stmt: str, args: Array<str>?): Json {
    return this._client?.execute(stmt, args);
  }
}

pub class LibSql {
  config: Config;

  var inflight _client: Client?;

  new(config: Config) {
    this.config = config;
  }

  inflight new() {
    this._client = nil;
  }

  pub inflight connect() {
  }

  pub inflight close() {
  }

  pub inflight execute(stmt: str, args: Array<str>?): MutArray<MutMap<IDataType?>> {
    let response = http.post(
      "{this.config.url}/v2/pipeline",
      headers: {
        "Authorization": "Bearer {this.config.authToken}",
        "Content-Type": "application/json",
      },
      body: Json.stringify({
        requests: [
          { type: "execute", stmt: { sql: stmt } },
          { type: "close" },
        ],
      }),
    );

    log("execute: response.body={response.body}");

    if response.ok {
      let body = Json.parse(response.body);
      let var result = body.get("results").getAt(0);

      if result.get("type") == "error" {
        throw result.get("error").asStr();
      }

      if let resultResponse = result.tryGet("response") {
        result = resultResponse.get("result");

        let cols: Array<ColumnType> = unsafeCast(result.get("cols"));
        let rows: Array<Array<ColumnValue>> = unsafeCast(result.get("rows"));

        let dataTable = MutArray<MutMap<IDataType?>>[];

        for row in 0..rows.length {
          let rowData = MutMap<IDataType?>{};
          for col in 0..cols.length {
            rowData.set(cols.at(col).name, rows.at(row).at(col).value);
          }
          dataTable.push(rowData);
        }

        return dataTable;
      }
    }
  }
}
