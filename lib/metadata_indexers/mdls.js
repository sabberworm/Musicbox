var spawn = require('child_process').spawn;
var matcher = /("(.+)"|(\b(.+)\b))/;

module.exports = function(global, options) {
	var opts = options.indexers.mdls || {executable: "mdls"};
	var executable = opts.executable;

	var md_for_file = function(file, type, error_handler, callback) {
		var proc;
		try {
			proc = spawn(executable, ['-name', type, '-raw', file]);
		} catch(e) {
			setTimeout(arguments.callee, 1000*(Math.random()+1), file, type, callback);
			return;
		}
		var str = '';
		proc.stdout.on('data', function(data) {
			str += data.toString('utf-8');
		});
		proc.on('exit', function(code, signal) {
			if(code !== 0) {
				return error_handler(file, signal);
			}
			callback(str);
		});
	};

	return {
		index: function(file, insert, error_handler) {
			try {
				var metadata = {};
				md_for_file(file, 'kMDItemTitle', error_handler, function(md) {
					metadata.name = md;
					md_for_file(file, 'kMDItemAlbum', error_handler, function(md) {
						metadata.album = md;
						md_for_file(file, 'kMDItemAuthors', error_handler, function(md) {
							metadata.artist = md.match(matcher);
							if(metadata.artist) {
								metadata.artist = metadata.artist[2] || metadata.artist[3];
							}
							md_for_file(file, 'kMDItemAudioTrackNumber', error_handler, function(md) {
								metadata.track_number = parseInt(md, 10);
								md_for_file(file, 'kMDItemRecordingYear', error_handler, function(md) {
									metadata.year = parseInt(md, 10);
									md_for_file(file, 'kMDItemMusicalGenre', error_handler, function(md) {
										metadata.genre = md;
										insert(file, metadata);
									});
								});
							});
						});
					});
				});
			} catch (e) {
				error_handler(file, e);
			}
		}
	};
};