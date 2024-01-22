const URL = require("node:url").URL;

exports.url = (input) => new URL(input);

exports.urlSearchParams = (params) => new URLSearchParams(params);
