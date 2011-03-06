var layers = {
	music: require("./controllers/music.js"),
	votes: require("./controllers/votes.js"),
	users: require("./controllers/users.js"),
	playing: require("./controllers/playing.js")
};

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
				console.log("Registering route /"+layer_name+"/"+method_name+params);
				(function(layer_name, layer, method_name) {
					app.get("/"+layer_name+"/"+method_name+params, function(request, response, next) {
						var data = layer.methods[method_name](request, response, next);
						response.setHeader('Content-Type', 'application/json;charset=utf-8');
						response.end(JSON.stringify(data));
					});
				})(layer_name, layer, method_name);
			}
		}
	}
};