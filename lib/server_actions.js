var layers = {
	music: require("./controllers/music.js"),
	votes: require("./controllers/votes.js"),
	users: require("./controllers/users.js"),
	playing: require("./controllers/playing.js")
};

var url_parse = require('url').parse;

module.exports = function(general, options, db) {
	return function(app) {
		for(layer_name in layers) {
			var layer = layers[layer_name];
			layer.config(general, options, db);
			for(method_name in layer.methods) {
				var params = "";
				if(layer.params && layer.params[method_name]) {
					params = "/:"+layer.params[method_name].join('/:');
				}
				var needs_login = layer.needs_login && (layer.needs_login === true || layer.needs_login[method_name]);
				console.log("Registering route /"+layer_name+"/"+method_name+params);
				(function(layer_name, layer, method_name, needs_login) {
					app.get("/"+layer_name+"/"+method_name+params, function(request, response, next) {
						request.query = url_parse(request.url, true).query;
						var promise = function(data) {
							response.setHeader('Content-Type', 'application/json;charset=utf-8');
							response.end(JSON.stringify(data));
						};
						if(needs_login && !request.session.login) {
							promise({error: 'needs login'});
							return;
						}
						//The method needs to either call promise or return something that can be json-ified
						var data = layer.methods[method_name](promise, request, response, next);
						if(data) {
							promise(data);
						}
					});
				})(layer_name, layer, method_name, needs_login);
			}
		}
	}
};