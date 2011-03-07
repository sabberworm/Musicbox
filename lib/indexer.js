var general, options, db;

var fs = require('fs');

var readdir;
var metadata_indexers = {};

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
				var items = fs.readdirSync(item)
				readdir(item, items);
			} else if(stat.isFile()) {
				if(item_name.indexOf('.') < 1) { //Ignore dotfiles and those who don’t have an extension
					return;
				}
				var extension = item.split('.').slice(-1)[0];
				var indexer_name = options.types[extension];
				if(indexer_name) {
					var indexer = get_indexer(indexer_name);
					indexer.index(item);
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
	general = gen;
	options = opts;
	db = d;
	index_task();
};