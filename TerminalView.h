//
//  TerminalView.h
//  iNetSim
//
//  Created by James Hope on 6/10/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class OSController;

@interface TerminalView : NSTextView 
{
  @private
	OSController *CA_osController;
}

- (void)setOSController:(OSController *)osController;
- (OSController *)osController;

@end
