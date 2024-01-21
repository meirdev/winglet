interface ValueOrFile {
}

pub struct File {
  path: str;
  name: str;
  size: num;
  mimetype: str?;
  encoding: str?;
}

pub class Busboy {
  pub static extern "./busboy.js" inflight busboy(headers: Map<str>, body: str): Map<Array<ValueOrFile>>;
}
