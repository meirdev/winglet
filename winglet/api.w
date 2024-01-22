bring cloud;
bring util;

bring "cdktf" as cdktf;
bring "@cdktf/provider-aws" as tfaws;

bring "./response.w" as response;
bring "./request.w" as request;
bring "./router.w" as router;
bring "./server.w" as server;
bring "./stream-function.w" as streamFunction;

pub struct ApiOptions {
  stream: bool?;
}

pub class Api extends router.Router {
  routers: MutArray<router.Router>;
  stream: bool;

  new(options: ApiOptions?) {
    super();

    this.routers = MutArray<router.Router>[];
    this.stream = options?.stream ?? false;
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
    let getRes = inflight (event: str): response.Response => {
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

      return this.dispatch(req);
    };

    let getMetadata = inflight (res: response.Response): Json => {
      let headers = MutMap<str>{};

      for key in res.getHeaders().keys() {
        headers.set(key, res.getHeaders().get(key) ?? "");
      }

      let metadata: Json = {
        statusCode: res.getStatus(),
        headers: Json.parse(Json.stringify(headers)),
      };

      return metadata;
    };

    if this.stream {
      let cloudFunction = new streamFunction.StreamFunction(inflight (event: str, responseStream: streamFunction.IStream) => {
        let res = getRes(event);

        let fn = inflight (res: response.Response) => {
          let stream = streamFunction.HttpResponseStream.httpResponseStreamFrom(responseStream, getMetadata(res));

          if let streamFn = res.getStream() {
            streamFn(unsafeCast(stream));
          } else {
            stream.write(res.getBody());
          }

          stream.end();
        };

        return unsafeCast(fn(res));
      });

      let lambdaFunction: tfaws.lambdaFunction.LambdaFunction = unsafeCast(unsafeCast(std.Node.of(cloudFunction).children.at(0))?.function);

      let lambdaFunctionUrl = new tfaws.lambdaFunctionUrl.LambdaFunctionUrl(
        functionName: lambdaFunction.functionName,
        authorizationType: "NONE",
        invokeMode: "RESPONSE_STREAM",
      );

      new cdktf.TerraformOutput({
        value: lambdaFunctionUrl.functionUrl,
      });
    } else {
      let cloudFunction = new cloud.Function(inflight (event: str) => {
        let res = getRes(event);

          let fn = inflight (res: response.Response) => {
            let var metadata = getMetadata(res);

            return {
              "statusCode": metadata.get("statusCode"),
              "headers": metadata.get("headers"),
              "body": res.getBody(),
            };
          };

        return unsafeCast(fn(res));
      });

      let lambdaFunction: tfaws.lambdaFunction.LambdaFunction = unsafeCast(std.Node.of(cloudFunction).findChild("Default"));

      let lambdaFunctionUrl = new tfaws.lambdaFunctionUrl.LambdaFunctionUrl(
        functionName: lambdaFunction.functionName,
        authorizationType: "NONE",
      );

      new cdktf.TerraformOutput({
        value: lambdaFunctionUrl.functionUrl,
      });
    }
  }
}
