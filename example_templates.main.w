bring cloud;
bring http;

bring "./winglet/api.w" as api_;
bring "./winglet/template.w" as template_;

let api = new api_.Api();

let template = new template_.Template("./templates");

api.get("/", inflight (req, res) => {
  let index = template.render("./index.html");

  res.html(index);
});

api.listen(8080);

test "example" {
  let response = http.get("http://localhost:8080/");

  assert(response.body.contains("<h1>Hello \{\{ name \}\}</h1>"));
}
