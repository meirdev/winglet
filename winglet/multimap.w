pub inflight class MultiMap {
  pub map: MutMap<MutArray<str>>;

  new() {
    this.map = {};
  }

  pub inflight get(name: str): str? {
    if let values = this.map.tryGet(name) {
      return values.at(0);
    }
  }

  pub inflight getAll(name: str): Array<str>? {
    if let values = this.map.tryGet(name) {
      return unsafeCast(values);
    }
  }

  pub inflight keys(): Array<str> {
    return this.map.keys();
  }

  pub inflight values(): Array<str> {
    let values = MutArray<str>[];
    for key in this.map.keys() {
      for value in this.map.get(key) {
        values.push(value);
      }
    }
    return unsafeCast(values);
  }

  pub inflight set(name: str, value: str) {
    this.map.set(name, MutArray<str>[value]);
  }

  pub inflight append(name: str, value: str) {
    if let values = this.map.tryGet(name) {
      if !values.contains(value) {
        values.push(value);
      }
    } else {
      this.map.set(name, MutArray<str>[value]);
    }
  }

  pub inflight delete(name: str, value: str?) {
    if let values = this.map.tryGet(name) {
      if let value = value {
        while values.contains(value) {
          values.removeFirst(value);
        }
      } else {
        this.map.delete(name);
      }
    }
  }

  pub inflight has(name: str, value: str?): bool {
    if let values = this.map.tryGet(name) {
      if let value = value {
        return values.contains(value);
      }
      return true;
    }
    return false;
  }

  pub inflight entries(): Array<Array<str>> {
    let entries = MutArray<Array<str>>[];
    for key in this.map.keys() {
      for value in this.map.get(key) {
        entries.push([key, value]);
      }
    }
    return unsafeCast(entries);
  }

  pub inflight toMap(separator: str): MutMap<str> {
    let headers: MutMap<str> = {};
    for name in this.map.keys() {
      headers.set(name, this.map.get(name).join(separator));
    }
    return headers;
  }
}
