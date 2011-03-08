var general, options, db;

exports.config = function(gen, opt, d) {
	general = gen;
	options = opt;
	db = d;
};

exports.methods = {
	artist_count: function(promise, request, response, next) {
		db.collection('tracks', function(err, tracks) {
			tracks.distinct('artist', function(error, artists) {
				promise({count: artists.length});
			});
		});
	},
	
	artists: function(promise, request, response, next) {
		var start = request.params.start;
		var length = request.params.length;
		db.collection('tracks', function(err, tracks) {
			tracks.distinct('artist', function(error, artists) {
				promise({artists: artists});
			});
			// tracks.find({is_playable: true}, {limit: length, skip: start, distinct: 'artist'}, function(error, artists) {
			// 	promise({artists: artists.items});
			// });
		});
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