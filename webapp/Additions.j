@import <Foundation/CPObject.j>
@import <Foundation/CPString.j>
@import <AppKit/CPTextField.j>
@import <AppKit/CPWindowController.j>

@implementation CPString (URLEncodeAdditon)
- (CPString)urlencode
{
	// http://kevin.vanzonneveld.net
	// +   original by: Philip Peterson
	// +   improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
	// +      input by: AJ
	// +   improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
	// +   improved by: Brett Zamir (http://brett-zamir.me)
	// +   bugfixed by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
	// +      input by: travc
	// +      input by: Brett Zamir (http://brett-zamir.me)
	// +   bugfixed by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
	// +   improved by: Lars Fischer
	// +      input by: Ratheous
	// +      reimplemented by: Brett Zamir (http://brett-zamir.me)
	// +   bugfixed by: Joris
	// +      reimplemented by: Brett Zamir (http://brett-zamir.me)
	// %          note 1: This reflects PHP 5.3/6.0+ behavior
	// %        note 2: Please be aware that this function expects to encode into UTF-8 encoded strings, as found on
	// %        note 2: pages served as UTF-8
	// *     example 1: urlencode('Kevin van Zonneveld!');
	// *     returns 1: 'Kevin+van+Zonneveld%21'
	// *     example 2: urlencode('http://kevin.vanzonneveld.net/');
	// *     returns 2: 'http%3A%2F%2Fkevin.vanzonneveld.net%2F'
	// *     example 3: urlencode('http://www.google.nl/search?q=php.js&ie=utf-8&oe=utf-8&aq=t&rls=com.ubuntu:en-US:unofficial&client=firefox-a');
	// *     returns 3: 'http%3A%2F%2Fwww.google.nl%2Fsearch%3Fq%3Dphp.js%26ie%3Dutf-8%26oe%3Dutf-8%26aq%3Dt%26rls%3Dcom.ubuntu%3Aen-US%3Aunofficial%26client%3Dfirefox-a'
	var str = self.toString();

	// Tilde should be allowed unescaped in future versions of PHP (as reflected below), but if you want to reflect current
	// PHP behavior, you would need to add ".replace(/~/g, '%7E');" to the following.
	return encodeURIComponent(str).replace(/!/g, '%21').replace(/'/g, '%27').replace(/\(/g, '%28').replace(/\)/g, '%29').replace(/\*/g, '%2A').replace(/%20/g, '+');
}
@end

@implementation CPTextField (TitledLabelAddition)
+ (CPTextField)hudLabelWithTitle:(CPString)aTitle {
	var label = [CPTextField labelWithTitle:aTitle];
	[label setTextColor:[CPColor whiteColor]];
	return label;
}
@end

@implementation CPWindowController (ToggleAddition)
-(void)toggle {
	if([[self window] isVisible]) {
		[[self window] orderOut:self];
	} else {
		[[self window] orderFront:self];
	}
}
@end

@implementation CPWindowController (SimpleCPTableViewSetup)
-(CPTableView)setUpTableViewWithFirstColumn:(CPString)columnName {
  var contentView = [[self window] contentView];
  
  var scrollView = [[CPScrollView alloc] initWithFrame:[contentView bounds]];
  [scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [scrollView setAutoresizesSubviews:YES];

  var result = [[CPTableView alloc] initWithFrame:[scrollView bounds]];
  [result setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [result setAutoresizesSubviews:YES];
  [result setUsesAlternatingRowBackgroundColors:YES];

  var firstColumn = [[CPTableColumn alloc] initWithIdentifier:"column1"];
  [[firstColumn headerView] setStringValue:columnName];
  [firstColumn setWidth:[result bounds].size.width-17];
  [result addTableColumn:firstColumn];
  
  [scrollView setDocumentView:result];
  [contentView addSubview:scrollView];

  [result setDelegate:self];
  [result setDataSource:self];
  
  return result;
}
@end
