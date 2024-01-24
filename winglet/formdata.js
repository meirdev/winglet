const { realpathSync, appendFileSync } = require("node:fs");
const { tmpdir } = require("node:os");
const { randomUUID } = require("node:crypto");
const { join } = require("node:path");

const busboy = require("busboy");

function tempfile() {
  return join(realpathSync(tmpdir()), randomUUID());
}

function FormData(headers, body) {
  return new Promise((resolve, reject) => {
    const formData = {
      files: {},
      fields: {},
    };

    const bb = busboy({ headers });

    bb.on("file", (name, file, info) => {
      let tmpFile = tempfile();

      const { filename, encoding, mimetype } = info;

      let size = 0;

      file
        .on("data", async (data) => {
          appendFileSync(tmpFile, data);
          size += data.length;
        })
        .on("error", () => reject(null))
        .on("end", () => {
          if (!(name in formData.files)) {
            formData.files[name] = [];
          }

          formData.files[name].push({
            path: tmpFile,
            name: filename,
            size,
            mimetype,
            encoding,
          });
        });
    })
      .on("field", (name, value) => {
        if (!(name in formData.fields)) {
          formData.fields[name] = [];
        }

        formData.fields[name].push(value);
      })
      .on("finish", () => {
        resolve(formData);
      })
      .on("error", () => {
        reject(null);
      });

    bb.end(body);
  });
}

exports.formdata = FormData;
