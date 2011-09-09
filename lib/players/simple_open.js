var controller;

function play_track(track) {
	console.log("playing track", track);
	setTimeout(function() {
		controller.mark_played(track);
		controller.find_next_track(play_track);
	}, 60000);
}

// The null player – does nothing
exports.run = function(options, ctrl) {
	controller = ctrl;
	controller.find_next_track(play_track);
};