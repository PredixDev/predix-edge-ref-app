'use strict';
const merge = require('merge-stream');

// ------------------------------------------------
//   Task: Copy extra files for deployment
//    Most files are included in the bundle, these are exceptions.
// ------------------------------------------------

module.exports = function(gulp) {
  return function() {
    var outputDir = './build/es6-bundled/';
    // These directories contain files that are not included in the polymer build output for various reasons.
    // (Whenever possible files should be imported using HTML imports, so they're included in the polymer build.)
    var extraDirectories = [
    //   'public/bower_components/polymer',
    //   'public/bower_components/webcomponentsjs',

    //   'public/bower_components/px-typography-design',
    //   'public/bower_components/px-theme',
      'bower_components/px-dark-theme',
    //   'public/bower_components/px-vis',
    //   'public/bower_components/pxd3',
    //   'public/downloads',

    //   'public/elements/dev-guide'
    ];

    var extraStreams = [];

    extraDirectories.forEach(function(bc) {
      extraStreams.push(gulp.src([bc + '/**/*.*']).pipe(gulp.dest(outputDir + bc)));
    });

    var server = gulp.src(['server/**/*.*']).pipe(gulp.dest(outputDir + '/server'))
    var packageFile = gulp.src(['package.json']).pipe(gulp.dest(outputDir));
    var imageFiles = gulp.src(['images/**/*.*']).pipe(gulp.dest(outputDir + '/images'));
    var dataFiles = gulp.src(['data/**/*.*']).pipe(gulp.dest(outputDir + '/data'));

    return merge(server, packageFile, extraStreams, imageFiles, dataFiles);
  };
};
