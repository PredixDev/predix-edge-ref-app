![logo](images/edge-ref-app.png)

## One App, Many Devices

The app we are building will be deployed to many devices.  Some Configs may vary per Asset or Device.  Edge Manager helps you remotely manage and deploy Apps to all your devices.

## Viewing This Application's Config Files

Recall from the Application architecture that the containers are speaking to each other over a pub/sub message queue.  

In the Node-Red window, click Debug tab to view the mqtt configs.  Click on each debug msg to format the text more nicely.

 - Notice how the OPC UA Adapter is sending data to the app_data topic.

 - Notice how the Time Series Cloud Gateway is receiving data on the timeseries_data topic.
