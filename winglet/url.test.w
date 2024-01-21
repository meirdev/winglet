bring "./url.w" as url111;

test "parse URL" {
  let url_ = url111.Url.url("http://127.0.0.1/hello?foo=bar&text=hello%20world&foo=123");

  assert(url_.searchParams.get("foo") == "bar");
  assert(url_.searchParams.get("text") == "hello world");

  let keys = MutArray<str>[];

  for key in url_.searchParams.keys() {
    keys.push(key);
  }

  assert(keys == ["foo", "text", "foo"]);

  let values = MutArray<str>[];

  for value in url_.searchParams.getAll("foo") {
    values.push(value);
  }

  assert(values == ["bar", "123"]);
}
