bring fs;

bring "./formdata.w" as formdata;

let BODY = "------WebKitFormBoundary4M0NzTvVNkC9F1P2\r\nContent-Disposition: form-data; name=\"task[]\"\r\n\r\ntask 1\r\n------WebKitFormBoundary4M0NzTvVNkC9F1P2\r\nContent-Disposition: form-data; name=\"task[]\"\r\n\r\ntask 2\r\n------WebKitFormBoundary4M0NzTvVNkC9F1P2\r\nContent-Disposition: form-data; name=\"title\"\r\n\r\nTitle\r\n------WebKitFormBoundary4M0NzTvVNkC9F1P2\r\nContent-Disposition: form-data; name=\"doc[]\"; filename=\"doc1.txt\"\r\nContent-Type: text/plain\r\n\r\nhello\n\r\n------WebKitFormBoundary4M0NzTvVNkC9F1P2\r\nContent-Disposition: form-data; name=\"doc[]\"; filename=\"doc2.txt\"\r\nContent-Type: text/plain\r\n\r\nworld\n\r\n------WebKitFormBoundary4M0NzTvVNkC9F1P2--\r\n";

test "multipart/form-data" {
  let formData = formdata.FormData.formdata(
    {
      "content-type": "multipart/form-data; boundary=----WebKitFormBoundary4M0NzTvVNkC9F1P2",
    },
    BODY,
  );

  assert(unsafeCast(formData.fields.get("task[]")) == ["task 1", "task 2"]);

  assert(unsafeCast(formData.fields.get("title")) == ["Title"]);

  let file1 = formData.files.get("doc[]").at(0);

  assert(file1.name == "doc1.txt");
  assert(fs.readFile(file1.path) == "hello\n");

  let file2 = formData.files.get("doc[]").at(1);

  assert(file2.name == "doc2.txt");
  assert(fs.readFile(file2.path) == "world\n");
}

test "application/x-www-form-urlencoded" {
  let formData = formdata.FormData.formdata(
    {
      "content-type": "application/x-www-form-urlencoded",
    },
    "task%5B%5D=task+1&task%5B%5D=task+2&title=Title",
  );

  assert(formData.fields.get("task[]") == ["task 1", "task 2"]);

  assert(formData.fields.get("title") == ["Title"]);
}
