@import <AppKit/CPWindow.j>
@import <AppKit/CPWindowController.j>
@import <AppKit/CPTableView.j>
@import <AppKit/CPBrowser.j>
@import "Additions.j"

@implementation MusicViewController : CPWindowController {
	CPBrowser musicBrowser;
	CPTableView trackList;
	AppController appController;
}

- (id)initWithAppController:(AppController)controller {
	var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMake(340, 130, 500, 400) styleMask:CPTitledWindowMask|CPMiniaturizableWindowMask|CPResizableWindowMask];
	self = [super initWithWindow:theWindow];
	if (!self) {
		return nil;
	}
	var contentView = [theWindow contentView];
	appController = controller;
	storedArtists = [[CPMutableDictionary alloc] init];
	
	// musicBrowser = [[CPBrowser alloc] initWithContentRect];
	
	[theWindow setTitle:[[appController windowTitles] objectForKey:"AllMusic"]];

	var toolbar = [[CPToolbar alloc] initWithIdentifier:"Main"];
	var toolbarDelegate = [[MainToolbarDelegate alloc] initWithAppController:controller];
	[toolbar setDelegate:toolbarDelegate];
	[toolbar setVisible:YES];
	[theWindow setToolbar: toolbar];
	
	return self;
}

@end