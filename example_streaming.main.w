bring http;
bring util;

bring "./winglet/api.w" as api_;

let api = new api_.Api(stream: true);

api.get("/", inflight (req, res) => {
  res.html("{""}
  <html>
    <head>
      <script>
        async function getStream() \{
          const progress = document.getElementById('progress');
          const response = await fetch('/stream');
          const reader = response.body.getReader();
          reader.read().then(function pump(\{ done, value \}) \{
            if (done) \{
              return;
            \}
            const decoder = new TextDecoder();
            progress.textContent = decoder.decode(value);
            return reader.read().then(pump);
          \});
        \}
        </script>
      </head>
    <body>
    <div id='progress'></div>
    <script>
      getStream();
    </script>
    </body>
  </html>
  ");
});

api.get("/stream", inflight (req, res) => {
  res.streaming(inflight (stream) => {
    for i in 0..=5 {
      stream.write("Progress {i}/5");
      util.sleep(1s);
    }
  });
});

api.listen(8080);

test "example" {
  let response = http.get("http://localhost:8080/stream");

  for i in 0..=5 {
    let s = "Progress {i}/5";
    assert(response.body.contains(s));
  }
}
