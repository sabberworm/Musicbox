exports.run = function(general, options, db) {
	var engine_name = options.engine;
	
	var remove_votes = function(track) {
		// DELETE FROM votes WHERE track_id = $track_id;
	};
	
	var controller = {
		find_next_song: function() {
			// Select song to play
			// SELECT * FROM votes JOIN tracks ON tracks.id=votes.track_id WHERE is_unplayable = 0 AND (last_played IS NULL OR last_played < DATE_SUB(NOW(), INTERVAL $song_play_block_interval HOUR)) GROUP BY tracks.id ORDER BY vote_count DESC, last_played ASC, tracks.id ASC LIMIT 1;
			// UPDATE tracks SET is_playing = 1 WHERE id = $track_id;
		},
		
		mark_played: function(track) {
			remove_votes(track);
			// UPDATE tracks SET last_played = NOW() WHERE id = $track_id;
			// UPDATE tracks SET is_playing = 0 WHERE id = $track_id;
		},
		
		mark_unplayable: function(track) {
			remove_votes(track);
			// UPDATE tracks SET is_unplayable = 1 WHERE id = $track_id;
		},
		
		mark_deleted: function(track) {
			remove_votes(track);
			// DELETE FROM tracks WHERE id = $track_id;
		}
	};
	
	var engine = require('./players/'+engine_name+'.js');
	console.log('Starting player', engine_name);
	engine.run(options, controller);
};