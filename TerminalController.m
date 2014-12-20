//
//  TerminalController.m
//  iNetSim
//
//  Created by James Hope on 3/10/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "TerminalController.h"


@implementation TerminalController

- (void)awakeFromNib
{
	CA_sessions = [[NSMutableArray alloc] init];
	[tabView removeTabViewItem:[tabView tabViewItemAtIndex:0]];
}

/*
 Method Name: newSession:
 Imported values:
 - (NSString pointer)deviceName - the name of the device that we want a terminal session for
 Exported value: none
 Purpose: This method creates a new terminal session, or switches to an existing one, for a
 particular device.
 */
- (void)newSession:(NSString *)deviceName
{
	BOOL isNewSession = YES;
	int tabNumber = 0;
	int i;
	NSArrayController *array;
	OSController *theOS;
	
	// Check if a tab already exists for this device
	for (i = 0; i < [CA_sessions count]; i++)
		{
		if ([[[[[CA_sessions objectAtIndex:i] objectAtIndex:0] 
			device] valueForKey:@"deviceName"] isEqualToString:deviceName])
			{
			// It does, so don't create a new session
			isNewSession = NO;
			tabNumber = i;
			}
		}
	
	// ok, create a new session if there's no session already
	if (isNewSession)
		{
		// filter it out
		[deviceArray setFilterPredicate: 
			[NSPredicate predicateWithFormat:@"deviceName matches[c] %@", deviceName]];
		NSString *deviceType = [[[deviceArray selectedObjects] objectAtIndex:0] valueForKey:@"deviceType"];
		if ([deviceType isEqualToString:@"Switch"] || [deviceType isEqualToString:@"Router"]
				|| [deviceType isEqualToString:@"PC"])
			{
			NSTabViewItem *tabViewItem = [[NSTabViewItem alloc] initWithIdentifier:deviceName];
			// [tabViewItem setLabel:deviceName];
			// Tie the tab view item's label to the actual object, do that after the device has been found
			// This is to allow the tab view item's label to be updated when a device has it's name changed
			
			// add the tab view item to the tab view
			[tabView addTabViewItem:tabViewItem];
			
			// create the terminal view and add it to the tab view item. Give the terminal view
			// the frame based on the internal bounds of the tab view
			NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:[tabView bounds]];
			NSClipView *clipView = [[NSClipView alloc] initWithFrame:[scrollView bounds]];
			[scrollView setContentView:clipView];
			TerminalView *terminal = [[TerminalView alloc] initWithFrame:[clipView bounds]];
			[scrollView setDocumentView:terminal];
			[scrollView setHasVerticalScroller:YES];
			[scrollView setBorderType:NSBezelBorder];
			[tabViewItem setView:scrollView];
			
			// now create the OS controllers
			if ([deviceType isEqualToString:@"Router"])
				{
				array = routerArray;
				theOS = [[IOSController alloc] init];
				}
			else if ([deviceType isEqualToString:@"Switch"])
				{
				array = switchArray;
				theOS = [[IOSController alloc] init];
				}
			else if ([deviceType isEqualToString:@"PC"])
				{
				array = pcArray;
				theOS = [[DOSController alloc] init];
				}
			// find the device
			NSLog(@"find the device");
			[array setSelectedObjects:[deviceArray arrangedObjects]];
			// hand it over to the OS
			NSLog(@"hand it over to the OS");
			[theOS setDevice:[[array selectedObjects] objectAtIndex:0]];
			// bind the tab view item's label to the device's name
			NSLog(@"bind the tab view item's label to the device's name");
			[tabViewItem bind:@"label" toObject:[[array selectedObjects] objectAtIndex:0]
						withKeyPath:@"deviceName" options:nil];
			// do the rest of the setting up of view and delegates
			NSLog(@"do the rest of the setting up of view and delegates");
			[theOS setView:terminal];
			[theOS setDelegate:self];
			[theOS setRipEntryArray:ripEntryArray]; // added by James Hope 20/10/2005
			[theOS setNetworkArray:networkArray];  // added by James Hope 20/10/2005
            [theOS setHostTableArray:hostTableArray]; //Added by Leong on 01/11/2005
			[terminal setDelegate:self];
			[terminal setOSController:theOS];
			// add this session to the session array
			[CA_sessions addObject:[NSMutableArray arrayWithObject:theOS]];
			// Display the terminal window
			[tabView selectLastTabViewItem:self];
			[terminalWindow makeKeyAndOrderFront:self];

			// boot the OS
			[theOS boot];
            [theOS setRouterArrayController:routerArray];
			}
		else
			{
			NSLog(@"Error: shouldn't be here making a new terminal session when a Switch, Router, or PC isn't selected!");
			NSLog(@"Device Name: %@, Device Type: %@", deviceName, deviceType);
			}
		}
	else
		{
		[tabView selectTabViewItemAtIndex:tabNumber];
		// Display the terminal window
		[terminalWindow makeKeyAndOrderFront:self];
		}
}

/*
 Method Name: newTelnetSession:
 Imported values:
 - (NSString pointer)deviceName - the name of the device that we want a telnet session for
 Exported value: (boolean)success - notifies the calling OS that the telnet session is a success
 Purpose: This method creates a new telnet session within the currently focussed terminal session
 */
- (BOOL)newTelnetSession:(NSString *)deviceName
{
	BOOL success = NO;
	int session;
	TerminalView *terminal;
	NSArrayController *array;
	OSController *theOS;
	
	session = [tabView indexOfTabViewItem:[tabView selectedTabViewItem]];
	// filter it out
  [deviceArray setFilterPredicate: 
		[NSPredicate predicateWithFormat:@"deviceName matches[c] %@", deviceName]];
	if ([[deviceArray arrangedObjects] count] == 1)
		{
		NSString *deviceType = [[[deviceArray arrangedObjects] objectAtIndex:0] valueForKey:@"deviceType"];
		// removed the ability to telnet into a PC - 23/10/2005 by James Hope
		if ([deviceType isEqualToString:@"Switch"] || [deviceType isEqualToString:@"Router"])
			{
			// now create the OS controllers
			if ([deviceType isEqualToString:@"Router"])
				{
				array = routerArray;
				theOS = [[IOSController alloc] init];
				}
			else if ([deviceType isEqualToString:@"Switch"])
				{
				array = switchArray;
				theOS = [[IOSController alloc] init];
				}
			// find the device
			[array setSelectedObjects:[deviceArray arrangedObjects]];
			// hand it over to the OS
			[theOS setDevice:[[array selectedObjects] objectAtIndex:0]];
			
			terminal = [[[tabView selectedTabViewItem] view] documentView];
			// do the rest of the setting up of view and delegates
			[theOS setView:terminal];
			[theOS setDelegate:self];
			[theOS setRipEntryArray:ripEntryArray]; // added by James Hope 20/10/2005
			[theOS setNetworkArray:networkArray];  // added by James Hope 20/10/2005
			[terminal setDelegate:self];
			[terminal setOSController:theOS];
			// disable access of the calling OS to the Terminal View
			[[[CA_sessions objectAtIndex:session] lastObject] setView:nil];
			// add this session to the session array
			[[CA_sessions objectAtIndex:session] addObject:theOS];
			// start the session
			[theOS loginVty];
			success = YES;
			}
		else
			{
			NSLog(@"Error: shouldn't be here making a new telnet session for something other than a Switch or Router");
			}
		}
	return success;
}

/*
 Method Name: closeSession
 Imported values: none
 Exported value: none
 Purpose: This method closes the top level session for the current terminal
 */
- (void)closeSession
{
	TerminalView *terminal;
	OSController *theOS;
	int session = [tabView indexOfTabViewItem:[tabView selectedTabViewItem]];
	
	// prevent the closing session from outputting to the terminal
	[[[CA_sessions objectAtIndex:session] lastObject] setView:nil];
	[[CA_sessions objectAtIndex:session] removeObjectAtIndex:[[CA_sessions objectAtIndex:session] count] - 1];
	terminal = [[[tabView selectedTabViewItem] view] documentView];
	
	// check if that was the first session or not
	if ([[CA_sessions objectAtIndex:session] count] > 0)
		{
		// not first session, so restore the previous one
	  theOS = [[CA_sessions objectAtIndex:session] lastObject];
		[terminal setOSController:theOS];
		[theOS setView:terminal];
		[theOS showPrompt];
		}
	else
		{
		// was the last session, so clean up the terminal window
		[[CA_sessions objectAtIndex:session] release];
		[CA_sessions removeObjectAtIndex:session];
		[terminal release];
		[tabView removeTabViewItem:[tabView selectedTabViewItem]];
    // Now check if all terminals are closed or not
		if ([CA_sessions count] == 0)
			{
			[terminalWindow performClose:self];
			}
		}
}

@end
