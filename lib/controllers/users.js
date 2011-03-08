var general, options, db;

var BSON = require('mongodb').BSONNative;

exports.config = function(gen, opt, d) {
	general = gen;
	options = opt;
	db = d;
};

exports.methods = {
	login: function(promise, request, response, next) {
		if(request.session.login) {
			return {login: 'already '+request.session.login};
		}
		db.collection('users', function(err, users) {
			users.findOne({name: request.params.user_name}, function(error, user) {
				if(user) {
					request.session.login = user._id;
					promise({login: true});
				} else {
					user = {name: request.params.user_name};
					users.insert(user, function(error, userFromDB) {
						console.log('Inserted user', userFromDB);
						request.session.login = userFromDB._id;
						promise({login: true});
					});
				}
			});
		});
	},
	
	test: function(promise, request, response, next) {
		if(request.session.login) {
			db.collection('users', function(err, users) {
				users.findOne({_id: BSON.ObjectID.createFromHexString(request.session.login)}, function(error, user) {
					if(!user) {
						delete request.session.login;
						promise({login: false});
					} else {
						promise({login: user.name});
					}
				});
			});
		} else {
			return {login: false};
		}
	},
	
	logout: function(promise, request, response, next) {
		var old = request.session.login;
		delete request.session.login;
		return {logout: old};
	}
};

exports.params = {
	login: ['user_name']
};
