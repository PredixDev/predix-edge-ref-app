## Time Series Tags Config File

Time Series Tags are the primary key of sensor data coming in from, in this case, the OPCUA adapter.  

Here are the tag definitions used by the OPCUA Adapter to convert the sensor data to Time Series format.  The Cloud Gateway sends the data to Predix Time Series in the cloud and is used by APM.

    "opcua": {
        "type": "opcuasubflat",
        "config": {
            "transport_addr": "opc-tcp://3.39.89.86:49310",
            "log_level": "debug",
            "data_map": [
                {
                  "alias": "Compressor-CMMS-Compressor-2018:CompressionRatio",
                  "id": "ns=2;s=Simulator.Device1.FLOAT1"
                },
                {
                  "alias": "Compressor-CMMS-Compressor-2018:DischargePressure",
                  "id": "ns=2;s=Simulator.Device1.FLOAT2"
                },
                {
                  "alias": "Compressor-CMMS-Compressor-2018:SuctionPressure",
                  "id": "ns=2;s=Simulator.Device1.FLOAT3"
                },
                {
                  "alias": "Compressor-CMMS-Compressor-2018:Velocity",
                  "id": "ns=2;s=Simulator.Device1.FLOAT4"
                },
                {
                  "alias": "Compressor-CMMS-Compressor-2018:Temperature",
                  "id": "ns=2;s=Simulator.Device1.FLOAT5"
                }
            ]
        }
      }
