interface IAny {
}

pub inflight class Context {
  userData: MutMap<IAny>;

  new() {
    this.userData = {};
  }

  pub inflight get(name: str): IAny {
    return this.userData.get(name);
  }

  pub inflight set(name: str, value: IAny) {
    this.userData.set(name, value);
  }
}
