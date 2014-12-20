//  MyDocument.h
//  iNetSimDemo
//
//  Created by Leon Chew on 31/08/05.
//  Copyright __MyCompanyName__ 2005 . All rights reserved.

#import <Cocoa/Cocoa.h>

@class TopologyController, TerminalController;

@interface MyDocument : NSPersistentDocument 
{
	IBOutlet NSWindow *deviceModelViewer;
	IBOutlet TopologyController *controller;
	IBOutlet NSArrayController *deviceArray;
	IBOutlet NSArrayController *linkArray;
//    IBOutlet NSArrayController *portTypeController;
		// Terminal Controller
    IBOutlet TerminalController *terminalController;
}

- (IBAction)showDeviceModelViewer:(id)sender;
- (IBAction)addHub:(id)sender;
- (IBAction)addSwitch:(id)sender;
- (IBAction)addRouter:(id)sender;
- (IBAction)addPC:(id)sender;
- (IBAction)addLink:(id)sender;
- (IBAction)removeDevice:(id)sender;
- (IBAction)removeLink:(id)sender;
- (IBAction)showTerminal:(id)sender;

@end
