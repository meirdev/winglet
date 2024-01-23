bring http;
bring util;

bring "./winglet/api.w" as api_;
bring "./winglet/stream.w" as stream_;

let api = new api_.Api(stream: true);

api.get("/", inflight (req, res) => {
  res.html("{""}
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
    setTimeout(() => eventSource.close(), 5000);
    </script>
    </head>
    <body>
      <ul id='list'></ul>
    </body>
  </html>
  ");
});

api.get("/events", inflight (req, res) => {
  res.sse(inflight (stream) => {
    for i in 1..=5 {
      stream.write(
        id: "{i}",
        event: "ping",
        data: "Ping #{i}",
      );
      util.sleep(1s);
    }
  });
});

api.listen(8080);

test "example" {
  let response = http.get("http://localhost:8080/events");

  for i in 1..=5 {
    let s = "Ping #{i}";
    assert(response.body.contains(s));
  }
}
