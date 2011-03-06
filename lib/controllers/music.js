var general, options, db;

exports.config = function(gen, opt, d) {
	general = gen;
	options = opt;
	db = d;
};

exports.methods = {
	artist_count: function(request, response, next) {
		
	},
	
	artists: function(request, response, next) {
		
	},
	
	album_count: function(request, response, next) {
		
	},
	
	albums: function(request, response, next) {
		
	},
	
	tracks: function(request, response, next) {
		
	},
	
	next_tracks: function(request, response, next) {
		
	}
};

exports.params = {
	artists: ['start', 'length'],
	album_count: ['artist'],
	albums: ['start', 'length'],
	tracks: ['start', 'length']
};