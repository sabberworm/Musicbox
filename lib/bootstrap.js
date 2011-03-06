exports.run = function(settings) {
	var db = require('mongodb');
	var db_server = settings.general.db.host || 'localhost';
	var db_port = settings.general.db.port || db.Connection.DEFAULT_PORT;
	console.log('Connecting to '+ db_server + ' on port ' + db_port);
	var server = new db.Server(db_server, db_port);
	var database = new db.Db(settings.general.db.database, server, {native_parser: true});
	database.open(function(error, db) {
		console.log(error, db);
		if(!error);
		require('./server.js').run(settings.general, settings.webapp, db);
		require('./indexer.js').run(settings.general, settings.indexer, db);
		require('./player.js').run(settings.general, settings.player, db);
	});
};