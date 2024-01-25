bring fs;

pub class Glob {
  pub static glob(path: str): MutArray<str> {
    let files = MutArray<str>[];
  
    let addToFiles = (path: str) => {
      let dir = fs.readdir(path);
  
      for file in dir {
        let filePath = fs.absolute(fs.join(path, file));
  
        if fs.isDir(filePath) {
          addToFiles(filePath);
        } else {
          files.push(filePath);
        }
      }
    };
  
    addToFiles(path);
  
    return files;
  }
}
