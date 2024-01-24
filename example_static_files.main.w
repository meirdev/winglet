bring http;
bring util;

bring "./winglet/static-files.w" as staticFiles_;

let staticFiles = new staticFiles_.StaticFiles(path: "./assets/");

test "example" {
  let response = http.get("http://localhost:9000/index.html");

  assert(response.body.contains("Welome to Winglet"));
}
