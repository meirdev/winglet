bring http;
bring util;

bring "./docker.w" as docker;

let container = new docker.Docker(
  image: "nginx",
  tag: "1.25.3-alpine",
  ports: {"80": "8080"},
);

test "run container" {
  container.run();
}
