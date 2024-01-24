bring http;
bring util;

bring "./docker.w" as docker_;

let docker = new docker_.Docker();

test "run container" {
  let container = docker.run(
    image: "nginx",
    tag: "1.25.3-alpine",
    ports: {"80": "8080"},
  );

  // wait a while for the web server to become available
  util.sleep(3s);

  let response = http.get("http://localhost:8080");

  // log("{response.body}");

  assert(response.body.contains("Welcome to nginx"));

  container.stop();
}
