pub struct User {
  id: num;
  username: str;
  name: str?;
  bio: str?;
  link: str?;
  image_url: str?;
  is_verified: bool;
  joined_at: num;
  followers_count: num;
}

// enum PostType {
//     THREAD,
//     REPLY,
//     REPOST,
//     QUOTE,
// }

struct _Post {
  id: num;
  code: str;
  user: num;
  content: str?;
  created_at: num;
  updated_at: num;
  likes_count: num;
  replies_count: num;
  quotes_count: num;
  reposts_count: num;
  type: str;
}

pub struct Post extends _Post {
  thread: _Post?;
  quote: _Post?;
  repost: _Post?;
}

pub struct Attachment {
  id: num;
  post: num;
  url: str;
  mime_type: str;
  size: num;
  metadata: Json?;
}

pub struct Link {
  id: num;
  post: num;
  url: str;
  display_url: str?;
  image_url: str?;
  title: str?;
}
