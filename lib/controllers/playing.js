var general, options, db;

exports.config = function(gen, opt, d) {
	general = gen;
	options = opt;
	db = d;
};

exports.methods = {
	show: function(promise, request, response, next) {
		db.collection('tracks', function(err, tracks) {
			tracks.findOne({is_playing: true}, function(error, track) {
				if(!track) {
					promise({message: "Nothing playing"});
					return;
				}
				promise({track: track});
			});
		});
	}
};
