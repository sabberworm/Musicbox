@import <AppKit/CPPanel.j>
@import <AppKit/CPWindowController.j>
@import "Additions.j"

@implementation NowPlayingView : CPWindowController {
	CPTextField trackText;
	CPTextField artistText;
	CPTextField albumText;
	CPTextField yearText;
	int prevTrackId;
	AppController appController;
}

- (id)initWithAppController:(AppController)controller {
	var theWindow = [[CPPanel alloc] initWithContentRect:CGRectMake(10, 300, 300, 160) styleMask:CPHUDBackgroundWindowMask|CPClosableWindowMask];
	self = [super initWithWindow:theWindow];
	if (!self) {
		return nil;
	}
	var contentView = [theWindow contentView];
	appController = controller;
	prevTrackId = null;
	
	[theWindow setTitle:[[appController windowTitles] objectForKey:"NowPlaying"]];
	[theWindow setFloatingPanel:YES];

	var leftDistance = 5;
	var topDistance = 30;
	var verticalDistance = 5;
	
	var trackLabel = [CPTextField hudLabelWithTitle:"Track:"];
	verticalDistance += [trackLabel frame].size.height;
	leftDistance += [trackLabel frame].size.width;

	[trackLabel setFrameOrigin:CGPointMake(leftDistance, topDistance)];
	var trackText = [CPTextField hudLabelWithTitle:""];
	[trackText setFrameOrigin:CGPointMake(leftDistance+80, topDistance)];

	var artistLabel = [CPTextField hudLabelWithTitle:"Artist:"];
	[artistLabel setFrameOrigin:CGPointMake(leftDistance, topDistance+=verticalDistance)];
	var artistText = [CPTextField hudLabelWithTitle:""];
	[artistText setFrameOrigin:CGPointMake(leftDistance+80, topDistance)];

	var albumLabel = [CPTextField hudLabelWithTitle:"Album:"];
	[albumLabel setFrameOrigin:CGPointMake(leftDistance, topDistance+=verticalDistance)];
	var albumText = [CPTextField hudLabelWithTitle:""];
	[albumText setFrameOrigin:CGPointMake(leftDistance+80, topDistance)];

	var yearLabel = [CPTextField hudLabelWithTitle:"Year:"];
	[yearLabel setFrameOrigin:CGPointMake(leftDistance, topDistance+=verticalDistance)];
	var yearText = [CPTextField hudLabelWithTitle:""];
	[yearText setFrameOrigin:CGPointMake(leftDistance+80, topDistance)];

	[contentView addSubview:trackLabel];
	[contentView addSubview:artistLabel];
	[contentView addSubview:albumLabel];
	[contentView addSubview:yearLabel];

	[contentView addSubview:trackText];
	[contentView addSubview:artistText];
	[contentView addSubview:albumText];
	[contentView addSubview:yearText];
	
	return self;
}

- (void) update {
	var request = [CPURLRequest requestWithURL:"playing/show"];
	var connection = [CPURLConnection connectionWithRequest:request delegate:self];
}

-(void)connection:(CPURLConnection)connection didReceiveData:(CPString)data {
	var jsObject = [data objectFromJSON];
	if(jsObject.message) {
		if(prevTrackId != null) {
			[appController updateVotesAndTopTracks];
		}
		[trackText setStringValue:jsObject.message];
		[trackText setTextColor:[CPColor grayColor]];
		[artistText setStringValue:""];
		[albumText setStringValue:""];
		[yearText setStringValue:""];
		prevTrackId = null;
	} else {
		if(prevTrackId != jsObject.track._id) {
			[appController updateVotesAndTopTracks];
		}
		[trackText setStringValue:jsObject.track.track_name];
		[trackText setTextColor:[CPColor whiteColor]];
		[artistText setStringValue:jsObject.track.artist_name];
		[albumText setStringValue:jsObject.track.album_name];
		[yearText setStringValue:jsObject.track.year];
		prevTrackId = jsObject.track._id;
	}
	[trackText sizeToFit];
	[artistText sizeToFit];
	[albumText sizeToFit];
	[yearText sizeToFit];
}
@end
