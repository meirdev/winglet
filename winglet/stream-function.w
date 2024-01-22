bring cloud;

pub interface IStream {
  inflight write(s: str);
  inflight end(); 
}

pub class HttpResponseStream {
  pub static extern "./stream-function.js" inflight httpResponseStreamFrom(stream: IStream, headers: Json): IStream;
}

interface IFunctionHandler {
}

// It is not possible to inherit cloud.Function so I create an interface to override the _getCodeLines method

class IFunction {
  pub var _getCodeLines: (IFunctionHandler): MutArray<str>;

  new() {
    this._getCodeLines = (handler) => {return MutArray<str>[];};
  }

  pub addEnvironment(name: str, key: str) {
  }
}

pub class StreamFunction {
  pub fn: IFunction;

  new(handler: inflight (str, IStream): str?) {
    this.fn = unsafeCast(new cloud.Function(unsafeCast(handler)));
    this.fn._getCodeLines = this._getCodeLines;
  }

  protected _getCodeLines(handler: IFunctionHandler): MutArray<str> {
    let inflightClient = unsafeCast(handler)?._toInflight();
    let lines = MutArray<str>[];

    lines.push("\"use strict\";");
    lines.push("exports.handler = awslambda.streamifyResponse(async (event, responseStream, context) => \{");
    lines.push("  return await ({inflightClient}).handle(event, responseStream);");
    lines.push("});");

    return lines;
  }
}
