bring cloud;
bring util;

bring "cdktf" as cdktf;
bring "@cdktf/provider-aws" as tfaws;

bring "./response.w" as response;
bring "./request.w" as request;
bring "./router.w" as router;
bring "./server.w" as server;

class I {
  pub static extern "./aaa.js" simpleStringify(s: Json): str;
}

pub class Api extends router.Router {
  routers: MutArray<router.Router>;

  new() {
    super();

    this.routers = MutArray<router.Router>[];
  }

  pub inflight dispatch(req: request.Request): response.Response {
    let middlewares = MutArray<router.Middleware>[];
    let middlewaresParams = MutArray<MutMap<str>>[];

    for middleware in this.middlewares {
      let pattern = new router.Pattern(this.basePath + middleware.path);

      if let params = pattern.match(req.path()) {
        middlewares.push(middleware);
        middlewaresParams.push(params);
      }
    }

    let var theRoute: router.Route? = nil;
    let var theRouteParams: MutMap<str>? = nil;

    for route in this.routes {
      let pattern = new router.Pattern(this.basePath + route.path);

      if let params = pattern.match(req.path()) {
        theRoute = route;
        theRouteParams = params;
        break;
      }
    }

    let res = new response.Response();

    let var prevIndex = -1;

    let runner = inflight (index) => {
      prevIndex = index;

      if index < middlewares.length {
        let middleware = middlewares.at(index);
        req.params = middlewaresParams.at(index);
        middleware.handler(req, res, inflight () => { runner(index + 1); });
      }
      else {
        if theRoute? {
          if let params = theRouteParams {
            req.params = params;
            res.status(200);
            theRoute?.handler(req, res);
          }
        }
      }
    };

    runner(0);

    return res;
  }

  pub router(router: router.Router) {
    this.routers.push(router);
  }

  pub listen(port: num) {
    let target = util.env("WING_TARGET");

    if target == "sim" {
      this.simListen(port);
    }
    elif target == "tf-aws" {
      this.tfAwsListen(port);
    }
  }

  simListen(port: num) {
    if !std.Node.of(this).app.isTestEnvironment {
      let httpServer = new server.HttpServer(inflight (req, fn) => {
        let res = this.dispatch(req);

        fn(res);
      });

      new cloud.Service(inflight () => {
        httpServer.listen(port);

        return inflight () => { httpServer.close(); };
      });
    }
  }

  pub tfAwsListen(port: num) {
    let cloudFunction = new cloud.Function(inflight (event: str) => {
      let eventJson: Json = unsafeCast(event);

      let http = eventJson.get("requestContext").get("http");
      let var body = "{eventJson.tryGet("body") ?? ""}";

      if eventJson.get("isBase64Encoded").asBool() {
        body = util.base64Decode(body);
      }

      let req = new request.Request(
        http.get("method").asStr(),
        http.get("path").asStr(),
        body,
      );

      let res = this.dispatch(req);

      let fn = inflight (res: response.Response) => {
        let headers = MutMap<str>{};

        for key in res.getHeaders().keys() {
          headers.set(key, res.getHeaders().get(key) ?? "");
        }

        return {
          "statusCode": res.getStatus(),
          "body": res.getBody(),
          "headers": Json.parse(Json.stringify(headers)),
        };
      };

      return unsafeCast(fn(res));
    });

    let functionName = unsafeCast(std.Node.of(cloudFunction).findChild("Default"))?._functionName;

    // log("{Json.stringify(unsafeCast(std.Node.of(cloudFunction).findChild("Default"))?.tryGetContext("memory_size"))}");
    // log("{unsafeCast(std.Node.of(cloudFunction).findChild("Default"))?._functionName}");

    new tfaws.lambdaFunctionUrl.LambdaFunctionUrl(
      functionName: functionName,
      authorizationType: "NONE",
    );
  }
}
