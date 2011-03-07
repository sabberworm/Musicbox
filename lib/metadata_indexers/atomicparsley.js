var spawn = require('child_process').spawn;
var matcher = /Atom "(.{4})" contains: (.+)\n/g;
var spawn_count = 0;
module.exports = function(global, options, db) {
	var opts = options.indexers.atomicparsley || { executable: "AtomicParsley" };
	var executable = opts.executable;
	var max_spawn = 200/Object.keys(options.indexers).length;
	return {
		index: function(file) {
			if(spawn_count > max_spawn) {
				setTimeout(arguments.callee, 1000, file);
				return;
			}
			spawn_count++;
			var proc = spawn(executable, [file, '-t']);
			var metadata = {};
			proc.stdout.on('data', function(data) {
				data = data.toString('utf-8');
				while(match = matcher.exec(data)) {
					if(match[1] === "©nam") {
						metadata.name = match[2];
					}
					if(match[1] === "©ART") {
						metadata.artist = match[2];
					}
					if(match[1] === "aART") {
						metadata.artist = match[2];
					}
					if(match[1] === "©alb") {
						metadata.album = match[2];
					}
					if(match[1] === "trkn") {
						metadata.tack_number = parseInt(match[2].match(/\d+/)[0], 10);
					}
					if(match[1] === "©gen") {
						metadata.genre = match[2];
					}
					if(match[1] === "©day") {
						metadata.year = match[2];
					}
				}
			});
			proc.on('exit', function() {
				spawn_count--;
				console.log(metadata);
			});
		}
	};
};