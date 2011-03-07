var general, options, db;

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
	
	logout: function(promise, request, response, next) {
		var old = request.session.login;
		delete request.session.login;
		return {logout: old};
	}
};

exports.params = {
	login: ['user_name']
};
