/*******************************************************
The edge-ref-app Express web application includes these features:
  * simple authentication with local db. (not UAA or OAuth)
  * proxy to node-red
*******************************************************/
var http = require('http'); // needed to integrate with ws package for mock web socket server.
const express = require('express');
var path = require('path');
var mqtt = require('./mqtt-ws.js');
var bodyParser = require('body-parser')


// var cookieParser = require('cookie-parser'); // used for session cookie
// var bodyParser = require('body-parser');
// var session = require('express-session');
// get config settings from local file or VCAPS env var in the cloud
// var config = require('./predix-config');
// getting user information from UAA
// var userInfo = require('./routes/user-info');
const app = express();
var httpServer = http.createServer(app);

/**********************************************************************
       SETTING UP EXRESS SERVER
***********************************************************************/
// app.set('trust proxy', 1);

// if running locally, we need to set up the proxy from local config file:
const node_env = process.env.node_env || 'development';
console.log('************ Environment: '+node_env+' ******************');

console.log('base-dir:', process.env['base-dir']);
app.use(express.static(path.join(__dirname, process.env['base-dir'] ? process.env['base-dir'] : '../'), {index: "src/index.html"}));
// app.use('/bower_components', express.static(path.join(__dirname, process.env['base-dir'] ? process.env['base-dir'] : '../bower_components')))
// need these routes to support browser refresh:
app.use(['/home', '/operations', '/configuration', '/device'], (req, res) => {
  res.sendFile(path.join(__dirname, '../src/index.html'));
});
app.post('/api/device-event', bodyParser.json(), function(req, res){
  console.log("posted");
  mqtt.handleDeviceEvent(req,res);
  res.end("yes");

});

// if (node_env === 'development') {
//   var devConfig = require('./localConfig.json')[node_env];
// 	proxy.setServiceConfig(config.buildVcapObjectFromLocalConfig(devConfig));
// 	proxy.setUaaConfig(devConfig);
// } else {
//   app.use(require('compression')()) // gzip compression
// }

// Session Storage Configuration:
// *** Using in memory session store for edge app, since we don't expect many concurrent users. **
const sessionOptions = {
  secret: 'edge-ref-app-secret',
  name: 'edge-ref-app-cookie', // give a custom name for your cookie here
  maxAge: 30 * 60 * 1000,  // expire token after 30 min.
  proxy: true,
  resave: true,
  saveUninitialized: true,
  cookie: {secure: true} // secure cookie is preferred, but not possible in some clouds.
};

// app.use(cookieParser('edge-ref-app-secret'));
// app.use(session(sessionOptions));
// app.use(bodyParser.json());
// app.use(bodyParser.urlencoded({ extended: false }));

/****************************************************************************
	SET UP EXPRESS ROUTES
*****************************************************************************/

// if (!config.isUaaConfigured()) {
//   // mock UAA routes
//   app.get(['/login', '/logout'], function(req, res) {
//     res.redirect('/');
//   })
//   app.get('/userinfo', function(req, res) {
//       res.send({user_name: 'Sample User'});
//   });
// } else {
//   //login route redirect to predix uaa login page
//   app.get('/login',passport.authenticate('predix', {'scope': ''}), function(req, res) {
//     // The request will be redirected to Predix for authentication, so this
//     // function will not be called.
//   });

//   // route to fetch user info from UAA for use in the browser
//   app.get('/userinfo', userInfo(config.uaaURL), function(req, res) {
//     res.send(req.user.details);
//   });

//   if (config.rmdDatasourceURL && config.rmdDatasourceURL.indexOf('https') === 0) {
//     app.get('/api/datagrid/*',
//         proxy.addClientTokenMiddleware,
//         proxy.customProxyMiddleware('/api/datagrid', config.rmdDatasourceURL, '/services/experience/datasource/datagrid'));
//   }
//   //Use this route to make the entire app secure.  This forces login for any path in the entire app.
//   // app.use('/', passport.authenticate('main', {
//   //     noredirect: false // Redirect the user to the authentication page
//   //   }),
//   //   express.static(path.join(__dirname, process.env['base-dir'] ? process.env['base-dir'] : '../public'))
//   // );

// }

/*******************************************************
SET UP MOCK API ROUTES
*******************************************************/
// NOTE: these routes are added after the real API routes.
//  So, if you have configured asset, the real asset API will be used, not the mock API.
// Import route modules
// var mockAssetRoutes = require('./routes/mock-asset.js')();
// var mockTimeSeriesRouter = require('./routes/mock-time-series.js');
// var mockRmdDatasourceRoutes = require('./routes/mock-rmd-datasource.js')();
// // add mock API routes.  (Remove these before deploying to production.)
// app.use(['/mock-api/predix-asset', '/api/predix-asset'], jsonServer.router(mockAssetRoutes));
// app.use(['/mock-api/predix-timeseries', '/api/predix-timeseries'], mockTimeSeriesRouter);
// app.use(['/mock-api/datagrid', '/api/datagrid'], jsonServer.router(mockRmdDatasourceRoutes));
// require('./routes/mock-live-data.js')(httpServer);
// ***** END MOCK ROUTES *****

//logout route
// app.get('/logout', function(req, res) {
// 	req.session.destroy();
// 	req.logout();
//   res.redirect(config.uaaURL + '/logout?redirect=' + config.appURL);
// });

app.get('/favicon.ico', function (req, res) {
	res.send('favicon.ico');
});

// app.get('/config', function(req, res) {
//   let title = "Predix WebApp Starter";
//   if (config.isAssetConfigured()) {
//     title = "RMD Reference App";
//   }
//   console.log();
//   res.send({wsUrl: config.websocketServerURL, appHeader: title, dataExchangeEnabled: config.isDataExchangeConfigured(),
//       timeSeriesOnly: config.timeSeriesOnly == "true" ? true : false});
// });

// Sample route middleware to ensure user is authenticated.
//   Use this route middleware on any resource that needs to be protected.  If
//   the request is authenticated (typically via a persistent login session),
//   the request will proceed.  Otherwise, the user will be redirected to the
//   login page.
//currently not being used as we are using passport-oauth2-middleware to check if
//token has expired
/*
function ensureAuthenticated(req, res, next) {
    if(req.isAuthenticated()) {
        return next();
    }
    res.redirect('/');
}
*/

////// error handlers //////
// catch 404 and forward to error handler
app.use(function(err, req, res, next) {
  console.error(err.stack);
	var err = new Error('Not Found');
	err.status = 404;
	next(err);
});

// development error handler - prints stacktrace
if (node_env === 'development') {
	app.use(function(err, req, res, next) {
		if (!res.headersSent) {
			res.status(err.status || 500);
			res.send({
				message: err.message,
				error: err
			});
		}
	});
}

// production error handler
// no stacktraces leaked to user
app.use(function(err, req, res, next) {
	if (!res.headersSent) {
		res.status(err.status || 500);
		res.send({
			message: err.message,
			error: {}
		});
	}
});

httpServer.listen(process.env.VCAP_APP_PORT || 5000, function () {
	console.log ('Server started on port: ' + httpServer.address().port);
});

module.exports = app;
