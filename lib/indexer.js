var general, options, db;

var fs = require('fs');

var readdir;
var metadata_indexers = {};

// Indexers pass found metadata to this function to update the db
var insert = function(path, metadata) {
	db.collection('tracks', function(err, tracks) {
		tracks.findOne({path: path}, function(error, track) {
			metadata.has_been_updated = true;
			metadata.last_update = new Date();
			metadata.path = path;
			if(track == null) {
				console.log("Inserting metadata:", metadata);
				tracks.insert(metadata)
			} else {
				for(field in metadata) {
					track[field] = metadata[field];
				}
				console.log("Updating track:", track);
				tracks.save(track);
			}
		});
		// tracks.insert()
	});
};

var get_indexer = function(name) {
	if(!metadata_indexers[name]) {
		metadata_indexers[name] = require('./metadata_indexers/'+name+'.js')(general, options, db);
	}
	return metadata_indexers[name];
};

readdir = function(dir, item_names) {
	item_names.forEach(function(item_name) {
		var item = dir+'/'+item_name;
		fs.stat(item, function(error, stat) {
			if(error) {
				console.log(error);
				return;
			}
			if(stat.isDirectory()) {
				var items = fs.readdirSync(item);
				readdir(item, items);
			} else if(stat.isFile()) {
				if(item_name.indexOf('.') < 1) { //Ignore dotfiles and those who don’t have an extension
					return;
				}
				var extension = item.split('.').slice(-1)[0];
				var indexer_name = options.types[extension];
				if(indexer_name) {
					var indexer = get_indexer(indexer_name);
					indexer.index(item, insert);
				}
			}
		});
	});
};

var index_task = function() {
	general.music_dirs.forEach(function(dir) {
		fs.realpath(dir, function(error, dir) {
			if(error) {
				console.log("Not indexing directory because of error", error);
				return;
			}
			console.log("Indexing directory "+dir);
			fs.readdir(dir, function(error, items) {
				readdir(dir, items);
			});
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
	index_task();
	setInterval(index_task, opts.interval*1000*60*60);
};