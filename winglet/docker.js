const http = require("node:http");

exports.dockerApi = ({ method, path, body }) => {
  body = JSON.stringify(body ?? "");

  const options = {
    socketPath: "/var/run/docker.sock",
    path,
    method,
    headers: {
      "Content-Type": "application/json",
      "Content-Length": Buffer.byteLength(body),
    },
  };

  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      res.setEncoding("utf8");

      let rawData = "";

      res.on("data", (chunk) => {
        rawData += chunk;
      });

      res.on("end", () => {
        try {
          resolve(rawData !== "" ? JSON.parse(rawData) : null);
        } catch (error) {
          resolve(null);
        }
      });
    });

    req.on("error", (e) => {
      reject(`${e}`);
    });

    req.write(body);
    req.end();
  });
};
