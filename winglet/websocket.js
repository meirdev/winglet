const WebSocketServer = require("websocket").server;

exports.websocket = (server) => new WebSocketServer({ httpServer: server });
