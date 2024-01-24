interface ValueOrFile {
}

pub struct File {
  path: str;
  name: str;
  size: num;
  mimetype: str?;
  encoding: str?;
}

pub struct Form {
  files: Map<Array<File>>;
  fields: Map<Array<str>>;
}

pub class FormData {
  pub static extern "./formdata.js" inflight formdata(headers: Map<str>, body: str): Form;
}
