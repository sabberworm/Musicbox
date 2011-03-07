var general, options, db;

exports.config = function(gen, opt, d) {
	general = gen;
	options = opt;
	db = d;
};

exports.methods = {
	show: function(promise, request, response, next) {
		
	},
	
	reset: function(promise, request, response, next) {
		
	},
	
	add: function(promise, request, response, next) {
		
	}
};

exports.params = {
	add: ['track_id']
};

exports.needs_login = true;