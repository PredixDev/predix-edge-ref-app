
## What you need to do

Now let's redesign our data flow to scale the values of the sensor data by 1000.

## The Initial Flow

The flow should start out like this.

![initial-flow](images/initial-flow.png)

(scroll for more content)

## See the Traffic

1. Drag a link from the OPCUA Adapter Topic to the Cloud Gateway Topic
2. Click the Deploy button up above
3. Click the Debug tab up above

This is the same traffic you saw on the Operations tab in the graph and it is currently being sent to Predix Time Series in the cloud.

![initial-flow](images/see-the-traffic.png)

## Add a Function

1. Drag a Function node and place it in the flow between the From OPCUA Adapter and To Cloud Gateway
2. If needed drag lines between the nodes
3. Double click the new Function node, name it Scalar

    ![initial-flow](images/scale-the-data.png)

4. Copy the code below, paste it in the Function

        //read the message into a json object
        var item = JSON.parse(msg.payload);

        //scale up the value by 1000 and put it back on the broker topic to be sent to Predix Time Series
        for ( var i=0;i<item.body.length;i++)
        {
          var tagName = item.body[i].name;
          var value = item.body[i].datapoints[0][1];

          //scale the tag value * 100
          item.body[i].datapoints[0][1] = value * 100;

          //don't do this for workshop - APM Asset Model needs to match
          //you could even give the scaled tag a new name
          //item.body[0].name = tagName + '.scaled_x_1000';

          var scaled_item = JSON.stringify(item);

          //publish the tag back to the broker on the topic the cloud-gateway
          //container is subscribing to
          msg.payload = scaled_item

          return msg;
        }

5. Click Done then Deploy



## Validate Results

1. Drag the Input node named MQTT on to the palette
2. Double click and enter **timeseries_data** in the topic.
3. Delete the old link to the Debug node and make a new one from the MQTT **timeseries_data** listener.
4. Deploy
5. Pro Tip: try a scalar of 0 or a large number to see the change, and Deploy.  Please change it back to 100 and Deploy.

![initial-flow](images/validate-flow.png)
