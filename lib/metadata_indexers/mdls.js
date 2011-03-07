var exec = require('child_process').exec;
var matcher = /("(.+)"|(\b(.+)\b))/;
module.exports = function(global, options, db) {
	var opts = options.indexers.mdls || { executable: "mdls" };
	var executable = opts.executable;
	return {
		index: function(file, insert) {
			try {
				var metadata = {};
				exec(executable+" -name 'kMDItemTitle' '-raw' '"+file+"'", function(error, stdout, stderr) {
					metadata.name = stdout.toString('utf-8');
					exec(executable+" -name 'kMDItemAlbum' '-raw' '"+file+"'", function(error, stdout, stderr) {
						metadata.album = stdout.toString('utf-8');
						exec(executable+" -name 'kMDItemAuthors' '-raw' '"+file+"'", function(error, stdout, stderr) {
							metadata.artist = stdout.toString('utf-8').match(matcher);
							if(metadata.artist) {
								metadata.artist = metadata.artist[2] || metadata.artist[3];
							}
							exec(executable+" -name 'kMDItemAudioTrackNumber' '-raw' '"+file+"'", function(error, stdout, stderr) {
								metadata.track_number = parseInt(stdout.toString('utf-8'));
								exec(executable+" -name 'kMDItemRecordingYear' '-raw' '"+file+"'", function(error, stdout, stderr) {
									metadata.year = parseInt(stdout.toString('utf-8'));
									exec(executable+" -name 'kMDItemMusicalGenre' '-raw' '"+file+"'", function(error, stdout, stderr) {
										metadata.genre = stdout.toString('utf-8');
										insert(file, metadata);
									});
								});
							});
						});
					});
				});
			} catch(e) {
				setTimeout(arguments.callee, 1000, file);
				return;
			}
		}
	};
};