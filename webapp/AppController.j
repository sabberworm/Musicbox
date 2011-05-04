/*
 * AppController.j
 * M.U.S.I.C.box
 *
 * Created by You on July 5, 2009.
 * Copyright 2009, rasch@R.Ø.S.A. All rights reserved.
 */

@import <Foundation/CPObject.j>
@import "NowPlayingView.j"
@import "MusicListController.j"
@import "MyVotesView.j"
@import "LoginController.j"
@import "MainToolbarDelegate.j"
@import "TrackListController.j"

@implementation AppController : CPObject
{
	NowPlayingView nowPlayingWindow @accessors;
	MyVotesView myVotesWindow @accessors;
	MusicListController allMusicWindow @accessors;
	TrackListController currentTopTracks @accessors;
	CPString userName @accessors;
	CPDictionary windowTitles @accessors;
	CPTextField nameLabel @accessors;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
	var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask],
		contentView = [theWindow contentView];
	[contentView setBackgroundColor:[CPColor blackColor]];
	
	windowTitles = [CPDictionary dictionaryWithJSObject: {
		MyVotes: "My Votes",
		AllMusic: "Available Music",
		CurrentTopTracks: "Current Playlist",
		NowPlaying: "Now Playing",
		Albums: "All Albums",
		Logout: "Logout"
	}]
	
	var toolbar = [[CPToolbar alloc] initWithIdentifier:"Main"];
	var toolbarDelegate = [[MainToolbarDelegate alloc] initWithAppController:self];
	[toolbar setDelegate:toolbarDelegate];
	[toolbar setVisible:YES];
	[theWindow setToolbar: toolbar];

	var rosaLabel = [[CPTextField alloc] initWithFrame:CGRectMake(0, 0, 255, 30)];
	[rosaLabel setStringValue:"Internal"];
	[rosaLabel setTextColor:[CPColor colorWithHexString:"FF99CC"]];
	[rosaLabel setFont:[CPFont systemFontOfSize:24]];
	[rosaLabel sizeToFit];
	[contentView addSubview: rosaLabel];

	var boxLabel = [[CPTextField alloc] initWithFrame:CGRectMake([rosaLabel frame].size.width+2, 0, 255, 30)];
	[boxLabel setStringValue:"M.U.S.I.C.box"];
	[boxLabel setTextColor:[CPColor whiteColor]];
	[boxLabel setFont:[CPFont systemFontOfSize:24]];
	[boxLabel sizeToFit];
	[contentView addSubview: boxLabel];

	nameLabel = [[CPTextField alloc] initWithFrame:CGRectMake([boxLabel frame].origin.x+[boxLabel frame].size.width+2, 0, 255, 30)];
	[nameLabel setTextColor:[CPColor colorWithHexString:"666666"]];
	[nameLabel setFont:[CPFont systemFontOfSize:24]];
	[contentView addSubview: nameLabel];
	
	[theWindow orderFront:self];
	
	nowPlayingWindow = [[NowPlayingView alloc] initWithAppController:self];
	[nowPlayingWindow showWindow:self];
	window.setInterval(function() {[self updateNowPlaying];}, 20*1000);
	[self updateNowPlaying];

	myVotesWindow = [[MyVotesView alloc] initWithAppController:self];
	
  currentTopTracks = null;
  allMusicWindow = null;
	
	var request = [CPURLRequest requestWithURL:"users/test"];
	var jsObject = [CPURLConnection sendSynchronousRequest:request returningResponse:nil].JSONObject();
	if(jsObject.login) {
		[self login:jsObject.login];
	} else {
		var loginController = [LoginController sharedLoginController];
		[loginController showLoginWindow:self];
	}
}

- (void)updateNowPlaying {
	[nowPlayingWindow update];
}

- (void)login:(CPString)user {
	userName = user;
	[nameLabel setStringValue:user];
	[nameLabel sizeToFit];
  [myVotesWindow showWindow:self];
	[myVotesWindow activate];
	
	//Show late to avoid the long load
  allMusicWindow = [[MusicListController alloc] initWithAppController:self];
  [allMusicWindow showWindow:self];
}

- (void) updateTopTracks {
  if(![self userName]) {
    return;
  }
  
  var request = [CPURLRequest requestWithURL:"music/next_tracks"];
  if(currentTopTracks == null) {
    var tracks = [CPURLConnection sendSynchronousRequest:request returningResponse:nil].JSONObject();
    currentTopTracks = [[TrackListController alloc] initWithAppController:self andTracks:tracks andFrame:CGRectMake(10, 500, 300, 300) andTitle:[[self windowTitles] objectForKey:"CurrentTopTracks"] withVotesColumn:YES];
  } else {
    var connection = [CPURLConnection connectionWithRequest:request delegate:currentTopTracks];
  }
}

- (void) toggleTopTracks {
  if(!currentTopTracks) {
    [self updateTopTracks];
	  window.setInterval(function() {[self updateTopTracks];}, 20*1000);
  }
  [[self currentTopTracks] toggle];
}

- (void)updateMyVotes {
  if(![self userName]) {
    return;
  }
  [myVotesWindow update];
}

- (void)updateVotesAndTopTracks {
  [self updateMyVotes];
  [self updateTopTracks];
}

@end
