var general, options, db;

exports.config = function(gen, opt, d) {
	general = gen;
	options = opt;
	db = d;
};

exports.methods = {
	artist_count: function(promise, request, response, next) {
		
	},
	
	artists: function(promise, request, response, next) {
		
	},
	
	album_count: function(promise, request, response, next) {
		
	},
	
	albums: function(promise, request, response, next) {
		
	},
	
	tracks: function(promise, request, response, next) {
		
	},
	
	next_tracks: function(promise, request, response, next) {
		
	}
};

exports.params = {
	artists: ['start', 'length'],
	album_count: ['artist'],
	albums: ['start', 'length'],
	tracks: ['start', 'length']
};

exports.needs_login = {
	next_tracks: true
};