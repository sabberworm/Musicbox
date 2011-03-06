var fs = require('fs'),
    sys = require('sys'),
    yaml = require('yaml');

fs.readFile('./config/config.yaml', function(err, data) {
	var settings = {};
	if (err) {
		sys.puts('No settings.json found ('+err+'). Using default settings');
	} else {
		try {
			settings = yaml.eval(data.toString('utf8',0,data.length));
			console.log("Starting Musicbox with settings ", settings);
		} catch (e) {
			sys.puts('Error parsing config.yaml: '+e);
			process.exit(1);
		}
		var bootstrap = require('./lib/bootstrap.js');
		bootstrap.run(settings);
	}
});
