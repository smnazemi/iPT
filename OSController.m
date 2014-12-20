//
//  OSController.m
//  iNetSim
//
//  Created by James Hope on 6/10/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "OSController.h"


@implementation OSController

- (id)init
{
	[super init];
   
   CA_commandHistory = [NSMutableArray new];
	
	CA_buffer = [[NSString alloc] initWithString:@""];
	
	return self;
}

/*
 Method Name: setView:
 Imported values:
 - (TerminalView pointer)deviceName - the terminal view to attach to
 Exported value: none
 Purpose: This method attaches this OS controller to a particular terminal view
 */
- (void)setView:(TerminalView *)terminalView
{
	if (terminalView != CA_terminalView)
    {
		[CA_terminalView release];
		CA_terminalView = [terminalView retain];
    }
}

/*
 Method Name: setDevice:
 Imported values:
 - (NSManagedObject pointer)device - the model entity to which this OS belongs
 Exported value: none
 Purpose: This method attaches this OS controller to its model entity
 */
- (void)setDevice:(NSManagedObject *)device
{
	if (device != CA_device)
    {
		[CA_device release];
		CA_device = [device retain];
    }
}

/*
 Method Name: setDelegate:
 Imported values:
 - (id)delegate - the delegate for instances of this class
 Exported value: none
 Purpose: This method attaches this OS controller to a particular delegate
 */
- (void)setDelegate:(id)delegate
{
	if (delegate != CA_delegate)
    {
		[CA_delegate release];
		CA_delegate = [delegate retain];
    }
}

/*
 Method Name: setRipEntryArray:
 Imported values:
 - (NSArrayController pointer) - the RIP table for this topology
 Exported value: none
 Purpose: This method attaches this OS controller to the RIP table for this topology
 */
- (void)setRipEntryArray:(NSArrayController *)ripEntryArray
{
	if (ripEntryArray != CA_ripEntryArray)
		{
		[CA_ripEntryArray release];
		CA_ripEntryArray = [ripEntryArray retain];
		}
}

/*
 Method Name: setNetworkArray:
 Imported values:
 - (NSArrayController pointer) - the network array for the topology
 Exported value: none
 Purpose: This method attaches this OS controller to the network array
 */
- (void)setNetworkArray:(NSArrayController *)networkArray
{
	if (networkArray != CA_networkArray)
		{
		[CA_networkArray release];
		CA_networkArray = [networkArray retain];
		}
}


/*
 Method Name: setHostTableArray:
 Imported values:
 - (NSArrayController pointer) - the host table array for the topology
 Exported value: none
 Purpose: This method attaches this OS controller to the host table array
 */
// Added by Leong on 01/11/2005
- (void)setHostTableArray:(NSArrayController *)hostTableArray
{
	if (hostTableArray != CA_networkArray)
    {
		[CA_hostTableArray release];
		CA_hostTableArray = [hostTableArray retain];
    }
}

/* The following five methods are the accessors for the above mutators */
- (TerminalView *)view
{
	return [[CA_terminalView retain] autorelease];
}

- (NSManagedObject *)device
{
	return [[CA_device retain] autorelease];
}

- (id)delegate
{
	return [[CA_delegate retain] autorelease];
}

- (NSArrayController *)ripEntryArray
{
	return [[CA_ripEntryArray retain] autorelease];
}

- (NSArrayController *)networkArray
{
	return [[CA_networkArray retain] autorelease];
}

- (NSArrayController *)hostTableArray
{
	return [[CA_hostTableArray retain] autorelease];
}

/* The next three methods are just stubs for this abstract class */
- (void)showPrompt
{
	// Abstract stub
}

- (void)showCommandNotFound
{
	// Abstract stub
}

- (BOOL)sendData:(NSString *)data
{
	// Abstract stub
    return NO;
}

/*
 Method Name: showHistoryUp
 Imported values: none
 Exported value: none
 Purpose: This method replaces the edit area text with history (back)
 */
- (void)showHistoryUp
{
	if (CA_historyIndex > 0)
      {
		CA_historyIndex--;
		NSLog(@"historyIndex: %d, count: %d", CA_historyIndex, [CA_commandHistory count]);
		NSLog(@"History up %@ -> %@", CA_buffer, [CA_commandHistory objectAtIndex:CA_historyIndex]);
		[CA_terminalView replaceCharactersInRange:NSMakeRange(CA_editPos, [CA_buffer length])
                                     withString:[CA_commandHistory objectAtIndex:CA_historyIndex]];
		CA_buffer = [NSString stringWithString:[CA_commandHistory objectAtIndex:CA_historyIndex]];
		// move cursor to end
		CA_cursorPos = [CA_buffer length];
      }
}

/*
 Method Name: showHistoryDown
 Imported values: none
 Exported value: none
 Purpose: This method replaces the edit area text with history (forward)
 */
- (void)showHistoryDown
{
	if (CA_historyIndex < ( [CA_commandHistory count] - 1 ) )
      {
		CA_historyIndex++;
		NSLog(@"History down %@ -> %@", CA_buffer, [CA_commandHistory objectAtIndex:CA_historyIndex]);
		[CA_terminalView replaceCharactersInRange:NSMakeRange(CA_editPos, [CA_buffer length])
                                     withString:[CA_commandHistory objectAtIndex:CA_historyIndex]];
		CA_buffer = [NSString stringWithString:[CA_commandHistory objectAtIndex:CA_historyIndex]];
      }
	else if (CA_historyIndex == ( [CA_commandHistory count] - 1 ))
		{
		// Clear the buffer
		CA_historyIndex++;
		[CA_terminalView replaceCharactersInRange:NSMakeRange(CA_editPos, [CA_buffer length])
                                     withString:@""];
		CA_buffer = @"";
		}
	// move cursor to end
	CA_cursorPos = [CA_buffer length];
}

/*
 Method Name: parseInput
 Imported values: none
 Exported value: none
 Purpose: This method send commands to the appropriate state handler
 */
- (void)parseInput
{
	// tokenise the buffer
	NSArray *tokens = [CA_buffer componentsSeparatedByString:@" "];
	
	// Get the name of the method to call from the dictionary
	NSString *commandMethod = [CA_stateDictionary objectForKey:[NSNumber numberWithInt:CA_currentState]];
	
	// If there is a method that can be called, then call it
	if (commandMethod != nil)
    {
		[self callMethod:commandMethod withArguments:tokens];
    }
	else if (![CA_buffer isEqualToString:@""])
    {
		// Command not found and empty string not entered, so display a message
		[self showCommandNotFound];
    }
	// Show the prompt
	[self showPrompt];
}

/*
 Method Name: callMethod:withArguments (taken directly from iNetSim prototype)
 Imported values:
 - (NSString pointer)methodName - the name of the method to call
 - (NSArray pointer)args - the arguments of the command for which methodName is called
 Exported value: none
 Purpose: This method calls other methods as specified by methodName
 */
- (void)callMethod:(NSString *)methodName withArguments:(NSArray *)args
{
	SEL theSelector;
	NSMethodSignature *aSignature;
	
	theSelector = NSSelectorFromString(methodName);
	aSignature = [[self class] instanceMethodSignatureForSelector: theSelector];
	NSInvocation *anInvocation = [NSInvocation invocationWithMethodSignature: aSignature];
	[anInvocation setSelector: theSelector];
	[anInvocation setTarget: self];
	[anInvocation setArgument: &args atIndex: 2];
	[anInvocation invoke];
}


// Added on 16/10/2005 by Leong
- (void)setPort:(NSManagedObject *)aPort
{
	if (aPort != CA_port)
    {
		[CA_port release];
		CA_port = [aPort retain];
    }
}

// Added on 16/10/2005 by Leong
- (NSManagedObject *)port
{
    return [[CA_port retain] autorelease];
}


- (void)setRouterArrayController:(NSArrayController *)anArrayController
{
    if( CA_routerArrayController != anArrayController )
    {
        [CA_routerArrayController release];
        CA_routerArrayController = anArrayController;
    }
}


- (NSArray *)fetchRipTable
{
    NSManagedObjectContext *moc = [CA_ripEntryArray managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError *fetchError = nil;
    NSArray *fetchResults;
    
    @try
    {
        NSEntityDescription *entity  = [NSEntityDescription entityForName:@"RipEntry"
                                                   inManagedObjectContext:moc];
        [fetchRequest setEntity:entity];
        fetchResults = [moc executeFetchRequest:fetchRequest error:&fetchError];
    }
    @finally
    {
        [fetchRequest release];
    }
    return fetchResults;
}



- (void)pingProgressIndicator:(NSString *)aString
{
    int i;
    
    for( i = 0; i <  5; i++ )
    {
        [CA_terminalView appendString:aString];
    }
    
}


- (NSArray *)retrievePorts
{
    NSManagedObjectContext *moc = [CA_routerArrayController managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError *fetchError = nil;
    NSArray *fetchResults;
    
    @try
    {
        NSEntityDescription *entity  = [NSEntityDescription entityForName:@"Port"
                                                   inManagedObjectContext:moc];
        [fetchRequest setEntity:entity];
        fetchResults = [moc executeFetchRequest:fetchRequest error:&fetchError];
    }
    @finally
    {
        [fetchRequest release];
    }
    return fetchResults;
}


- (NSManagedObject *)retrievePortWithIp:(NSString *)ipAddress
{
    NSArray *ports = [self retrievePorts];
    NSEnumerator *portEnum = [ports objectEnumerator];
    NSManagedObject *port;
    NSManagedObject *tempPort;
    BOOL isFound = NO;
    
    while( (tempPort = [portEnum nextObject]) && !isFound )
    {
        if( [[tempPort valueForKey:@"ipAddress"] isEqualToString:ipAddress] )
        {
            port = tempPort;
            isFound = YES;
        }
        else
        {
            port = nil;
        }
    }
    return port;
}


- (NSString *)retriveGatewayForDevice:(NSManagedObject *)device
{
    return [device valueForKey:@"gateway"];
}

- (NSArray *)retriveRouters
{
    NSManagedObjectContext *moc = [CA_routerArrayController managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError *fetchError = nil;
    NSArray *fetchResults;
    
    @try
    {
        NSEntityDescription *entity  = [NSEntityDescription entityForName:@"Router"
                                                   inManagedObjectContext:moc];
        [fetchRequest setEntity:entity];
        fetchResults = [moc executeFetchRequest:fetchRequest error:&fetchError];
    }
    @finally
    {
        [fetchRequest release];
    }
    return fetchResults;
}


- (NSArray *)fetchRipNetwork
{
    NSManagedObjectContext *moc = [CA_networkArray managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError *fetchError = nil;
    NSArray *fetchResults;
    
    @try
    {
        NSEntityDescription *entity  = [NSEntityDescription entityForName:@"Network"
                                                   inManagedObjectContext:moc];
        [fetchRequest setEntity:entity];
        fetchResults = [moc executeFetchRequest:fetchRequest error:&fetchError];
    }
    @finally
    {
        [fetchRequest release];
    }
    return fetchResults;
}



@end
