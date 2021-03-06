@import <AppKit/CPPanel.j>
@import <AppKit/CPWindowController.j>
@import "Additions.j"

@implementation MyVotesView : CPWindowController {
	CPTextField votesText;
	CPButton resetButton;
	AppController appController;
}

- (id)initWithAppController:(AppController)controller {
	var theWindow = [[CPPanel alloc] initWithContentRect:CGRectMake(10, 130, 200, 120) styleMask:CPHUDBackgroundWindowMask|CPClosableWindowMask];
	self = [super initWithWindow:theWindow];
	if (!self) {
		return nil;
	}
	var contentView = [theWindow contentView];
	appController = controller;
	
	[theWindow setTitle:[[appController windowTitles] objectForKey:"MyVotes"]];
	[theWindow setFloatingPanel:YES];
	
	var votesLabel = [CPTextField hudLabelWithTitle:"Votes left:"];
	[votesLabel setFrameOrigin:CGPointMake(40, 30)];
	var votesText = [CPTextField hudLabelWithTitle:"unknown"];
	[votesText setFrameOrigin:CGPointMake(120, 30)];
	
  resetButton = [[CPButton alloc] initWithFrame:CGRectMake(40, 60, 0, 0)];
  [resetButton setTitle:"Reset My Votes"];
  [resetButton setTarget:self];
  [resetButton setAction:@selector(resetVotes)];
  [resetButton setBezelStyle: CPHUDBezelStyle];
  [resetButton setHidden:YES];
  [resetButton sizeToFit];

  [contentView addSubview:resetButton];
	[contentView addSubview:votesLabel];
	[contentView addSubview:votesText];
	[contentView addSubview:resetButton];
	
	return self;
}

-(void) activate {
  [resetButton setHidden:NO];
  [self update];
}

- (void) update {
	var request = [CPURLRequest requestWithURL:"my_votes/show_votes?user_name="+[appController userName]];
	var connection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void) resetVotes {
	var request = [CPURLRequest requestWithURL:"my_votes/reset?user_name="+[appController userName]];
	var response, error;
	var connection = [CPURLConnection sendSynchronousRequest:request returningResponse:response error:error];
	[appController updateVotesAndTopTracks];
}

-(void)connection:(CPURLConnection)connection didReceiveData:(CPString)data {
	var jsObject = [data objectFromJSON];
	[votesText setStringValue:jsObject.vote_count];
	[votesText sizeToFit];
}

@end
