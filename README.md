# Winglet

A web framework for Winglang.

## Examples

### Return JSON

```wing
bring "winglet" as winglet;

let api = winglet.Api();

api.get("/", inflight(req, res) => {
  res.json({
    "hello": "world",
  });
});
```

### Path parameters

```wing
bring "winglet" as winglet;

let api = winglet.Api();

api.get("/users/:userId", inflight(req, res) => {
  let userId = req.params.get("userId");

  res.text("User #{userId}");
});
```

### Read POST

```wing
bring "winglet" as winglet;

let api = winglet.Api();

api.get("/greet", inflight(req, res) => {
  let fullName = req.form().get("full_name");

  res.html("<h1>Hello {fullName}</h1>");
});

api.get("/", inflight(req, res) => {
  res.html(
    "<form action='/greet' method='POST'>" +
    "<label>Enter your name:</label>" +
    "<input type='text' name='full_name' />" +
    "<br />" +
    "<input type='submit' value='Send' />" +
    "</form>"
  );
});
```

### File Upload

```wing
bring "winglet" as winglet;

let api = new wingletApi.Api();

api.get("/upload", inflight(req, res) => {
  let file: wingletBusboy.File = unsafeCast(req.form().get("upload"));

  res.html("File name: {file.name}, size: {file.size}, mimetype: {file.mimetype}, tmp path: {file.path}");
});

api.get("/", inflight(req, res) => {
  res.html(
    "<form action='/upload' method='POST' enctype='multipart/form-data'>" +
    "<label>Select file:</label>" +
    "<input type='file' name='upload' />" +
    "<br />" +
    "<input type='submit' value='Send' />" +
    "</form>"
  );
});
```

### Middleware

```wing

```

### Streaming

```wing
bring util;

bring "./winglet/api.w" as wingletApi;

let api = new wingletApi.Api();

api.get("/stream", inflight(req, res) => {
  res.streaming(inflight(stream) => {
    for i in 0..=10 {
      stream.write("Progress {i}/10");
      util.sleep(1s);
    }
  });
});

api.get("/", inflight(req, res) => {
  res.html(
    "<html>" +
    "<head>" +
    "<script>" +
    "async function getStream() \{" +
    "const progress = document.getElementById('progress');" +
    "const response = await fetch('/stream');" +
    "const reader = response.body.getReader();" +
    "reader.read().then(function pump(\{ done, value \}) \{" +
    "if (done) \{return;\}" +
    "const decoder = new TextDecoder();" + 
    "progress.textContent = decoder.decode(value);" + 
    "return reader.read().then(pump);" +
    "\}" +
    ");" +
    "\}" +
    "</script>" +
    "</head>" +
    "<body>" +
    "<div id='progress'></div>" +
    "<script>" +
    "getStream();" +
    "</script>" +
    "</body>" +
    "</html>"
  );
});
```

### SSE

```wing
bring "winglet" as winglet;

api = winglet.Api();

api.get("/events", inflight(req, res) => {
  req.sse(inflight(stream) => {
    for i in 0..10 {
      stream.write(
        id: "{i}",
        event: "ping",
        data: "Ping #{i}",
      );
    }
  });
});

api.get("/", inflight(req, res) => {
  res.html("
  <html>
    <head>
    <script>
    const eventSource = new EventSource('/events');

    eventSource.addEventListener('ping', (event) => \{
      const newElement = document.createElement('li');
      const eventList = document.getElementById('list');
      newElement.textContent = event.data;
      eventList.appendChild(newElement);
    \});
    </script>
    </head>
    <body>
      <ul id='list'></ul>
    </body>
  </html>
  ");
});
```

## Roadmap

* Stability.
* More tests.
* Performence.
* Write documentation.
* Additional providers.
