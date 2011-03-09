Musicbox
--------------

Cappuccino Web-app with a node.js backend that lets users vote on tracks to listen to and automatically spawns raop_play (or another streaming player) with the next top-voted track.

## Requirements
- node.js
- npm packages
	- connect
	- yaml
	- mongodb
	- finder
- One of the supported players:
	- raop_play (needs faad for aac, mpg321 for mp3, vorbis-tools for ogg)
		- libssl
		- libssl-dev
		- libfltk1.1-dev
		- libfltk1.1c102
		- fluid,libglib2.0-dev
		- libsamplerate0
		- libsamplerate0-dev
		- libid3tag0
		- libid3tag0-dev
	- JustePort
	- Airfoil
- Metadata parser
	- AtomicParsley for mp4
	- mdls for mp4 or mp3
	- vorbis-tools for ogg


## Running

Clone or download Musicbox and `cd` to it.

    mv config/config.example.yaml config/config.yaml
    vi config/config.yaml
    node musicbox.js

Open [http://localhost:8080](http://localhost:8080) (or whatever port you configured).

## TODO

### Web-App

- Use CPBrowser for the song browser.
- Username in Session w/o login if cookie still valid
- Error handling if response is not JSON should be more graceful
- When creating votes, the voting date has to be stored to be used when ordering with MIN()

### Player
In addition to roap_play (which has not been updated in quite a while), other backends should be configurable: JustePort, Airfoil (via osascript), etc.

## Known issues

- With raop_play
	- Playback sometimes stops shortly before the track ends ~10 seconds
	- Some MP3 files play at an extremely slow rate. Most likely mpg321’s fault. Filter those files or update to a working version.

## License
Except for the icons, which I had to buy, Musicbox is freely distributable under the terms of an MIT-style license.

Copyright (c) 2011 Raphael Schweikert, http://sabberworm.com/

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
