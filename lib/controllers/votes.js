var general, options, db;

var BSON = require('mongodb').BSONNative;

exports.config = function(gen, opt, d) {
	general = gen;
	options = opt;
	db = d;
};

exports.methods = {
	show: function(promise, request, response, next) {
		db.collection('votes', function(err, votes) {
			votes.count({user: BSON.ObjectID.createFromHexString(request.session.login)}, function(error, count) {
				promise({count: options.number_of_votes-count});
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
		db.collection('votes', function(err, votes) {
			votes.insert({user: BSON.ObjectID.createFromHexString(request.session.login), track: request.params.track_id}, function(error, count) {
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