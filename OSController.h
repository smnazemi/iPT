//
//  OSController.h
//  iNetSim
//
//  Created by James Hope on 6/10/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TerminalView;

// Abstract class
@interface OSController : NSObject 
{
   @protected
	int CA_cursorPos;
	int CA_editPos;
	TerminalView *CA_terminalView;
	NSManagedObject *CA_device;
	id CA_delegate;
	int CA_currentState;
	NSString *CA_buffer;
	NSDictionary *CA_stateDictionary;
    NSManagedObject *CA_port;   // Added on 16/10/2005 by Leong
    NSArrayController *CA_routerArrayController; // Leong, please change this so it has the CA_ prefix
		NSArrayController *CA_ripEntryArray; // added by James Hope 20/10/05
		NSArrayController *CA_networkArray; // added by James Hope 20/10/05
        NSArrayController *CA_hostTableArray; // added by Leong 01/11/2005
      NSMutableArray *CA_commandHistory;
      int CA_historyIndex;

}

- (void)setView:(TerminalView *)terminalView;
- (void)setDevice:(NSManagedObject *)device;
- (void)setDelegate:(id)delegate;
- (void)setRipEntryArray:(NSArrayController *)ripEntryArray;
- (void)setNetworkArray:(NSArrayController *)networkArray;
- (void)setHostTableArray:(NSArrayController *)hostTableArray;
- (TerminalView *)view;
- (NSManagedObject *)device;
- (id)delegate;
- (NSArrayController *)ripEntryArray;
- (NSArrayController *)networkArray;
- (NSArrayController *)hostTableArray;
- (void)showPrompt;
- (void)showCommandNotFound;
- (BOOL)sendData:(NSString *)data;
- (void)showHistoryUp;
- (void)showHistoryDown;
- (void)parseInput;
- (void)callMethod:(NSString *)methodName withArguments:(NSArray *)args;


- (NSManagedObject *)port;                  // Added on 16/10/2005 by Leong
- (void)setPort:(NSManagedObject *)aPort;   // Added on 16/10/2005 by Leong
- (NSManagedObject *)retrievePortWithIp:(NSString *)ipAddress;    // Added on 22/10/2005 by Leong
- (NSArray *)retriveRouters;
- (void)pingProgressIndicator:(NSString *)aString;
- (NSArray *)fetchRipTable;

- (void)setRouterArrayController:(NSArrayController *)anArrayController;

@end
