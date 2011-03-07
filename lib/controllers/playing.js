var general, options, db;

exports.config = function(gen, opt, d) {
	general = gen;
	options = opt;
	db = d;
};

exports.methods = {
	show: function(promise, request, response, next) {
		return {message: "Nothing playing"};
	}
};
