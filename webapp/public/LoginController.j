/*
 * LoginController.j
 *
 * Created by Philippe Laval on 2009/03/19.
 * Copyright 2009 Philippe Laval. All rights reserved.
 */

@import <Foundation/CPObject.j>
@import <AppKit/CPWindowController.j>
@import "Additions.j"

var loginControllerSharedInstance = nil;

@implementation LoginController : CPWindowController
{
	CPTextField userTextField;
	CPTextField errorTextField;
	CPButton okButton;
	AppController appController;
}

+ (LoginController)sharedLoginController
{	
    if (loginControllerSharedInstance == nil)
    {
        loginControllerSharedInstance = [[LoginController alloc] init];
    }
    
    return loginControllerSharedInstance;
}

- (void)showLoginWindow:(id)sender
{
	appController = sender;
    [CPApp runModalForWindow:[self window]];
}

- (id)init
{
	// Create the login window
    var theWindow = [[CPPanel alloc] initWithContentRect:CGRectMake(100,100,320,160) styleMask: CPTitledWindowMask|CPTitledWindowMask];
    self = [super initWithWindow:theWindow];
    if (self)
    {
		[theWindow setTitle:@"Login"];
		[theWindow setLevel:CPModalPanelWindowLevel];
        
        [theWindow setDelegate:self];

		var contentView = [theWindow contentView];
		
		// Not login in
		isLoginIn = NO;
		accountID = -1;
		
		var textField = [[CPTextField alloc] initWithFrame:CGRectMake(10, 10, 320, 24)];
		[textField setStringValue:@"Enter your username and password to login."];
		[contentView addSubview:textField]; 

		textField = [[CPTextField alloc] initWithFrame:CGRectMake(10, 44, 70, 28)];
		[textField setStringValue:"User Name:"];
		[textField setAlignment:CPRightTextAlignment];
		[contentView addSubview:textField]; 

		textField = [[CPTextField alloc] initWithFrame:CGRectMake(10, 78, 70, 28)];
		[textField setStringValue:"Password:"];
		[textField setAlignment:CPRightTextAlignment];
		[contentView addSubview:textField];

		// Add the fields
		userTextField = [[CPTextField alloc] initWithFrame:CGRectMake(100, 40, 200, 28)];
		[userTextField setPlaceholderString:"username"];
		[userTextField setEditable:YES];
		[userTextField setSelectable:YES];
		[userTextField setBordered:YES]
		[userTextField setBezeled:YES]
		[userTextField setBezelStyle:CPTextFieldSquareBezel];
		[userTextField becomeFirstResponder];
		[contentView addSubview:userTextField]; 
		
		passwordTextField = [[CPSecureTextField alloc] initWithFrame:CGRectMake(100, 70, 200, 28)];
		[passwordTextField setPlaceholderString:"password"];
		[passwordTextField setEditable:YES];
		[passwordTextField setSelectable:YES];
		[passwordTextField setBordered:YES]
		[passwordTextField setBezeled:YES]
		[passwordTextField setBezelStyle:CPTextFieldSquareBezel];
		[contentView addSubview:passwordTextField]; 
		
		okButton = [[CPButton alloc] initWithFrame:CGRectMake(254, 105, 80, 18)];
		[okButton setTitle:"Login"];
	    [okButton setAction:@selector(login:)];
	    [okButton setTarget:self];
		[okButton sizeToFit];
		[contentView addSubview:okButton];

		errorTextField = [[CPTextField alloc] initWithFrame:CGRectMake(10, 128, 320, 24)];
		[errorTextField setTextColor:[CPColor redColor]];
		[contentView addSubview:errorTextField]; 
	}
	
	return self;
}

-(void) login:(id)sender
{
	var request = [CPURLRequest requestWithURL:"user/login?user_name="+encodeURIComponent([userTextField stringValue])+"&password="+encodeURIComponent([passwordTextField stringValue])];
	var jsObject = CPJSObjectCreateWithJSON([CPURLConnection sendSynchronousRequest:request returningResponse:nil error:nil].string);
	if(jsObject.error) {
		[errorTextField setStringValue:jsObject.error];
	} else if(jsObject.login) {
		[appController login:[userTextField stringValue]];
		[CPApp stopModal];
		[[self window] orderOut:self];
	}
}

@end