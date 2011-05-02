exports.run = function(general, options, db) {
	var engine_name = options.engine;
	
	var controller = {
		find_next_song: function() {
			
		},
		
		mark_played: function(song) {
			
		},
		
		mark_unplayable: function(song) {
			
		}
	};
	
	var engine = require('./players/'+engine_name+'.js');
	console.log('Starting player', engine_name);
	engine.run(options, controller);
};