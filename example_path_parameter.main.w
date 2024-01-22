bring http;

bring "./winglet/api.w" as api_;

let api = new api_.Api();

api.get("/users/:userId/posts/:postId", inflight (req, res) => {
  let userId = req.params.get("userId");
  let postId = req.params.get("postId");

  res.html("UserID: {userId} PostId: {postId}");
});

api.listen(8080);

test "example" {
  let response = http.get("http://localhost:8080/users/123/posts/456");

  assert(response.body == "UserID: 123 PostId: 456");
}
