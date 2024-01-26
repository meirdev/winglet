pub struct ColumnType {
  name: str;
  decltype: str;
}

pub struct ColumnValue {
  type: str;
  value: Json?;
}

pub interface IDatabase {
  inflight connect();
  inflight close();
  inflight execute(stmt: str, ...args: Array<Json>): Json;
}
