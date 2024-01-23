interface ValueOrFile {
}

pub struct File {
  path: str;
  name: str;
  size: num;
  mimetype: str?;
  encoding: str?;
}

pub class FormData {
  pub static extern "./formdata.js" inflight formdata(headers: Map<str>, body: str): Map<Array<ValueOrFile>>;
}
