const http = require('http');
const WebSocket = require('ws');
const url = require('url');
const jsonify = require('./jsonify-funcs.js');

//a map of web socket servers, the key is the url path, e.g. /livestream/Compressor-CMMS-Compressor-2018:DischargePressure
const wsMap = new Map();

//TODO: does this interfere with the node.js itself?
const server = http.createServer();
server.listen(9002);

//allows us to upgrade from an http connection to a wss connection
server.on('upgrade', function upgrade(request, socket, head) {  
  //check requested pathname and create a wss for each valid one
  const pathname = url.parse(request.url).pathname;
  if ( pathname == "/livestreams") {
    const wssLivestreams = new WebSocket.Server({ noServer: true });
    wssLivestreams.on('connection', function connection(ws) {
      ws.send(JSON.stringify(jsonify.strMapToObj(wsMap,),null,2));
    });
    wssLivestreams.handleUpgrade(request, socket, head, function done(ws) {
      wssLivestreams.emit('connection', ws, request);
    });
  }
  else {
    let wss = wsMap.get(pathname);
    if ( wss == null ) {
        console.log("unable to create websocket connection, invalid path=" + pathname);
        socket.destroy();
    } else {
      add(pathname);
      wss = wsMap.get(pathname);
      wss.handleUpgrade(request, socket, head, function done(ws) {
        wss.emit('connection', ws, request);
      });
    }
  }
});

//add a new websocket server for a particular URL, e.g. /livestream/Compressor-CMMS-Compressor-2018:DischargePressure
const add = function add(key) {
  const wss = new WebSocket.Server({ noServer: true });
  wsMap.set(key,wss);
  wss.on('connection', function connection(ws) {
    ws.on('message', function incoming(message) {
      //console.log('received: %s', message);
    });
    ws.send('{ "message": "' + key + ' connected" }');
  });
  // Broadcast to all.
  wss.broadcast = function broadcast(data) {
    // hacky filter to broadcast data no more than 2 times per second.
    wss.lastBroadcast = wss.lastBroadcast || new Date();
    wss.clients.forEach(function each(client) {
      if (client.readyState === WebSocket.OPEN) {
        let currentTime = new Date();
        // console.log('time diff: ', currentTime.valueOf() - wss.lastBroadcast.valueOf());
        if (currentTime.valueOf() - wss.lastBroadcast.valueOf() > 500) {
          // console.log('sending data over web socket', data);
          client.send(data);
          wss.lastBroadcast = currentTime;
        }
      }
    });
  };
}
module.exports = { wsMap: wsMap };
