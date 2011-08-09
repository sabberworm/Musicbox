var general, options, db;

var BSON = require('mongodb').BSONNative;

exports.config = function(gen, opt, d) {
	general = gen;
	options = opt;
	db = d;
};

exports.methods = {
	show: function(promise, request, response, next) {
		var user_id = BSON.ObjectID.createFromHexString(request.session.login);
		
		db.collection('tracks', function(err, tracks) {
			tracks.find({votes: {"$elemMatch": {user: user_id}}}, function(error, tracks) {
				var result = 0;
				tracks.each(function(error, track) {
					if(!track) {
						return promise({count: options.number_of_votes-result});
					}
					track.votes.forEach(function(vote) {
						if(vote.user.equals(user_id)) {
							result++;
						}
					});
				});
			});
		});
	},
	
	reset: function(promise, request, response, next) {
		db.collection('votes', function(err, votes) {
			votes.remove({user: BSON.ObjectID.createFromHexString(request.session.login)}, function(error, count) {
				promise({reset: true});
			});
		});
	},
	
	add: function(promise, request, response, next) {
		var user_id = BSON.ObjectID.createFromHexString(request.session.login);
		var track_id = BSON.ObjectID.createFromHexString(request.params.track_id);
		var upsert = {"$push": {votes: {user: user_id}}};
		
		db.collection('tracks', function(err, tracks) {
			tracks.update({_id: track_id}, upsert, {upsert: true}, function(error, track) {
				if(error) {
					promise({error: error});
				}
				promise({success: true});
			});
		});
	}
};

exports.params = {
	add: ['track_id']
};

exports.needs_login = true;