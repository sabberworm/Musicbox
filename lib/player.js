exports.run = function(general, options, db) {
	var player_opts = options.player;
	var engine_name = player_opts.engine;
	
	var controller = {
		find_next_song: function() {
			
		},
		
		mark_played: function(song) {
			
		},
		
		mark_unplayable: function(song) {
			
		}
	};
	
	var engine = require('./players/'+engine_name+'.js');
	engine.run(player_opts, controller);
};