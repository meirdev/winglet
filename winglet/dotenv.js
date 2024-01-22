const dotenv = require("dotenv");

exports.config = dotenv.config;

exports.preflightConfig = dotenv.config;

exports.env = () => process.env;
