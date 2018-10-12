'use strict';

// -------------------------------------
//   Task: Serve raw unbundled files from /public
// -------------------------------------
const nodemon = require('gulp-nodemon');

module.exports = function() {
  return function() {
    nodemon({
        script: 'server/app.js',
        ignore: ['/../*'],
        env: { 'base-dir' : '/..', 'node_env' : 'development'}
      })
      .on('restart', function() {
        console.log('app.js restarted');
      });
  };
};
