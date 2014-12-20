//
//  DOSController.m
//  iNetSim
//
//  Created by James Hope on 6/10/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "DOSController.h"


@implementation DOSController

/*
 Default Constructor
 Imported values: none
 Exported value: address of new IOSController object
 Purpose: This constructor defines all the state dictionaries for DOS
 */
- (id)init
{
	[super init];
	
    /* Specify parsing methods for each state */
	CA_stateDictionary = [[NSDictionary alloc] initWithObjectsAndKeys: 
                                                    @"processCommands:", 
                                [NSNumber numberWithInt: CA_normalState], nil];
	
	/* specify methods that handle commands in user state 
		Help text updated 2005/05/29 by James Hope */
	CA_commandDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                       @"showDir:\\\\\tShow Directory listing", @"dir",
                       @"exitDOS:\\\\\tExit DOS", @"exit",
                      @"showHelp:\\\\\tDisplays command help", @"help",
                    @"showConfig:\\\\Displays IP configuration", @"ipconfig",
                      @"sendPing:\\\\\tSend echo messages", @"ping",
                        @"telnet:\\\\Starts a telnet session", @"telnet",
                          @"show:\\\\Used for debug purpose only", @"show",
                @"sendTracert:\\\\Trace route to destination", @"tracert", nil];
	
	
	/* Explanation of values above:
		the "\\\\" is a delimeter between the method and the help text */
	
	return self;
}

/*
 Method Name: boot
 Imported values: none
 Exported value: none
 Purpose: This method shows a DOS splash message
 */
- (void)boot
{
	[CA_terminalView appendString:@"iNetSim DOS Version 1.0\n\tCopyright (c) 2005. All rights reserved\n"];
	CA_currentState = CA_normalState;
	[self showPrompt];
}

/*
 Method Name: showPrompt
 Imported values: none
 Exported value: none
 Purpose: This method displays a pseudo DOS prompt (A drive)
 */
- (void)showPrompt
{
	[CA_terminalView appendString:@"\nA:\\> "];
	CA_editPos = [[CA_terminalView string] length];
	CA_cursorPos = 0;
}

/*
 Method Name: sendData
 Imported values:
 - (NSString Pointer)data - the information coming from the terminal view, which could be user input or
 control information.
 Exported value: (boolean) shouldEcho - specifies whether or not the terminal view should echo the typed key
 Purpose: This method closes the top level session for the current terminal
 */
- (BOOL)sendData:(NSString *)data
{
	BOOL shouldEcho = NO;
	
	// move the cursor to the correct position
	[CA_terminalView setSelectedRange:NSMakeRange(CA_editPos + CA_cursorPos, 0)];
	[CA_terminalView scrollRangeToVisible:NSMakeRange(CA_editPos + CA_cursorPos, 0)];
	
	if ([data isEqualToString:@"newline"])
    {
		// return or enter was pressed
		
		// add the typed command to history
		if (![CA_buffer isEqualToString:@""])
			{
			NSLog(@"Adding to command history - %@", CA_buffer);
			[CA_commandHistory addObject:[NSString stringWithString:CA_buffer]];
			CA_historyIndex = [CA_commandHistory count];
			}
    // the following line fixes an issue when the cursor is within the edit area, and
    // doesn't follow the output to the next prompt.
    [CA_terminalView setSelectedRange:NSMakeRange(CA_editPos + [CA_buffer length], 0)];
		[self parseInput];
		CA_buffer = @"";
    }
	else if ([data isEqualToString:@"backspace"])
    {
		// backspace was pressed
		// only allow this to do anything if the cursor isn't at the beginning of the edit area
		if (CA_cursorPos > 0)
			{
			// check where the cursor is
			if (CA_cursorPos < [CA_buffer length])
				{
				// cursor is somewhere inside the edit area
				CA_buffer = [[CA_buffer substringToIndex:CA_cursorPos - 1] 
          stringByAppendingString:[CA_buffer substringFromIndex:CA_cursorPos]];
				}
			else
				{
				// the cursor is at the end of the edit area so just remove the final character
				CA_buffer = [CA_buffer substringToIndex:CA_cursorPos - 1];
				}
			// decrement the cursor position
			CA_cursorPos--;
			shouldEcho = YES;
			}
    }
	else if ([data isEqualToString:@"leftarrow"])
      {
		// left arrow key was pressed
		// only allow the cursor to move left if the cursor is not at the beginning of the edit area
		if (CA_cursorPos > 0)
			{
			CA_cursorPos--;
			shouldEcho = YES;
			}
      }
	else if ([data isEqualToString:@"rightarrow"])
      {
		// right arrow key was pressed
		// only allow the cursor to move right if the cursor is not at the end of the edit area
		if (CA_cursorPos < [CA_buffer length])
			{
			CA_cursorPos++;
			shouldEcho = YES;
			}
      }
	else if ([data isEqualToString:@"uparrow"])
      {
		// up arrow key was pressed (move back through history)
		[self showHistoryUp];
      }
	else if ([data isEqualToString:@"downarrow"])
      {
		// down arrow key was pressed (move forward through history)
		[self showHistoryDown];
      }
	else
    {
		if (CA_cursorPos < [CA_buffer length])
        {
			CA_buffer = [[[CA_buffer substringToIndex:CA_cursorPos] stringByAppendingString:data]
		   stringByAppendingString: [CA_buffer substringFromIndex:CA_cursorPos]];
        }
		else
        {
			CA_buffer = [NSString stringWithString:[CA_buffer stringByAppendingString:data]];
        }
		CA_cursorPos += [data length];
		shouldEcho = YES;
    }
	[CA_buffer retain];
	
	return shouldEcho;
}

/*
 Method Name: showHelp
 Imported values: none
 Exported value: none
 Purpose: This method displays the help text for commands in the current state
 */
- (void)showHelp:(NSArray *)tokens
{
	int i;  // for loop index
	NSString *key; // key to get command help text
	for (i = 0; i < [CA_commandDict count]; i++)
    {
		key = [[CA_commandDict allKeys] objectAtIndex:i];
		[CA_terminalView appendString:@"\n  "];
		[CA_terminalView appendString:key];
		[CA_terminalView appendString:@"\t"];
		[CA_terminalView appendString:[[[CA_commandDict objectForKey: key] 
	  	componentsSeparatedByString: @"\\\\"] objectAtIndex: 1]];
    }
}

/*
 Method Name: processCommands
 Imported values:
 - (NSArray Pointer)tokens - the command line parameters entered with a command (including the command itself)
 Exported value: none
 Purpose: This method calls methods that have been defined for each command (taken from prototype code)
 */
- (void)processCommands:(NSArray *)tokens
{
	int i;
	/* Revised by James Hope 2005/05/27
	- Changed to allow whitespace to be entered before commands and to use new callMethod() */
	
	/* Find the method for the entered command
	- bug in NSString.stringByTrimmingCharactersInSet causes some problems when string start with spaces */
	NSString *enteredCommand = [[tokens objectAtIndex: 0] 
                              stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
	NSString *commandMethod;
	
	commandMethod = [[[CA_commandDict objectForKey: enteredCommand]
                              componentsSeparatedByString: @"\\\\"] objectAtIndex: 0];
	
	if (commandMethod != nil)
    {
		/* Command recognised so call the method that handles it */
		[self callMethod: commandMethod withArguments: tokens];
    }
	else
    {
		if (![enteredCommand isEqualToString: @""])
        {
			/* Command not white space and isn't recognised so display error message */
			[CA_terminalView appendString:@"\nBad command or file name"];
        }
    }
}

/*
 Method Name: showDir
 Imported values:
 - (NSArray Pointer)tokens - the command line parameters entered with a command (including the command itself)
 Exported value: none
 Purpose: This method displays a mock directory listing (uses hostname as volume serial number)
 */
- (void)showDir:(NSArray *)tokens
{
	[CA_terminalView appendString:@"\n\n Volume in drive A is "];
	[CA_terminalView appendString:[CA_device valueForKey:@"deviceName"]];
	[CA_terminalView appendString:@"\n Volume Serial Number is CCCE-34BA\n"];
	[CA_terminalView appendString:@" Directory of A:\\\n\n"];
	[CA_terminalView appendString:@"PING\tEXE\t\t\t24,576\t10/09/05\t22:13\n"];
	[CA_terminalView appendString:@"TRACERT\tEXE\t\t\t20,480\t10/09/05\t22:13\n"];
	[CA_terminalView appendString:@"TELNET\tEXE\t\t\t77,584\t10/09/05\t22:13\n"];
	[CA_terminalView appendString:@"\t\t3 file(s)\t\t  122,640 bytes\n"];
	[CA_terminalView appendString:@"\t\t0 dir(s)\t\t        0 bytes free\n"];
}

/*
 Method Name: exitDOS
 Imported values:
 - (NSArray Pointer)tokens - the command line parameters entered with a command (including the command itself)
 Exported value: none
 Purpose: This method shuts DOS down and ends the session
 */
- (void)exitDOS:(NSArray *)tokens
{
	[CA_delegate closeSession];
}

/*
 Method Name: telnet
 Imported values:
 - (NSArray Pointer)tokens - the command line parameters entered with a command (including the command itself)
 Exported value: none
 Purpose: This method starts a telnet session
 */
- (void)telnet:(NSArray *)tokens
{
	// This is spaghetti for testing. It needs to check the routing table first, and if
	// a hostname was supplied, it needs to check what the IP address is before looking
	// in the routing table.
	
	if ([tokens count] > 1)
    {
		[CA_terminalView appendString:@"\nConnecting to "];
		[CA_terminalView appendString:[tokens objectAtIndex:1]];
		[CA_terminalView appendString:@"...\n"];
		// for this dodged up version, we'll only accept hostnames
		if (![CA_delegate newTelnetSession:[tokens objectAtIndex:1]])
        {
			[CA_terminalView appendString:@"Connection failed.\n"];
        }
    }
	else
    {
		[CA_terminalView appendString:@"\nUsage: telnet [hostname|ipaddress]\n"];
    }
}


- (void)pingSuccessResponseFor:(NSString *)ipAddress
{
    NSString *temp;
    int i;
    
    for( i = 0; i < 4; i++ )
    {
        temp = [NSString stringWithFormat:@"Reply from %@: bytes=32 time=1ms TTL=64\n", 
            ipAddress];
        [CA_terminalView appendString:temp];
    }
    
    temp = [NSString stringWithFormat:@"\nPing statistics for %@:\n", ipAddress];
    [CA_terminalView appendString:temp];
    [CA_terminalView appendString:@"\tPackets: Sent = 4, Received = 4, Lost = 0 (0% loss), \n"];
    [CA_terminalView appendString:@"Approximate round trip times in milli-seconds:\n"];
    [CA_terminalView appendString:@"\tMinimum = 1ms, Maximum = 1ms, Average = 1ms\n\n"];
}


- (void)pingFailResponseFor:(NSString *)ipAddress
{
    NSString *temp;
    int i;
    
    for( i = 0; i < 4; i++ )
    {
        [CA_terminalView appendString:@"Request timed out.\n"];
    }
    temp = [NSString stringWithFormat:@"\nPing statistics for %@:\n", ipAddress];
    [CA_terminalView appendString:temp];
    [CA_terminalView appendString:@"\tPackets: Sent = 4, Received = 0, Lost = 4 (100% loss), \n"];
    [CA_terminalView appendString:@"Approximate round trip times in milli-seconds:\n"];
    [CA_terminalView appendString:@"\tMinimum = 0ms, Maximum = 0ms, Average = 0ms\n\n"];
}




- (BOOL)isIp:(NSString *)ipAddress withGateway:(NSString *)gateway inRipTable:(NSArray *)ripTable
{
    NSEnumerator *ripEnum = [ripTable objectEnumerator];
    NSManagedObject *ripEntry;
    NSManagedObject *device;
    BOOL isFound = NO;
    
    while( (ripEntry = [ripEnum nextObject]) && !isFound )
    {
        device = [self retrievePortWithIp:ipAddress];
        
        if( [[ripEntry valueForKeyPath:@"source.ipAddress"] isEqualToString:gateway] && 
            [[ripEntry valueForKeyPath:@"destination.ipAddress"] isEqualToString:ipAddress])
        {
            isFound = YES;
        }
        else
        {
            isFound = NO;
        }
    }
    
    return isFound;
    
}


- (BOOL)isIp:(NSString *)ipAddress fromNetworkOfDevice:(NSManagedObject *)router
{
    NSSet *ports = [router valueForKey:@"deviceports"];
    NSEnumerator *portEnum = [ports objectEnumerator];
    NSManagedObject *port;
    NSString *ipAddNetwork;
    NSString *routerNetwork;
    BOOL isFound = NO;
    
    ipAddNetwork = [self networkForIp:ipAddress];
    
    while( (port = [portEnum nextObject]) && !isFound )
    {
        NSLog(@"checking whether ip is from router's netowrks");
        if( [[port valueForKey:@"enabled"] boolValue] == YES )
        {
            routerNetwork = [self networkForIp:[port valueForKey:@"ipAddress"]];
            NSLog(@"ipAddNetwork = %@, routerNetwork = %@", ipAddNetwork, routerNetwork);
            if( [ipAddNetwork isEqualToString:routerNetwork] )
            {
                NSLog(@"destIp from networks owned by router.");
                isFound = YES;
            }
        }
    }
    return isFound;
}


- (void)showPingOption
{
    NSString *msg;
    msg = @"\nUsage : ping [-t] [-a] [-n count] [-l size] [-f] [-i TTL] [-v TOS]\n";
    [CA_terminalView appendString:msg];
    msg = @"\t\t\t [-r count] [-s count] [[-j host-list] | [-k host-list]]";
    [CA_terminalView appendString:msg];
    msg = @"\t\t\t [-w timeout] target_name\n";
    [CA_terminalView appendString:msg];
    
    msg = @"Options:\n";
    [CA_terminalView appendString:msg];
    msg = @"\t-t\t\t\t\t Ping the specified host until stopped.\n";
    [CA_terminalView appendString:msg];
    msg = @"\t\t\t\t\t To see statistics and continue - type Control-Break\n";
    [CA_terminalView appendString:msg];
    msg = @"\t\t\t\t\t To stop - type Control-C\n";
    [CA_terminalView appendString:msg];
    msg = @"\t-a\t\t\t\t Resolve address to hostnames.\n";
    [CA_terminalView appendString:msg];
    msg = @"\t-n count\t\t Number of echo requests to send.\n";
    [CA_terminalView appendString:msg];
    msg = @"\t-l size\t\t\t Send buffer size.\n";
    [CA_terminalView appendString:msg];
    msg = @"\t-f\t\t\t\t Set Don't Fragment flag in packet.\n";
    [CA_terminalView appendString:msg];
    msg = @"\t-i TTL\t\t\t Time To Live.\n";
    [CA_terminalView appendString:msg];
    msg = @"\t-v TOS\t\t\t Type of Service.\n";
    [CA_terminalView appendString:msg];
    msg = @"\t-r count\t\t Record route for count hops.\n";
    [CA_terminalView appendString:msg];
    msg = @"\t-s count\t\t Timestamp for count hops.\n";
    [CA_terminalView appendString:msg];
    msg = @"\t-j host-list\t Loose source route along host-list.\n";
    [CA_terminalView appendString:msg];
    msg = @"\t-k host-list\t Strict source route along host-list.\n";
    [CA_terminalView appendString:msg];
    msg = @"\t-w timeout\t\t Timeout in milliseconds to wait for each reply.\n";
    [CA_terminalView appendString:msg];
}


- (void)sendPing:(NSArray *)tokens
{
    if( [tokens count] == 2 && [self isValidIp:[tokens objectAtIndex:1]] )
    {
        NSString *temp;
        
        NSString *destIp;
        NSString *currentIp;
        NSManagedObject *destPort;
        NSManagedObject *currentPort;
        NSManagedObject *temp1;
        NSManagedObject *temp2;
        NSSet *ports;
        NSManagedObject *gateway;
        BOOL isSuccess = NO;
        BOOL isEth = NO;
        
        // Before ping get the latest Rip table.
        [self buildRipTable];
        gateway = [[self retrievePortWithIp:[CA_device valueForKey:@"gateway"]] valueForKey:@"deviceport"];
        
        NSArray *ripTable = [self fetchRipTable];
        
        // output msg to user indicating that the Ping is in progress.
        temp = [NSString stringWithFormat:@"\nPinging %@ with 32 bytes of data:\n\n", 
            [tokens objectAtIndex: 1]];
        [CA_terminalView appendString:temp];
        
        // Get all ports from current PC
        ports = [CA_device valueForKey:@"deviceports"];
        NSEnumerator *portEnum = [ports objectEnumerator];
        
        // Choose eth port from current PC and set currentIp to its ip address
        while( !isEth && (currentPort = [portEnum nextObject]) )
        {
            if( [[currentPort valueForKey:@"portType"] isEqualToString:@"Ethernet"] )
            {
                isEth = YES;
                NSLog(@"current port id eth port.");
                currentIp = [currentPort valueForKey:@"ipAddress"];
            }
        }
        
        // Get destination port for the given ipAddress
        destPort = [self retrievePortWithIp:[tokens objectAtIndex: 1]];
        destIp = [tokens objectAtIndex: 1];
        
        if( [self selectDestinationPort:currentPort] != nil )
        {
            // Self pinging - ping succes if ip address is set.
            // Ping gateway.
            if( [destIp isEqualToString:currentIp] ||
                [destIp isEqualToString:[CA_device valueForKey:@"gateway"]])
            {
                NSLog(@"CurrentIp = %@", currentIp);
                [self pingSuccessResponseFor:[tokens objectAtIndex: 1]];
                
                isSuccess = YES; 
            }
            // Pinging devices from networks owned by the router(gateway of PC)
            else if( [self isIp:destIp fromNetworkOfDevice:gateway] &&
                     [self isIp:destIp inRipTable:[gateway valueForKey:@"ripTable"]] )
            {
                NSLog(@"CurrentIp = %@", currentIp);
                // Check whether ip setting for PC and Router are set properly.
                if( [self isIp:currentIp withGateway:[CA_device valueForKey:@"gateway"] inRipTable:ripTable] )
                {
                    [self pingSuccessResponseFor:[tokens objectAtIndex: 1]];
                    isSuccess = YES;
                }
            }
            // Pinging devices from different network
            else 
            {
                NSLog(@"Access different networks..");
                int i;
                NSArray *allRouter = [self retriveRouters];
                NSEnumerator *ripEnum = [ripTable objectEnumerator];
                temp1 = [self retrieveSourceOfIp:destIp inTable:ripTable];
                NSManagedObject *port;
                port = [self retrievePortWithIp:[CA_device valueForKey:@"gateway"]];
                
                
                
                    while( [ripEnum nextObject] && !isSuccess )
                    {
                        if( [self selectDestinationPort:temp1] != nil )
                        {
                            NSLog(@"[CA_device valueForKey:@gateway] = %@", [CA_device valueForKey:@"gateway"]);
                            NSLog(@"[temp1 valueForKey:@ipAddress] = %@", [[temp1 valueForKey:@"ipAddress"] className]);
                            if( [self isIp:[temp1 valueForKey:@"ipAddress"] inRipNetworkOfDevice:[port valueForKey:@"deviceport"]] )
                            {
                                [self pingSuccessResponseFor:[tokens objectAtIndex: 1]];
                                isSuccess = YES;
                            }
                            else
                            {
                                if(temp1 == nil)
                                {
                                    temp2 = [self retrieveSourceOfIp:destIp inTable:ripTable];
                                }
                                else
                                {
                                    temp2 = [self retrieveSourceOfIp:[temp1 valueForKey:@"ipAddress"] inTable:ripTable];
                                }
                                temp1 = temp2;
                            }
                        }
                        
                    }
                
                    
                    
                //}
            }
            
        }
        
        if( !isSuccess )
        {
            [self pingFailResponseFor:[tokens objectAtIndex: 1]];
        }
    }
    else if( ([tokens count] == 2) && ![self isValidIp:[tokens objectAtIndex:1]] )
    {
        [self showInvalidIpMsgForDOS:[tokens objectAtIndex:1]];
    }
    else if( [tokens count] == 1 )
    {
        [self showPingOption];
    }
    else
    {
        [self showCommandNotFound];
    }
}


@end
