Musicbox
--------------

Cappuccino Web-app that lets users vote on tracks to listen to and automatically spawns raop_play with the next top-voted track.

Currently consists of two Tcl/Expect scripts, the first of which periodically indexes the music files in a given folder while the second gets the current top-voted track and spawns raop_play.
The web interface is Cappuccino with a Rails backend.
All of these things keep their data in a MySQL database.

## TODO

### Node.js
The plan is to combine the Expect scripts as well as the Rails-Backend into one Node.js app.

### Cappuccino
Also, the Cappuccino version used is incredibly outdated and, in fact, I used the unfinished CPTableView class from an unstable branch. Bump to 0.9 and use CPBrowser for the song browser.

### Player
In addition to roap_play (which has not been updated in quite a while), other backends should be configurable: JustePort, Airfoil (via osascript), etc.

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
