bring "./router.w" as router;

test "multi params" {
  let pattern = new router.Pattern("/users/:userId/posts/:postId");

  assert(Json.stringify(pattern.match("/users/123/posts/456")) == Json.stringify({"userId": "123", "postId": "456"}));
}

test "with asterisk" {
  let pattern = new router.Pattern("/pages/*");

  assert(pattern.match("/pages/hello-world") != nil);

  let pattern2 = new router.Pattern("*");

  assert(pattern2.match("/pages/hello-world") != nil);
  assert(pattern2.match("/") != nil);
}
