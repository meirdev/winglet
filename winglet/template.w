bring fs;

bring "./glob.w" as glob;

pub class Template {
  dir: str;
  templates: MutMap<str>;

  new(dir: str) {
    this.dir = "";
    this.templates = {};

    for file in glob.Glob.glob(dir) {
      this.templates.set(fs.relative(file, dir), fs.readFile(file));
    }
  }

  injectContext(template: str, context: Json?) {

  }

  pub inflight render(path: str, context: Json?): str {
    let key = fs.relative(fs.join(this.dir, path), this.dir);

    return this.templates.get(key);
  }
}
