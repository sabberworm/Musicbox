var general, options, db, tracks;

var fs = require('fs');
var fnd = require('finder');
var Finder = fnd.Finder;
var NameList = fnd.NameList;

var dirs = [];
var extensions = [];
var finder = new Finder().type(Finder.FILE);

var metadata_indexers = {};

var running_indexers = 0;
var max_indexers = 20;

var items_to_tag = 0;
var items_tagged = 0;
var items_error = 0;

var index_task;

var finalize = function() {
	// Remove all old entries (the ones that have not been updated since the last index)
	tracks.remove({has_been_updated: false}, function(error) {
		if(error) {
			console.log("Error when removing old items", error);
		}
		console.log("Removed unupdated items");
		tracks.update({has_been_updated: true}, {"$set": {has_been_updated: false}}, {multi: true}, function(error) {
			if(error) {
				console.log("Error when setting has_been_updated to false", error);
			}
			console.log("Finished indexer run, tagged", items_tagged, "items with", items_error, "errors");
			items_tagged = 0;
			items_error = 0;
			setTimeout(index_task, options.interval*1000*60*60);
		});
	});
};

var ran_indexer = function() {
	running_indexers--;
	items_to_tag--;
	items_tagged++;
	if(items_to_tag === 0) {
		finalize();
	}
};

var indexer_error = function(path, error) {
	console.log("Indexer error", error, "for file", path);
	items_error++;
	ran_indexer();
};

// Indexers pass found metadata to this function to update the db
var insert = function(path, metadata) {
	tracks.findOne({path: path}, function(error, track) {
		metadata.has_been_updated = true;
		metadata.last_update = new Date();
		metadata.path = path;
		if(track == null) {
			metadata.is_playable = true; // New tracks are always playable. When it is first being played, the player will set is_playable to false for this track
			metadata.is_playing = false;
			console.log("Inserting metadata:", metadata.name);
			tracks.insert(metadata);
		} else {
			var has_updated = false;
			for(var field in metadata) {
				if(track[field] !== metadata[field]) {
					track[field] = metadata[field];
					has_updated = has_updated || (field !== 'has_been_updated' && field !== 'last_update');
				}
			}
			if(has_updated) {
				console.log("Updating track:", track.name);
			}
			tracks.save(track);
		}
		ran_indexer();
	});
};

var get_indexer = function(name) {
	if(!metadata_indexers[name]) {
		metadata_indexers[name] = require('./metadata_indexers/'+name+'.js')(general, options, db);
	}
	return metadata_indexers[name];
};

index_task = function() {
	finder.fetch(dirs, function(error, files) {
		console.log("Started indexer, tagging", files.length, "items");
		items_to_tag = files.length;
		files.forEach(function(file) {
			if(running_indexers > max_indexers) {
				setTimeout(arguments.callee, 200*(Math.random()+1), file);
				return;
			}
			var extension = file.split('.').slice(-1)[0];
			var indexer_name = options.types[extension];
			if(indexer_name) {
				var indexer = get_indexer(indexer_name);
				indexer.index(file, insert, indexer_error);
				running_indexers++;
			}
		});
	});
};

exports.run = function(gen, opts, d) {
	if(!opts.interval) {
		return;
	}
	general = gen;
	options = opts;
	db = d;
	
	db.collection('tracks', function(error, trk) {
		tracks = trk;
		
		general.music_dirs.forEach(function(dir) {
			dir = fs.realpathSync(dir);
			dirs.push(dir);
		});
		
		var extList = new NameList(NameList.MODE_ANY);
		for(var extension in options.types) {
			extList.addNames("*."+extension);
		}
		finder.names(extList);
	
		index_task();
	});
	
};