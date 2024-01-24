pub inflight class URLSearchParams_ {
  pub inflight get(name: str): str {
    return "";
  }

  pub inflight getAll(name: str): Array<str> {
    return [];
  }

  pub inflight keys(): Array<str> {
    return [];
  }

  pub inflight toString(): str {
    return "";
  }
}

pub inflight class URL_ {
  pub pathname: str;
  pub searchParams: URLSearchParams_;

  new() {
    this.pathname = "";
    this.searchParams = new URLSearchParams_();
  }
}

pub class Url {
  pub static extern "./url.js" inflight url(input: str): URL_;
  pub static extern "./url.js" inflight urlSearchParams(params: Json): URLSearchParams_;
}
