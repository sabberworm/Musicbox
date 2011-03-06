exports.run = function(settings) {
	var db = require('mongodb');
	var db_server = settings.general.db.host || 'localhost';
	var db_port = settings.general.db.port || db.Connection.DEFAULT_PORT;
	var server = new db.Server(db_server, db_port);
	var database = new db.Db(settings.general.db.database, server, {native_parser: true});
	database.open(function(error, db) {
		if(error) {
			sys.puts('Error connecting to database: '+error);
			process.exit(1);
		}
		console.log('Connected to db on '+ db_server + ':' + db_port);
		require('./server.js').run(settings.general, settings.webapp, db);
		require('./indexer.js').run(settings.general, settings.indexer, db);
		require('./player.js').run(settings.general, settings.player, db);
	});
};