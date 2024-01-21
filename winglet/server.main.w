bring cloud;
bring http;
bring util;

bring "./response.w" as response;
bring "./server.w" as server;

let httpServer = new server.HttpServer(inflight (req, res) => {
  log("{req.path()}");
  log("{Json.stringify(req.queries())}");

  let resData = new response.Response();

  if req.method() == "POST" {
    log("form: {Json.stringify(req.form())}");
  }

  resData.json({
    body: req.body(),
    headers: Json.stringify(req.headers()),
  });

  res(resData);
});

class App {
  new() {
    new cloud.Service(inflight () => {
      if !std.Node.of(this).app.isTestEnvironment {
        httpServer.listen(12345);

        return inflight () => { httpServer.close(); };
      }
    });
  }
}

new App();
