@import <AppKit/CPWindow.j>
@import <AppKit/CPWindowController.j>
@import <AppKit/CPTableView.j>
@import "Additions.j"
@import "TrackListController.j"

@implementation AlbumListController : CPWindowController {
  CPTableView albumView;
	AppController appController;
  int albumCount;
	CPDictionary storedAlbums;
	CPString artistName;
}

- (id)initWithAppController:(AppController)controller andArtistName:(CPString) name andFrame:(CGRect) frame {
	var theWindow = [[CPWindow alloc] initWithContentRect:frame styleMask:CPTitledWindowMask|CPClosableWindowMask|CPMiniaturizableWindowMask|CPResizableWindowMask];
	self = [super initWithWindow:theWindow];
	if (!self) {
		return nil;
	}
	var contentView = [theWindow contentView];
  appController = controller;
  artistName = name;
  storedAlbums = [[CPDictionary alloc] init];
	
	[theWindow setTitle:[[appController windowTitles] objectForKey:"Albums"]+(artistName ? " by "+artistName : "")];

  albumView = [self setUpTableViewWithFirstColumn:"Album"];

	return self;
}

- (int)numberOfRowsInTableView:(CPTableView)tableView {
  if(!albumCount) {
    var request = [CPURLRequest requestWithURL:"music/album_count"+(artistName ? "?artist_name="+encodeURIComponent(artistName) : "")];
    var jsObject = CPJSObjectCreateWithJSON([CPURLConnection sendSynchronousRequest:request returningResponse:nil error:nil].string);
    albumCount = jsObject.count;
  }
  return albumCount+(artistName ? 1 : 0);
}

- (id)tableView:(CPTableView)tableView objectValueForTableColumn:(CPTableColumn)tableColumn row:(int)row {
  if(artistName != nil) {
    row--;
  }
  if(row == -1) {
    return "All Tracks";
  }
  return [self albumNameByOffset:row];
}

- (CPString)albumNameByOffset:(int)offset {
  var storeLength = 20;
  var storedAlbumField = Math.floor(offset/storeLength);
  if([storedAlbums objectForKey:storedAlbumField] === null) {
    var request = [CPURLRequest requestWithURL:"music/albums?start="+storedAlbumField*storeLength+"&length="+storeLength+(artistName ? "&artist_name="+encodeURIComponent(artistName) : "")];
    var jsObject = CPJSObjectCreateWithJSON([CPURLConnection sendSynchronousRequest:request returningResponse:nil error:nil].string);
    [storedAlbums setObject:[CPArray arrayWithObjects:jsObject count:jsObject.length] forKey:storedAlbumField];
  }
  return [[storedAlbums objectForKey:storedAlbumField] objectAtIndex:offset%storeLength].track.album_name;
}

- (id)tableView:(CPTableView)tableView heightOfRow:(int)row {
    return 20.0;
}

//FIXME: code in respondToSelection: should actually be here, remove the ugly hack with selectionShouldChangeInTableView
- (void)tableViewSelectionDidChange:(CPNotification)aNotification {
}

- (void)respondToSelection {
  if(!albumView._selectedRowIndexes._ranges[0]) {
    return;
  }
  var row = albumView._selectedRowIndexes._ranges[0].location;
  //Remove selection
  [albumView deselectRow:row];
  [albumView setNeedsLayout];
  
  if(artistName != nil) {
    row--;
  }
  var albumName = null;
  if(row != -1) {
    albumName = [self albumNameByOffset:row];
  }
  var frame = [[self window] frame];
  frame.origin.x += frame.size.width+30;
  frame.origin.y += 26;
  frame.size.height -= 26;
  var title = "Tracks"+(artistName ? " by "+artistName : "")+(albumName ? " on "+albumName : "");
  var request = [CPURLRequest requestWithURL:"music/tracks?"+(artistName ? "&artist_name="+encodeURIComponent(artistName) : "")+(albumName ? "&album_name="+encodeURIComponent(albumName) : "")];
  var tracks = CPJSObjectCreateWithJSON([CPURLConnection sendSynchronousRequest:request returningResponse:nil error:nil].string);
  tracks = [CPArray arrayWithObjects:tracks count:tracks.length];
  var trackListWindow = [[TrackListController alloc] initWithAppController:appController andTracks:tracks andFrame:frame andTitle:title withVotesColumn:NO];
  [trackListWindow showWindow:self];
}

- (BOOL)selectionShouldChangeInTableView:(CPTableView)aTableView {
  window.setTimeout(function() {[self respondToSelection]}, 500);
	return YES;
}

@end