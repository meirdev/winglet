bring cloud;
bring http;
bring util;

bring "./url.w" as url;

struct DockerApiOptions {
  path: str;
  method: str;
  body: Json?;
}

pub struct DockerOptions {
  image: str;
  tag: str;
  ports: Map<str>;
  cmd: Array<str>?;
}

pub class Docker {
  pub static extern "./docker.js" inflight dockerApi(options: DockerApiOptions): Json?;

  options: DockerOptions;

  new(options: DockerOptions) {
    this.options = options;
  }

  inflight new() {
    let var result = Docker.dockerApi(
      path: "/images/create?{url.Url.urlSearchParams({"fromImage": this.options.image, "tag": this.options.tag}).toString()}",
      method: "POST",
    );

    // log("{result}");

    let portBindings = MutMap<Array<Map<str>>>{};

    for port in this.options.ports.keys() {
      portBindings.set("{port}/tcp", [{"HostPort": "{this.options.ports.get(port)}/tcp"}]);
    }

    // log("{portBindings}");

    result = Docker.dockerApi(
      path: "/containers/create",
      method: "POST",
      body: {
        "Image": "{this.options.image}:{this.options.tag}",
        "Cmd": this.options.cmd,
        "HostConfig": {
          "PortBindings": Json.parse(Json.stringify(portBindings)),
        },
      },
    );

    // log("{result}");

    let id = result?.get("Id")?.asStr();

    result = Docker.dockerApi(
      path: "/containers/{id}/start",
      method: "POST",
    );

    // log("{result}");

    util.sleep(5s);

    result = Docker.dockerApi(
      path: "/containers/{id}/stop",
      method: "POST",
    );

    // log("{result}");
  }

  pub inflight run() {

  }
}
