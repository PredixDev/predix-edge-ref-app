'use strict';

// -------------------------------------
//   Task: Serve bundled files from /build
// -------------------------------------
const nodemon = require('gulp-nodemon');

module.exports = function() {
  return function() {
    nodemon({
        script: 'server/app.js',
        ignore: ['*'],
        env: { 'base-dir' : '/../build/es6-bundled'}
      })
      .on('restart', function() {
        console.log('app.js restarted');
      });
  };
};
