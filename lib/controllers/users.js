var general, options, db;

exports.config = function(gen, opt, d) {
	general = gen;
	options = opt;
	db = d;
};

exports.methods = {
	login: function(request, response, next) {
		return {login: true};
	}
};

exports.params = {
	login: ['user_name']
};