var fs = require('fs'),
		sys = require('sys'),
		yaml = require('yaml')
		log = require('./lib/log.js');

fs.readFile('./config/config.yaml', function(err, data) {
	var settings = {};
	if (err) {
		log('error', 'No settings.json found ('+err+'). Aborting');
		process.exit(1);
	} else {
		try {
			settings = yaml.eval(data.toString('utf8',0,data.length));
			log('info', "Starting Musicbox with settings ", settings);
		} catch (e) {
			log('error', 'Error parsing config.yaml: '+e);
			process.exit(1);
		}
		var bootstrap = require('./lib/bootstrap.js');
		bootstrap.run(settings);
	}
});
