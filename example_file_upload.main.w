bring http;

bring "./winglet/api.w" as api_;
bring "./winglet/request.w" as request;

let api = new api_.Api();

api.get("/", inflight (req, res) => {
  res.html("{""}
  <form action='/upload' method='POST' enctype='multipart/form-data'>
    <label>Select file:</label>
    <input type='file' name='upload' />
    <br />
    <input type='submit' value='Send' />
  </form>
  ");
});

api.post("/upload", inflight (req, res) => {
  let file: request.File = unsafeCast(req.form().get("upload"));

  res.html("File name: {file.name}, size: {file.size}, mimetype: {file.mimetype}, tmp path: {file.path}");
});

api.listen(8080);

test "example" {
  let response = http.post(
    "http://localhost:8080/upload",
    body: "--X-INSOMNIA-BOUNDARY\r\nContent-Disposition: form-data; name=\"upload\"; filename=\"doc1.txt\"\r\nContent-Type: text/plain\r\n\r\nhello\n\r\n--X-INSOMNIA-BOUNDARY--\r\n",
    headers: {
      "Content-Type": "multipart/form-data; boundary=X-INSOMNIA-BOUNDARY",
    }
  );

  assert(response.body.startsWith("File name: doc1.txt, size: 6, mimetype: undefined, tmp path:"));
}
