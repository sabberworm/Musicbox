module.exports = function(level) {
	// level one of 'status', 'debug', 'info', 'error'
	var colorize = null;
	try {
		colorize = require("ansi-color").set;
	} catch (e) {}
	args = Array.prototype.slice.call(arguments, 1);
	if(colorize) {
		var color = null;
		if(level === 'error') {
			color = 'red';
		} else if (level === 'status') {
			color = 'underline';
		} else if (level === 'info') {
			color = 'green';
		}
		if(color) {
			args = [colorize(args.join(' '), color)]
		}
	} else {
		args.unshift('['+level.toUpperCase()+']');
	}
	console.log.apply(console, args)
};
