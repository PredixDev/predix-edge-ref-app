## Predix Edge App

Our Predix Edge application architecture consists of 4 Docker containers

- **MQTT Data Broker** - a pub/sub message queue
- **OPCUA Adapter** - listens for OPCUA Protocol, converts to Time Series format
- **Node Red** - for the demo workshop
- **Time Series Data Pump** - sends data to Predix Time Series in the cloud

![logo](images/edge-ref-app.png)


######     *Edge Agent runs native on the Predix Edge OS and not in a Docker container. The Edge Agent securely manages communication and registration for Predix Edge OS.

## Data Flow

From a data flow perspective the app is designed like this

![logo](images/edge-ref-app-data-flows-small.png)
