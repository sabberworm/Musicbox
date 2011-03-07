exports.run = function(general, options, db) {
	var connect = require('connect');
	var server = connect(
		connect.cookieParser(),
		connect.session({secret: options.session_secret}),
		connect.static(__dirname + "/../webapp"),
		connect.router(require('./server_actions.js')(general, options, db))
	);
	server.listen(options.port || 80);
	console.log("Listening on port "+(options.port || 80));
};