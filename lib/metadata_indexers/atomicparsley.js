var spawn = require('child_process').spawn;
var matcher = /Atom "(.{4})" contains: (.+)\n/g;

var parse_number = function(str) {
	var result = parseInt(str, 10);
	if(isNaN(result)) {
		return null;
	}
	return result;
};

module.exports = function(global, options) {
	var opts = options.indexers.atomicparsley || { executable: "AtomicParsley" };
	var executable = opts.executable;
	return {
		index: function(file, insert, error_handler) {
			var proc = {};
			try {
				proc = spawn(executable, [file, '-t']);
			} catch(e) {
				setTimeout(arguments.callee, 500*(Math.random()+1), file, insert);
				return;
			}
			var metadata = {};
			proc.stdout.on('data', function(data) {
				data = data.toString('utf-8');
				while(match = matcher.exec(data)) {
					if(match[1] === "©nam") {
						metadata.name = match[2];
					} else if(match[1] === "©ART") {
						metadata.artist = match[2];
					} else if(match[1] === "aART") {
						metadata.artist = match[2];
					} else if(match[1] === "©alb") {
						metadata.album = match[2];
					} else if(match[1] === "trkn") {
						metadata.tack_number = parse_number(match[2].match(/\d+/)[0]);
					} else if(match[1] === "©gen") {
						metadata.genre = match[2];
					} else if(match[1] === "©day") {
						metadata.year = parse_number(match[2]);
					}
				}
			});
			proc.on('exit', function(code, signal) {
				if(code !== 0) {
					return error_handler(file, signal);
				}
				insert(file, metadata);
			});
		}
	};
};