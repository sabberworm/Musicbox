@import <AppKit/CPWindow.j>
@import <AppKit/CPWindowController.j>
@import <AppKit/CPTableView.j>
@import <AppKit/CPTableColumn.j>
@import <AppKit/CPScrollView.j>
@import "Additions.j"
@import "MainToolbarDelegate.j"
@import "AlbumListController.j"

@implementation MusicListController : CPWindowController {
	CPTableView artistView;
	AppController appController;
	int artistCount;
	CPDictionary storedArtists;
}

- (id)initWithAppController:(AppController)controller {
	var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMake(340, 130, 280, 400) styleMask:CPTitledWindowMask|CPClosableWindowMask|CPMiniaturizableWindowMask|CPResizableWindowMask];
	self = [super initWithWindow:theWindow];
	if (!self) {
		return nil;
	}
	var contentView = [theWindow contentView];
	appController = controller;
	storedArtists = [[CPMutableDictionary alloc] init];
	
	[theWindow setTitle:[[appController windowTitles] objectForKey:"AllMusic"]];
		
	artistView = [self setUpTableViewWithFirstColumn:"Artist"];

	return self;
}

- (int)numberOfRowsInTableView:(CPTableView)tableView {
	if(!artistCount) {
		var request = [CPURLRequest requestWithURL:"music/artist_count"];
		var jsObject = [CPURLConnection sendSynchronousRequest:request returningResponse:nil].JSONObject();
		artistCount = jsObject.count;
	}
	return artistCount+1;
}

- (id)tableView:(CPTableView)tableView objectValueForTableColumn:(CPTableColumn)tableColumn row:(int)row {
	row--;
	if(row == -1) {
		return "All Artists";
	}
	return [self artistNameByOffset:row];
}

- (CPString)artistNameByOffset:(int)offset {
	var storeLength = 20;
	var storedArtistField = Math.floor(offset/storeLength);
	if(![storedArtists objectForKey:storedArtistField]) {
		var request = [CPURLRequest requestWithURL:"music/artists/"+storedArtistField*storeLength+"/"+storeLength];
		var jsObject = [CPURLConnection sendSynchronousRequest:request returningResponse:nil].JSONObject();
		[storedArtists setObject:[CPArray arrayWithObjects:jsObject.artists count:jsObject.artists.length] forKey:storedArtistField];
	}
	return [[storedArtists objectForKey:storedArtistField] objectAtIndex:offset%storeLength];
}

- (id)tableView:(CPTableView)tableView heightOfRow:(int)row {
		return 20.0;
}

//FIXME: code in respondToSelection: should actually be here, remove the ugly hack with selectionShouldChangeInTableView
- (void)tableViewSelectionDidChange:(CPNotification)aNotification {
}

- (void)respondToSelection {
	if(!artistView._selectedRowIndexes._ranges[0]) {
		return;
	}
	var row = artistView._selectedRowIndexes._ranges[0].location;
	//Remove selection
	[artistView deselectRow:row];
	[artistView setNeedsLayout];
	
	var artistName = null;
	if(row != 0) {
		row--;
		artistName = [self artistNameByOffset:row];
	}
	var frame = [[self window] frame];
	frame.origin.x += frame.size.width+30;
	frame.origin.y += 26;
	frame.size.height -= 26;
	var albumList = [[AlbumListController alloc] initWithAppController:appController andArtistName:artistName andFrame:frame];
	[albumList showWindow:self];
}

- (BOOL)selectionShouldChangeInTableView:(CPTableView)aTableView {
	window.setTimeout(function() {[self respondToSelection]}, 500);
	return YES;
}


@end