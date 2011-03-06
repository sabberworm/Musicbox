Cappuccino Web-app that lets users vote on tracks to listen to and automatically spawns raop_play with the next top-voted track.
--------------

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
