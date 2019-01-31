class EdgeLiveChart extends Polymer.Element {
  static get is() { return 'edge-live-chart'; }
  static get properties() {
    return {
      tsChartData: {
        type: Array,
        value: []
      },
      tsSeriesConfig: {
        type: Object,
        value: () => {
          // TODO
          return {
            "y0": {
                "name": "y0",
                "x": "timeStamp",
                "y": "y0",
                "yAxisUnit": "F",
                "axis": {
                    "id": "axis1",
                    "side": "left",
                    "number": "1"
                }
            }
          }
        }
      },
      topics: {
        type: Array,
        observer: '_topicItemsChanged'
      },
      selectedTopic: {
        type: String,
        observer: '_selectedTopicChanged'
      },
      tags: {
        type: Array,
        value: []
      },
      selectedTag: {
        type: String,
        observer: '_selectedTagChanged'
      },
      _socket: {
        type: Object
      },
      assetSpecs: {
        type: Array,
        value: []
      },
      steps: Object,
      stepsPrev: Object,
      stepsNext: Object,
      stepsData: Object,
      handleStepTap: Function
    }
  }
  constructor() {
    super();
    this.handleStepTap = this.handleStepTapFunc.bind(this);
  }
  connectedCallback() {
    //a place to put some console.logs - called near startup
    super.connectedCallback();
    console.log("edge-live-chart connectedCallback");
    this.show(this.stepsPrev);
    this.handleStepTap = this.handleStepTapFunc.bind(this);
    this.steps.addEventListener('px-steps-tapped-nav', this.handleStepTap);

    this.steps.items=this.stepsData.slice(3,7);
    this.steps.jumpToStep(1);

    this._fetchLiveStreams();
    this.$.specsAjax.addEventListener('response', function(evt) {
      this.set('assetSpecs', evt.detail.response.specs);
    }.bind(this));
  }

  disconnectedCallback() {
    console.log("edge-live-chart disconnectedCallback");
    this.steps.removeEventListener('px-steps-tapped-nav', this.handleStepTap);
    this._closeDataSocket();
  }
  handleStepTapFunc(event) {
    console.log("edge-live-chart:handleStepTap",event.detail);
    console.log("elc:current step (zero based)", event.detail.prevStep, "goto (non zero based)", event.detail.currentStep);
      if ( event.detail.currentStep == 0 ) {
        window.history.pushState({}, null, '/home');
        window.dispatchEvent(new CustomEvent('location-changed'));
        this.steps.setStep = 3;
      }
      else if ( event.detail.currentStep == 2 ) {
        console.log("jump to configuration");
        window.history.pushState({}, null, '/configuration');
        window.dispatchEvent(new CustomEvent('location-changed'));
      }
      else if ( event.detail.currentStep == 3 ) {
        console.log("jump to device");
        window.history.pushState({}, null, '/device');
        window.dispatchEvent(new CustomEvent('location-changed'));
      }
  }

  _fetchLiveStreams() {
    try {
      const socket = new WebSocket('ws://127.0.0.1:9002/livestreams')

      socket.onerror = (error) => {
        console.error('WebSocket Error: ', error);
      };

      socket.onmessage = function(evt) {
        console.log('message from WebSocket: ' + evt.data);
        this.tags = [];
        this.push('tags', ...Object.keys(JSON.parse(evt.data)));
        this.selectedTag = this.tags[0];
        socket.close();
      }.bind(this);

      socket.onclose = (evt) => {
        console.log('websocket closed. code: ' + evt.code);
      }
    } catch (err) {
      console.error('Error opening web socket. ', err);
    }
  }

  _closeDataSocket() {
    if (this._socket && this._socket.readyState !== WebSocket.CLOSED) {
      this._socket.close();
    }
  }

  _topicItemsChanged(newVal, oldVal) {
    if ( newVal.includes("app_data"))
      this.selectedTopic = "app_data";
  }

  _selectedTopicChanged(newVal, oldVal) {
    console.log("_selectedTopicChanged");
    console.log(newVal);
    if ( !newVal )
      return
    else {
      this.$.ironPostTopic.body = '["' + newVal + '"]';
      console.log(this.$.ironPostTopic.body)
      this.$.ironPostTopic.generateRequest();
    }
  }

  _selectedTagChanged(newVal, oldVal) {
    this._closeDataSocket();
    this.tsChartData = [];
    if (!newVal) return;
    try {
      this._socket = new WebSocket('ws://127.0.0.1:9002' + newVal);

      this._socket.onmessage = function(evt) {
        // console.log('message from WebSocket: ' + evt.data);
        const rawData = JSON.parse(evt.data);
        if (rawData.datapoints && rawData.datapoints.length>0) {
          const rawPoint = rawData.datapoints[0];
          if (this.tsChartData.length > 99) {
            this.shift('tsChartData');
          }
          this.push('tsChartData', {"timeStamp": rawPoint[0], "y0": rawPoint[1]});
        }
        // console.log('chart data length:', this.tsChartData.length);
      }.bind(this);

      this._socket.onerror = (error) => {
        console.error('WebSocket Error: ', error);
      }

      this._socket.onclose = (evt) => {
        console.log('websocket closed. code: ' + evt.code);
      }

    } catch (err) {
      console.error('Error opening web socket. ', err);
    }
  }

  hide(item) {
    item.style.display = "none";
  }
  show(item) {
    item.style.display = "block";
  }

}

window.customElements.define(EdgeLiveChart.is, EdgeLiveChart);
