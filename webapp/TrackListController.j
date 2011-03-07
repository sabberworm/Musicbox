@import <AppKit/CPWindow.j>
@import <AppKit/CPWindowController.j>
@import <AppKit/CPTableView.j>
@import "Additions.j"

@implementation TrackListController : CPWindowController {
  CPTableView trackView;
	AppController appController;
	CPArray trackList @accessors;
  CPImage isPlayingImage;
  CPImage voteImage;
}

- (id)initWithAppController:(AppController)controller andTracks:(CPArray)tracks andFrame:(CGRect)frame andTitle:(CPString)title withVotesColumn:(BOOL)hasVotesColumn {
	var theWindow = [[CPWindow alloc] initWithContentRect:frame styleMask:CPTitledWindowMask|CPClosableWindowMask|CPMiniaturizableWindowMask|CPResizableWindowMask];
	self = [super initWithWindow:theWindow];
	if (!self) {
		return nil;
	}
	var contentView = [theWindow contentView];
  appController = controller;
  trackList = tracks;
	
	[theWindow setTitle:title];

  trackView = [self setUpTableViewWithFirstColumn:"Track"];
  [trackView setAllowsColumnResizing:YES];
  
	var iconView = [[CPImageView alloc] initWithFrame:CGRectMake(16,16,0,0)];
  var iconColumn = [[CPTableColumn alloc] initWithIdentifier:"actions"];
  
  [iconColumn setWidth:18];
  [iconColumn setDataView:iconView];
  [trackView addTableColumn:iconColumn];
  [[[trackView tableColumns] objectAtIndex:0] setWidth:[trackView bounds].size.width-18];
  
  if(hasVotesColumn) {
    var votesColumn = [[CPTableColumn alloc] initWithIdentifier:"votes"];
    [votesColumn setWidth:20];
    [trackView addTableColumn:votesColumn];
  }

  var trackNumberColumn = [[CPTableColumn alloc] initWithIdentifier:"track_number"];
  [trackNumberColumn setWidth:20];
  [trackView addTableColumn:trackNumberColumn];

  var artistColumn = [[CPTableColumn alloc] initWithIdentifier:"artist"];
  [artistColumn setWidth:[trackView bounds].size.width];
  [trackView addTableColumn:artistColumn];

  var albumColumn = [[CPTableColumn alloc] initWithIdentifier:"album"];
  [albumColumn setWidth:[trackView bounds].size.width];
  [trackView addTableColumn:albumColumn];
  
	var mainBundle = [CPBundle mainBundle];
  isPlayingImage = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:"IsPlaying.png"] size:CPSizeMake(16, 16)];
	voteImage = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:"VoteAdd.png"] size:CPSizeMake(16, 16)];
	
  [trackView tile];
  
  return self;
}

- (int)numberOfRowsInTableView:(CPTableView)tableView {
  return [trackList count];
}

- (id)tableView:(CPTableView)tableView objectValueForTableColumn:(CPTableColumn)tableColumn row:(int)row {
  var track = [self trackByOffset:row];
  if ([tableColumn identifier] == "actions") {
    return track.is_playing ? isPlayingImage : voteImage;
  }
  if ([tableColumn identifier] == "votes") {
    return track.vote_count;
  }
  if ([tableColumn identifier] == "track_number") {
    return track.track_number;
  }
  if ([tableColumn identifier] == "artist") {
    return track.artist_name;
  }
  if ([tableColumn identifier] == "album") {
    return track.album_name;
  }
  return track.track_name;
}

- (CPString)trackByOffset:(int)offset {
  return [trackList objectAtIndex:offset].track;
}

- (id)tableView:(CPTableView)tableView heightOfRow:(int)row {
    return 16.0;
}

- (void)updateList {
  [trackView reloadData];
}

-(void)connection:(CPURLConnection)connection didReceiveData:(CPString)data {
	var jsObject = [data objectFromJSON];
	trackList = jsObject;
	[self updateList];
}

//FIXME: code in respondToSelection: should actually be here, remove the ugly hack with selectionShouldChangeInTableView
- (void)tableViewSelectionDidChange:(CPNotification)aNotification {
}

- (void)respondToSelection {
  if(!trackView._selectedRowIndexes._ranges[0]) {
    return;
  }
  var row = trackView._selectedRowIndexes._ranges[0].location;
  //Remove selection
  [trackView deselectRow:row];
  [trackView setNeedsLayout];
	var request = [CPURLRequest requestWithURL:"my_votes/add?user_name="+[appController userName]+"&track_id="+[self trackByOffset:row].id];
  var vote_success = [CPURLConnection sendSynchronousRequest:request returningResponse:nil error:nil].JSONObject().added;
  if(vote_success) {
    [appController updateVotesAndTopTracks];
  }
}

- (BOOL)selectionShouldChangeInTableView:(CPTableView)aTableView {
  window.setTimeout(function() {[self respondToSelection]}, 500);
	return YES;
}

@end