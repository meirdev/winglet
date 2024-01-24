bring cloud;
bring fs;
bring util;

bring "cdktf" as cdktf;
bring "@cdktf/provider-aws" as tfaws;

bring "./mime-types.w" as mimeTypes;
bring "./server.w" as server;
bring "./response.w" as response;

pub struct StaticFilesProps {
  path: str;
  indexDocument: str?;
  errorDocument: str?;
  simPort: num?;
}

pub interface IStaticFiles extends std.IResource {}

pub class StaticFilesBase {
  protected defaultIndexDocument: str;
  protected defaultErrorDocument: str;
  protected defaultSimPort: num;
  protected testingMode: bool;

  new() {
    this.defaultIndexDocument = "index.html";
    this.defaultErrorDocument = "index.html";
    this.defaultSimPort = 9000;

    try {
      this.testingMode = util.env("TESTING_MODE") == "y";
    } catch {
      this.testingMode = false;
    }
  }

  protected glob(path: str): MutArray<str> {
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

pub class StaticFilesSim extends StaticFilesBase impl IStaticFiles {
  new(props: StaticFilesProps) {
    if this.testingMode || !std.Node.of(this).app.isTestEnvironment {
      let port = props.simPort ?? this.defaultSimPort;

      log("Static files URL: http://localhost:{port}");

      let absPath = fs.absolute(props.path);

      let httpServer = new server.HttpServer(inflight (req, res) => {
        let path = fs.join(absPath, req.pathname);

        let resData = new response.Response();

        if fs.isDir(path) {
          resData.status(403).html("Directory index is not implemented");
        }
        elif fs.exists(path) {
          resData.status(200).file(path).header("Content-Type", mimeTypes.MimeType.lookup(path));
        }
        else {
          resData.status(404).html("File not found");
        }

        res(resData);
      });

      new cloud.Service(inflight () => {
        httpServer.listen(port);

        return inflight () => { httpServer.close(); };
      });
    }
  }
}

pub class StaticFilesTfaws extends StaticFilesBase impl IStaticFiles {
  bucket: tfaws.s3Bucket.S3Bucket;

  new(props: StaticFilesProps) {
    super();

    this.bucket = new tfaws.s3Bucket.S3Bucket({
      bucket: "static-files-" + nodeof(this).addr.substring(0, 8),
    });

    new tfaws.s3BucketPublicAccessBlock.S3BucketPublicAccessBlock({
      bucket: this.bucket.id,
      blockPublicAcls: false,
      blockPublicPolicy: false,
      ignorePublicAcls: false,
      restrictPublicBuckets: false,
    });

    let var indexDocument: tfaws.s3BucketWebsiteConfiguration.S3BucketWebsiteConfigurationIndexDocument? = nil;

    if let indexDocument_ = props.indexDocument {
      indexDocument = {
        suffix: indexDocument_,
      };
    } else {
      indexDocument = {
        suffix: this.defaultIndexDocument,
      };
    }

    let var errorDocument: tfaws.s3BucketWebsiteConfiguration.S3BucketWebsiteConfigurationErrorDocument? = nil;

    if let errorDocument_ = props.errorDocument {
      errorDocument = {
        key: errorDocument_,
      };
    } else {
      errorDocument = {
        key: this.defaultErrorDocument,
      };
    }

    new tfaws.s3BucketWebsiteConfiguration.S3BucketWebsiteConfiguration({
      bucket: this.bucket.id,
      indexDocument: indexDocument,
      errorDocument: errorDocument,
    });

    new tfaws.s3BucketPolicy.S3BucketPolicy({
      bucket: this.bucket.id,
      policy: Json.stringify({
        Version: "2012-10-17",
        Statement: [
          {
            Sid: "AllowGetObject",
            Effect: "Allow",
            Principal: "*",
            Action: [
              "s3:GetObject",
            ],
            Resource: [
              "{this.bucket.arn}/*",
            ],
          },
        ],
      }),
    });

    let absPath = fs.absolute(props.path);

    for file in this.glob(absPath) {
      let key = file.substring(absPath.length + 1);

      new tfaws.s3Object.S3Object({
        bucket: this.bucket.id,
        key: file.substring(absPath.length + 1),
        source: file,
        contentType: mimeTypes.MimeType.preflightLookup(file),
        etag: "{datetime.utcNow().timestamp}",
      }) as "file-{key}";
    }

    new cdktf.TerraformOutput({
      value: "http://{this.bucket.bucket}.s3-website.{this.bucket.region}.amazonaws.com",
    });
  }
}

pub class StaticFiles impl IStaticFiles {
  new(props: StaticFilesProps) {
    let target = util.env("WING_TARGET");

    if target == "sim" {
      new StaticFilesSim(props) as "sim";
    } elif target == "tf-aws" {
      new StaticFilesTfaws(props) as "tf-aws";
    } else {
      throw "Unsupported target {target}";
    }
  }
}
