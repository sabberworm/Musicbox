var spawn = require('child_process').spawn;
var matcher = /([A-Z]+)=(.+)\n/g;

module.exports = function(global, options, db) {
	var opts = options.indexers.vorbiscomment || { executable: "vorbiscomment" };
	var executable = opts.executable;
	return {
		index: function(file, insert, error_handler) {
			var proc = {};
			try {
				proc = spawn(executable, ['-l', '-R', file]);
			} catch(e) {
				setTimeout(arguments.callee, 1000, file, insert);
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
						metadata.tack_number = parseInt(match[2], 10);
					} else if(match[1] === "GENRE") {
						metadata.genre = match[2];
					} else if(match[1] === "DATE") {
						metadata.year = parseInt(match[2], 10);
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