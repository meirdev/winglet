bring cloud;
bring http;
bring util;

bring "./response.w" as response;
bring "./server.w" as server;

let httpServer = new server.HttpServer(inflight (req, res) => {
  log("{req.path()}");
  log("{Json.stringify(req.queries())}");

  let resData = new response.Response();

  resData.json({
    body: req.body(),
    headers: Json.stringify(req.headers()),
  });

  res(resData);
});

new cloud.Service(inflight () => {
  httpServer.listen(12345);

  return inflight () => { httpServer.close(); };
});

test "all tests" {
  util.sleep(1s);

  let var r = http.get("http://127.0.0.1:12345/page?a=123&b=456");

  assert(r.status == 200);

  log("{r.body}");
  // assert(r.body == "hello");

  r = http.post("http://127.0.0.1:12345/post", {
    body: "hello"
  });

  assert(r.status == 200);

  log("{r.body}");
}
