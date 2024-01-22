pub interface T {
}

pub struct ColumnType {
  name: str;
  decltype: str;
}

pub struct ColumnValue {
  type: str;
  value: T?;
}

pub interface IDatabase {
  inflight connect();
  inflight close();
  inflight execute(stmt: str, args: Array<str>?): MutArray<MutMap<T?>>;
}
