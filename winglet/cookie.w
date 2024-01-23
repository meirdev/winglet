pub struct CookieOptions {
  domain: str?;
  expires: std.Datetime?;
  httpOnly: bool?;
  maxAge: num?;
  partitioned: bool?;
  path: str?;
  priority: str?;
  sameSite: str?;
  secure: bool?;
}

pub class Cookie {
  pub static extern "./cookie.js" inflight parse(s: str): Map<str>;
  pub static extern "./cookie.js" inflight serialize(name: str, value: str, options: CookieOptions?): str;
}
