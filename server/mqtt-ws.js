// Connect to edge MQTT broker, then broadcast data over websocket for UI to consume.

const mqtt = require('mqtt')
const appConfig = require('./edge-ref-app-config.js');
var ws = require('./edge-ws-server.js');

const client = mqtt.connect(appConfig.mqttHost);
var topics = [];
let topicToMonitor = appConfig.operationsTopic;

client.on('connect', () => {
  client.subscribe("#");
  console.log('mqtt client connected with options: ', client.options);
})

client.on('message', (topic, message) => {
  if ( !topics.includes(topic) )
    topics[topics.length] = topic;
  if(topic === topicToMonitor) {
    const obj = JSON.parse(message.toString());
    const path = '/livestream/' + obj.body[0].name;
    const wss = ws.wsMap.get(path);
    if ( wss == null ) {
      ws.wsMap.set(path, "valid");
    }
    if ( wss != "valid" && wss != null ) {
      wss.broadcast(JSON.stringify(obj.body[0]));
    }
  }
})

// client.on('error') didn't work... have to attach to the client.stream instead.
client.stream.on('error', (err) => {
  console.error(err.message);
  console.error(err);
})

function getTopics(req,res) {
  console.log("getTopics");
  console.log(topics);
  res.send(topics);
}

function postTopic(req,res) {
  console.log("postTopic");
  topicToMonitor = req.body[0];
}

function handleDeviceEvent(req,res) {
  console.log("handleDeviceEvent");
  console.log(req.body);
  let tsIngest = {
    "messageId": "1453338376222",
    "body": [
      {
        "name": "Compressor-CMMS-Compressor-2018.device-event",
        "datapoints": [
          [
            1453338376222,
            10,
            3
          ]
        ],
        "attributes": {
        }
      }
    ]
  };
  tsIngest.messageId = Math.round((new Date()).getTime());
  //TODO ensure tag name comes from body
  tsIngest.body[0].datapoints[0][0] = tsIngest.messageId; //time
  tsIngest.body[0].datapoints[0][1] = req.body.eventId; //value
  tsIngest.body[0].datapoints[0][2] = 3; //quality
  tsIngest.body[0].attributes.deviceEventCost = req.body.cost;
  tsIngest.body[0].attributes.deviceEventType = req.body.eventType;
  client.publish('timeseries_data', JSON.stringify(tsIngest));
  console.log(JSON.stringify(tsIngest));
}

module.exports = {
  handleDeviceEvent: handleDeviceEvent,
  getTopics: getTopics,
  postTopic: postTopic
}
