pub class Cookie {
  pub static extern "./cookie.js" inflight parse(s: str): Map<str>;
  pub static extern "./cookie.js" inflight serialize(name: str, value: str): str;
}
