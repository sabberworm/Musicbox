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
		var start = parseInt(request.params.start, 10);
		var length = parseInt(request.params.length, 10);
		db.collection('tracks', function(err, tracks) {
			tracks.distinct('artist', {is_playable: true, 'artist': {'$ne': null}}, function(error, artists) {
				promise({artists: artists.slice(start, start+length)});
			});
		});
	},
	
	album_count: function(promise, request, response, next) {
		var artist = request.query.artist_name;
		db.collection('tracks', function(err, tracks) {
			var query = {is_playable: true};
			if(artist) {
				query['artist'] = artist;
			}
			tracks.distinct('album', query, function(error, albums) {
				promise({count: albums.length});
			});
		});
	},
	
	albums: function(promise, request, response, next) {
		var start = parseInt(request.params.start, 10);
		var length = parseInt(request.params.length, 10);
		var artist = request.query.artist_name;
		db.collection('tracks', function(err, tracks) {
			var query = {is_playable: true};
			if(artist) {
				query['artist'] = artist;
			}
			tracks.distinct('album', query, function(error, albums) {
				promise({albums: albums.slice(start, start+length)});
			});
		});
	},
	
	tracks: function(promise, request, response, next) {
		var artist = request.query.artist_name;
		var album = request.query.album_name;
		db.collection('tracks', function(err, tracks) {
			var query = {is_playable: true};
			if(artist) {
				query['artist'] = artist;
			}
			if(album) {
				query['album'] = album;
			}
			tracks.find(query, function(error, cursor) {
				cursor.toArray(function(error, albums) {
					promise({tracks: albums});
				});
			});
		});
	},
	
	next_tracks: function(promise, request, response, next) {
		db.collection('tracks', function(err, votes) {
			votes.find({is_playable: true, 'votes.length': {'$gt': 0}}, {sort: ['is_playing', 'votes.length', 'last_played', '_id']}, function(error, cursor) {
				cursor.toArray(function(error, tracks) {
					promise({tracks: tracks});
				});
			});
		});
    // @tracks = Track.find(:all, :select => "*, sum(votes.vote_count) AS vote_count", :joins => "JOIN votes ON tracks.id=votes.track_id", :group => "tracks.id", :order => 'is_playing DESC, vote_count DESC, last_played ASC, tracks.id ASC')
	}
};

exports.params = {
	artists: ['start', 'length'],
	albums: ['start', 'length']
};

exports.needs_login = {
	next_tracks: true
};