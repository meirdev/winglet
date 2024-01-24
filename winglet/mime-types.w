pub class MimeType {
  pub static extern "./mime-types.js" inflight lookup(file: str): str;
  pub static extern "./mime-types.js" preflightLookup(file: str): str;
}
