@import <Foundation/CPObject.j>
@import <Foundation/CPString.j>
@import <AppKit/CPTextField.j>
@import <AppKit/CPWindowController.j>

@implementation CPString (URLEncodeAdditon)
- (CPString)urlencode
{
    // URL-encodes string 
    //
    // version: 901.1411
    // discuss at: http://phpjs.org/functions/urlencode
    // +   original by: Philip Peterson
    // +   improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
    // +      input by: AJ
    // +   improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
    // +   improved by: Brett Zamir
    // %          note: info on what encoding functions to use from: http://xkr.us/articles/javascript/encode-compare/
    // *     example 1: urlencode('Kevin van Zonneveld!');
    // *     returns 1: 'Kevin+van+Zonneveld%21'
    // *     example 2: urlencode('http://kevin.vanzonneveld.net/');
    // *     returns 2: 'http%3A%2F%2Fkevin.vanzonneveld.net%2F'
    // *     example 3: urlencode('http://www.google.nl/search?q=php.js&;ie=utf-8&oe=utf-8&aq=t&rls=com.ubuntu:en-US:unofficial&client=firefox-a');
    // *     returns 3: 'http%3A%2F%2Fwww.google.nl%2Fsearch%3Fq%3Dphp.js%26ie%3Dutf-8%26oe%3Dutf-8%26aq%3Dt%26rls%3Dcom.ubuntu%3Aen-US%3Aunofficial%26client%3Dfirefox-a'
                              
    var histogram = {}, tmp_arr = [];
    var ret = self.toString();
     
    var replacer = function(search, replace, str) {
        var tmp_arr = [];
        tmp_arr = str.split(search);
        return tmp_arr.join(replace);
    };
     
    // The histogram is identical to the one in urldecode.
    histogram["'"]   = '%27';
    histogram['(']   = '%28';
    histogram[')']   = '%29';
    histogram['*']   = '%2A';
    histogram['~']   = '%7E';
    histogram['!']   = '%21';
    histogram['%20'] = '+';
     
    // Begin with encodeURIComponent, which most resembles PHP's encoding functions
    ret = encodeURIComponent(ret);
     
    for (search in histogram) {
        replace = histogram[search];
        ret = replacer(search, replace, ret) // Custom replace. No regexing
    }
     
    // Uppercase for full PHP compatibility
    return ret.replace(/(\%([a-z0-9]{2}))/g, function(full, m1, m2) {
        return "%"+m2.toUpperCase();
    });
     
    return ret;
}
@end

@implementation CPTextField (TitledLabelAddition)
+ (CPTextField)labelWithTitle:(CPString)aTitle {
	var label = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
	[label setStringValue:aTitle];
	[label sizeToFit];
	return label;
}
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
