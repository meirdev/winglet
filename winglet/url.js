const URL = require("node:url").URL;

exports.url = (input) => {
  if (input.startsWith("/")) {
    // add dummy url to allow URL parse the string
    input = `http://0.0.0.0${input}`;
  }
  return new URL(input);
}

exports.urlSearchParams = (params) => new URLSearchParams(params);
