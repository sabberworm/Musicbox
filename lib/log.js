// ANSI color code outputs for strings

var ANSI_CODES = {
  "off": 0,
  "bold": 1,
  "italic": 3,
  "underline": 4,
  "blink": 5,
  "inverse": 7,
  "hidden": 8,
  "black": 30,
  "red": 31,
  "green": 32,
  "yellow": 33,
  "blue": 34,
  "magenta": 35,
  "cyan": 36,
  "white": 37,
  "black_bg": 40,
  "red_bg": 41,
  "green_bg": 42,
  "yellow_bg": 43,
  "blue_bg": 44,
  "magenta_bg": 45,
  "cyan_bg": 46,
  "white_bg": 47
};

var begin_color = function(color) {
  if(!color) return str;

  var color_attrs = color.split("+");
  var ansi_str = "";
  for(var i=0, attr; attr = color_attrs[i]; i++) {
    ansi_str += "\033[" + ANSI_CODES[attr] + "m";
  }
  return ansi_str;
};

var end_color = function() {
	return "\033[" + ANSI_CODES["off"] + "m";
}

module.exports = function(level) {
	// level one of 'status', 'debug', 'info', 'error'
	var colorize = null;
	try {
		colorize = require("ansi-color").set;
	} catch (e) {}
	args = Array.prototype.slice.call(arguments, 1);
	if(process.env.TERM && process.env.TERM.match(/color$/)) {
		var color = null;
		if(level === 'error') {
			color = 'red';
		} else if (level === 'status') {
			color = 'underline';
		} else if (level === 'info') {
			color = 'green';
		}
		if(color) {
			args.unshift(begin_color(color));
			args.push(end_color());
		}
	} else {
		args.unshift('['+level.toUpperCase()+']');
	}
	console.log.apply(console, args)
};
