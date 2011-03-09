exports.run = function(general, options, db) {
	var connect = require('connect');
	var server = connect(
		connect.static(__dirname + "/../webapp_debug"),
		connect.static(__dirname + "/../webapp_release"),
		connect.static(__dirname + "/../webapp"),
		connect.cookieParser(),
		connect.session({secret: options.session_secret}),
		connect.router(require('./server_actions.js')(general, options, db))
	);
	server.listen(options.port || 80);
	console.log("Listening on port "+(options.port || 80));
};