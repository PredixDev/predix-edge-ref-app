/*
This module reads config settings from localConfig.json when running locally with gulp,
  or from containerConfig.json when running in docker.
*/

let settings = {};

// checking NODE_ENV to load cloud properties from VCAPS
// or development properties from config.json.
const node_env = process.env.node_env || 'development';
if(node_env === 'development') {
  // use localConfig file
	settings = require('./config/localConfig.json');
} else {
  settings = require('./config/containerConfig.json')
}

module.exports = settings;
