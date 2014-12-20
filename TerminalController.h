//
//  TerminalController.h
//  iNetSim
//
//  Created by James Hope on 3/10/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class OSController, IOSController, DOSController, TerminalView;

@interface TerminalController : NSObject 
{
    IBOutlet NSPanel *terminalWindow;
	IBOutlet NSTabView *tabView;
	IBOutlet NSArrayController *deviceArray;
	IBOutlet NSArrayController *switchArray;
	IBOutlet NSArrayController *routerArray;
	IBOutlet NSArrayController *pcArray;
    //IBOutlet NSArrayController *linkTypeArray;
		IBOutlet NSArrayController *ripEntryArray; // added by James Hope 20/10/05
		IBOutlet NSArrayController *networkArray; // added by James Hope 20/10/05
        IBOutlet NSArrayController *hostTableArray; // added by Leong 01/11/2005
	@private
		NSMutableArray *CA_sessions;
}

- (void)newSession:(NSString *)deviceName;
- (BOOL)newTelnetSession:(NSString *)deviceName;
- (void)closeSession;


@end
