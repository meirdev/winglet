const { Client } = require("pg");

exports.client = (config) => new Client(config);
