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

class Docker_ {
  pub static extern "./docker.js" inflight dockerApi(options: DockerApiOptions): Json?;
}

pub inflight class Container {
  dockerId: str;

  new(dockerId: str) {
    this.dockerId = dockerId;
  }

  pub inflight stop() {
    let result = Docker_.dockerApi(
      path: "/containers/{this.dockerId}/stop",
      method: "POST",
    );

    // log("{result}");
  }
}

pub class Docker {
  name: str;

  new() {
    this.name = nodeof(this).addr.substring(0, 8);
  }

  pub inflight run(options: DockerOptions): Container {
    let var result = Docker_.dockerApi(
      path: "/containers/json?{url.Url.urlSearchParams({"all": true}).toString()}",
      method: "GET",
    );

    // log("{Json.stringify(result)}");

    let var containerId: str? = nil;

    let containers: Array<Json> = unsafeCast(result);

    for container in containers {
      if container.get("Names").getAt(0).asStr() == "/{this.name}" {
        containerId = container.get("Id").asStr();
      }
    }

    if !containerId? {
      result = Docker_.dockerApi(
        path: "/images/create?{url.Url.urlSearchParams({"fromImage": options.image, "tag": options.tag}).toString()}",
        method: "POST",
      );

      // log("{Json.stringify(result)}");

      let portBindings = MutMap<Array<Map<str>>>{};

      for port in options.ports.keys() {
        portBindings.set("{port}/tcp", [{"HostPort": "{options.ports.get(port)}/tcp"}]);
      }

      // log("{portBindings}");

      result = Docker_.dockerApi(
        path: "/containers/create?{url.Url.urlSearchParams({"name": this.name}).toString()}",
        method: "POST",
        body: {
          "Image": "{options.image}:{options.tag}",
          "Cmd": options.cmd,
          "HostConfig": {
            "PortBindings": Json.parse(Json.stringify(portBindings)),
          },
        },
      );

      // log("{Json.stringify(result)}");

      containerId = result?.get("Id")?.asStr();
    }

    result = Docker_.dockerApi(
      path: "/containers/{containerId}/start",
      method: "POST",
    );

    // log("{result}");

    if let id = containerId {
      return new Container(id);
    }
  }
}
