bring "./url.w" as url_;

test "parse URL" {
  let url = url_.Url.url("http://127.0.0.1/hello?foo=bar&text=hello%20world&foo=123");

  assert(url.searchParams.get("foo") == "bar");
  assert(url.searchParams.get("text") == "hello world");

  let keys = MutArray<str>[];

  for key in url.searchParams.keys() {
    keys.push(key);
  }

  assert(keys == ["foo", "text", "foo"]);

  let values = MutArray<str>[];

  for value in url.searchParams.getAll("foo") {
    values.push(value);
  }

  assert(values == ["bar", "123"]);

  assert(url.pathname == "/hello");
}
