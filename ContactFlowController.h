//
//  ContactFlowController.h
//  ContactFlow
//
//  Created by Zero on 11/8/07.
//  Copyright 2007 Zero's Studio. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ContactFlowController : NSWindowController {
	NSMutableArray *_imageArray;
	IBOutlet id _imageBrowser;
	IBOutlet id _searchField;
}
- (void)find:(id)sender;
@end
