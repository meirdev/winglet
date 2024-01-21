bring fs;

bring "./response.w" as response;

test "set status" {
  let res = new response.Response();

  res.status(200);

  assert(res.getStatus() == 200);
}

test "set headers" {
  let res = new response.Response();

  res.header("Content-Language", "en-US");

  assert(res.getHeaders().get("Content-Language") == "en-US");
}

test "set body" {
  let res = new response.Response();

  res.body("hello world");

  assert(res.getBody() == "hello world");
}

test "set json" {
  let res = new response.Response();

  res.json({
    "hello": "world"
  });

  assert(res.getHeaders().get("Content-Type") == "application/json");
  assert(res.getBody() == "\{\"hello\":\"world\"}");
}

test "set html" {
  let res = new response.Response();

  let html = "<html><body><h1>Hello World</h1></body></html>";

  res.html(html, charset: "utf-8");

  assert(res.getHeaders().get("Content-Type") == "text/html; charset=utf-8");
  assert(res.getBody() == html);
}

test "set file" {
  let res = new response.Response();

  let data = "hello world";
  let path = "./test.txt";

  fs.writeFile("test.txt", data);

  res.file(path, mediaType: "text/plain", filename: "hello.txt");

  let headers = res.getHeaders();

  assert(headers.get("Content-Type") == "text/plain");
  assert(headers.get("Content-Disposition") == "attachment; filename=\"hello.txt\"");

  assert(res.getBody() == data);

  fs.remove(path);
}

test "set redirect" {
  let res = new response.Response();

  res.redirect("https://google.com");

  assert(res.getStatus() == 301);
  assert(res.getHeaders().get("Location") == "https://google.com");
}

test "set cookie" {
  let res = new response.Response();

  res.cookie("userId", "123");

  assert(res.getHeaders().get("Set-Cookie") == "userId=123");
}

test "set many 1" {
  let res = new response.Response();

  res.status(404);
  res.json({"message": "not found"});

  assert(res.getStatus() == 404);
  assert(res.getBody() == "\{\"message\":\"not found\"\}");
}
