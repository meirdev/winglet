bring "./cookie.w" as cookie;

test "parse" {
  let cookies = cookie.Cookie.parse("foo=bar; equation=E%3Dmc%5E2");

  assert(cookies.get("foo") == "bar");
  assert(cookies.get("equation") == "E=mc^2");
}

test "serialize" {
  let cookies = cookie.Cookie.serialize("foo", "bar");

  assert(cookies == "foo=bar");
}
