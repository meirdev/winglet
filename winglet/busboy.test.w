bring fs;

bring "./busboy.w" as busboy;

let BODY = "\x2d\x2d\x2d\x2d\x2d\x2d\x57\x65\x62\x4b\x69\x74\x46\x6f\x72\x6d\x42\x6f\x75\x6e\x64\x61\x72\x79\x34\x4d\x30\x4e\x7a\x54\x76\x56\x4e\x6b\x43\x39\x46\x31\x50\x32\x0d\x0a\x43\x6f\x6e\x74\x65\x6e\x74\x2d\x44\x69\x73\x70\x6f\x73\x69\x74\x69\x6f\x6e\x3a\x20\x66\x6f\x72\x6d\x2d\x64\x61\x74\x61\x3b\x20\x6e\x61\x6d\x65\x3d\x22\x74\x61\x73\x6b\x5b\x5d\x22\x0d\x0a\x0d\x0a\x74\x61\x73\x6b\x20\x31\x0d\x0a\x2d\x2d\x2d\x2d\x2d\x2d\x57\x65\x62\x4b\x69\x74\x46\x6f\x72\x6d\x42\x6f\x75\x6e\x64\x61\x72\x79\x34\x4d\x30\x4e\x7a\x54\x76\x56\x4e\x6b\x43\x39\x46\x31\x50\x32\x0d\x0a\x43\x6f\x6e\x74\x65\x6e\x74\x2d\x44\x69\x73\x70\x6f\x73\x69\x74\x69\x6f\x6e\x3a\x20\x66\x6f\x72\x6d\x2d\x64\x61\x74\x61\x3b\x20\x6e\x61\x6d\x65\x3d\x22\x74\x61\x73\x6b\x5b\x5d\x22\x0d\x0a\x0d\x0a\x74\x61\x73\x6b\x20\x32\x0d\x0a\x2d\x2d\x2d\x2d\x2d\x2d\x57\x65\x62\x4b\x69\x74\x46\x6f\x72\x6d\x42\x6f\x75\x6e\x64\x61\x72\x79\x34\x4d\x30\x4e\x7a\x54\x76\x56\x4e\x6b\x43\x39\x46\x31\x50\x32\x0d\x0a\x43\x6f\x6e\x74\x65\x6e\x74\x2d\x44\x69\x73\x70\x6f\x73\x69\x74\x69\x6f\x6e\x3a\x20\x66\x6f\x72\x6d\x2d\x64\x61\x74\x61\x3b\x20\x6e\x61\x6d\x65\x3d\x22\x74\x69\x74\x6c\x65\x22\x0d\x0a\x0d\x0a\x54\x69\x74\x6c\x65\x0d\x0a\x2d\x2d\x2d\x2d\x2d\x2d\x57\x65\x62\x4b\x69\x74\x46\x6f\x72\x6d\x42\x6f\x75\x6e\x64\x61\x72\x79\x34\x4d\x30\x4e\x7a\x54\x76\x56\x4e\x6b\x43\x39\x46\x31\x50\x32\x0d\x0a\x43\x6f\x6e\x74\x65\x6e\x74\x2d\x44\x69\x73\x70\x6f\x73\x69\x74\x69\x6f\x6e\x3a\x20\x66\x6f\x72\x6d\x2d\x64\x61\x74\x61\x3b\x20\x6e\x61\x6d\x65\x3d\x22\x64\x6f\x63\x5b\x5d\x22\x3b\x20\x66\x69\x6c\x65\x6e\x61\x6d\x65\x3d\x22\x64\x6f\x63\x31\x2e\x74\x78\x74\x22\x0d\x0a\x43\x6f\x6e\x74\x65\x6e\x74\x2d\x54\x79\x70\x65\x3a\x20\x74\x65\x78\x74\x2f\x70\x6c\x61\x69\x6e\x0d\x0a\x0d\x0a\x68\x65\x6c\x6c\x6f\x0a\x0d\x0a\x2d\x2d\x2d\x2d\x2d\x2d\x57\x65\x62\x4b\x69\x74\x46\x6f\x72\x6d\x42\x6f\x75\x6e\x64\x61\x72\x79\x34\x4d\x30\x4e\x7a\x54\x76\x56\x4e\x6b\x43\x39\x46\x31\x50\x32\x0d\x0a\x43\x6f\x6e\x74\x65\x6e\x74\x2d\x44\x69\x73\x70\x6f\x73\x69\x74\x69\x6f\x6e\x3a\x20\x66\x6f\x72\x6d\x2d\x64\x61\x74\x61\x3b\x20\x6e\x61\x6d\x65\x3d\x22\x64\x6f\x63\x5b\x5d\x22\x3b\x20\x66\x69\x6c\x65\x6e\x61\x6d\x65\x3d\x22\x64\x6f\x63\x32\x2e\x74\x78\x74\x22\x0d\x0a\x43\x6f\x6e\x74\x65\x6e\x74\x2d\x54\x79\x70\x65\x3a\x20\x74\x65\x78\x74\x2f\x70\x6c\x61\x69\x6e\x0d\x0a\x0d\x0a\x77\x6f\x72\x6c\x64\x0a\x0d\x0a\x2d\x2d\x2d\x2d\x2d\x2d\x57\x65\x62\x4b\x69\x74\x46\x6f\x72\x6d\x42\x6f\x75\x6e\x64\x61\x72\x79\x34\x4d\x30\x4e\x7a\x54\x76\x56\x4e\x6b\x43\x39\x46\x31\x50\x32\x2d\x2d\x0d\x0a";

test "multipart/form-data" {
  let formData = busboy.Busboy.busboy(
    {
      "content-type": "multipart/form-data; boundary=----WebKitFormBoundary4M0NzTvVNkC9F1P2",
    },
    BODY,
  );

  assert(unsafeCast(formData.get("task[]")) == ["task 1", "task 2"]);

  assert(unsafeCast(formData.get("title")) == ["Title"]);

  let file1: busboy.File = unsafeCast(formData.get("doc[]").at(0));

  assert(file1.name == "doc1.txt");
  assert(fs.readFile(file1.path) == "hello\n");

  let file2: busboy.File = unsafeCast(formData.get("doc[]").at(1));

  assert(file2.name == "doc2.txt");
  assert(fs.readFile(file2.path) == "world\n");
}

test "application/x-www-form-urlencoded" {
  let formData = busboy.Busboy.busboy(
    {
      "content-type": "application/x-www-form-urlencoded",
    },
    "task%5B%5D=task+1&task%5B%5D=task+2&title=Title",
  );

  assert(unsafeCast(formData.get("task[]")) == ["task 1", "task 2"]);

  assert(unsafeCast(formData.get("title")) == ["Title"]);
}
