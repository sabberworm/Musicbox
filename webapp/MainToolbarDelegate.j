@import <AppKit/CPToolbar.j>
@import <AppKit/CPToolbarItem.j>

@implementation MainToolbarDelegate : CPObject {
	AppController appController;
  CPArray toolbarItems;
}

- (id)initWithAppController:(AppController)controller {
	appController = controller;
  toolbarItems = [CPArray arrayWithObjects:['AllMusic', CPToolbarFlexibleSpaceItemIdentifier, 'CurrentTopTracks', 'MyVotes', CPToolbarSeparatorItemIdentifier, 'NowPlaying'] count:4];
	self = [super init];
	return self
}

// Return an array of toolbar item identifier (all the toolbar items that may be present in the toolbar)
- (CPArray)toolbarAllowedItemIdentifiers:(CPToolbar)aToolbar {
	return toolbarItems;
}

// Return an array of toolbar item identifier (the default toolbar items that are present in the toolbar)
- (CPArray)toolbarDefaultItemIdentifiers:(CPToolbar)aToolbar {
	return toolbarItems;
}

- (CPToolbarItem)toolbar:(CPToolbar)aToolbar itemForItemIdentifier:(CPString)anItemIdentifier willBeInsertedIntoToolbar:(BOOL)aFlag {
	var toolbarItem = [[CPToolbarItem alloc] initWithItemIdentifier:anItemIdentifier];
	var mainBundle = [CPBundle mainBundle];
	
	var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:[anItemIdentifier stringByAppendingString:".png"]] size:CPSizeMake(32, 32)];
	[toolbarItem setImage:image];
	
	image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:[anItemIdentifier stringByAppendingString:"-Press.png"]] size:CPSizeMake(32, 32)];
	[toolbarItem setAlternateImage:image];
		
	[toolbarItem setTarget:self];
	if(anItemIdentifier == "MyVotes") {
		[toolbarItem setAction:@selector(toggleVotes:)];
	} else if(anItemIdentifier == "NowPlaying") {
		[toolbarItem setAction:@selector(toggleNowPlaying:)];
	} else if(anItemIdentifier == "CurrentTopTracks") {
		[toolbarItem setAction:@selector(togglePlaylist:)];
	} else if(anItemIdentifier == "AllMusic") {
		[toolbarItem setAction:@selector(toggleMusic:)];
	}
	[toolbarItem setLabel:[[appController windowTitles] objectForKey:anItemIdentifier]];
	
	[toolbarItem setMinSize:CGSizeMake(32, 32)];
	[toolbarItem setMaxSize:CGSizeMake(32, 32)];	
	return toolbarItem;
}

- (void)toggleVotes:(id)sender {
	[[appController myVotesWindow] toggle];
}

- (void)toggleNowPlaying:(id)sender {
	[[appController nowPlayingWindow] toggle];
}

- (void)togglePlaylist:(id)sender {
  [appController toggleTopTracks];
}

- (void)toggleMusic:(id)sender {
  [[appController allMusicWindow] toggle];
}

@end
