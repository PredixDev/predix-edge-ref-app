'use strict';

// -------------------------------------
//   Task: Watch: Public
// -------------------------------------

module.exports = function(gulp) {
  return function() {
    gulp.watch(['src/**/*.scss', 'public/*.scss'], ['compile:sass']);
  };
};
