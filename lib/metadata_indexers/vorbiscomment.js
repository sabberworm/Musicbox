var spawn = require('child_process').spawn;
var matcher = /([A-Z]+)=(.+)\n/g;

var parse_number = function(str) {
	var result = parseInt(str, 10);
	if(isNaN(result)) {
		return null;
	}
	return result;
};

module.exports = function(global, options) {
	var opts = options.indexers.vorbiscomment || { executable: "vorbiscomment" };
	var executable = opts.executable;
	return {
		index: function(file, insert, error_handler) {
			var proc = {};
			try {
				proc = spawn(executable, ['-l', '-R', file]);
			} catch(e) {
				setTimeout(arguments.callee, 250*(Math.random()+1), file, insert);
				return;
			}
			var metadata = {};
			proc.stdout.on('data', function(data) {
				data = data.toString('utf-8');
				while(match = matcher.exec(data)) {
					if(match[1] === "TITLE") {
						metadata.name = match[2];
					} else if(match[1] === "ARTIST") {
						metadata.artist = match[2];
					} else if(match[1] === "ALBUM") {
						metadata.album = match[2];
					} else if(match[1] === "TRACKNUMBER") {
						metadata.tack_number = parse_number(match[2]);
					} else if(match[1] === "GENRE") {
						metadata.genre = match[2];
					} else if(match[1] === "DATE") {
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