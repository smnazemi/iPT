//
//  IOSController.m
//  iNetSim
//
//  Created by James Hope on 6/10/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "IOSController.h"



@implementation IOSController

/*
 Default Constructor
 Imported values: none
 Exported value: address of new IOSController object
 Purpose: This constructor defines all the state dictionaries for the IOS
 */
- (id)init
{
	[super init];
		
		/* Specify parsing methods for each state */
		CA_stateDictionary = [[NSDictionary alloc] initWithObjectsAndKeys: 
			@"bootUp:", [NSNumber numberWithInt: CA_bootState],
			@"processCommands:", [NSNumber numberWithInt: CA_userState],
			@"processCommands:", [NSNumber numberWithInt: CA_privState],
			@"configureMode:", [NSNumber numberWithInt: CA_configModeState],
			@"processCommands:", [NSNumber numberWithInt: CA_configState], 
			@"processCommands:", [NSNumber numberWithInt: CA_serialConfigState],
			@"processCommands:", [NSNumber numberWithInt: CA_ethernetConfigState],
			@"processCommands:", [NSNumber numberWithInt: CA_routerConfigState],
			@"processCommands:", [NSNumber numberWithInt: CA_routerRipConfigState],
			@"processCommands:", [NSNumber numberWithInt: CA_vtyLineConfigState],
			@"processCommands:", [NSNumber numberWithInt: CA_consoleLineConfigState],
			@"lineConfigSetPassword:", [NSNumber numberWithInt: CA_lineConfigConsolePasswordSetState],
			@"lineConfigSetPassword:", [NSNumber numberWithInt: CA_lineConfigVtyPasswordSetState],
			@"setEnablePassword:", [NSNumber numberWithInt: CA_enableSecretSetState],
			@"checkPassword:", [NSNumber numberWithInt: CA_enterPrivWithSecretState],
			@"checkPassword:", [NSNumber numberWithInt: CA_bootWithPasswordState],
			@"checkPassword:", [NSNumber numberWithInt: CA_telnetWithPasswordState],
			nil];
		
		/* specify methods that handle commands in user state */
		CA_userDict = [[NSDictionary alloc] initWithObjectsAndKeys:
			@"enterPriv:\\\\\tTurn on privileged commands", @"enable",
			@"exitExec:\\\\\t\tExit from the EXEC", @"exit",
			@"exitExec:\\\\\tExit from the EXEC", @"logout",
			@"sendPing:\\\\\t\tSend echo messages", @"ping",
			@"show:\\\\\t\tShow running system information", @"show",
			@"sendTraceroute:\\\\Trace route to destination", @"traceroute", nil];
		
		CA_privDict = [[NSDictionary alloc] initWithObjectsAndKeys:
			@"configureMode:\\\\\tEnter configuration mode", @"configure",
			@"notImplemented:\\\\\t\tCopy from one file to another", @"copy",
			@"exitPriv:\\\\\tDisable privileged mode", @"disable",
			@"setEnablePassword:\\\\\tTurn on privileged commands", @"enable",
			@"notImplemented:\\\\\t\tErase a filesystem", @"erase",
			@"exitExec:\\\\\t\tExit from the EXEC", @"exit",
			@"exitExec:\\\\\tExit from the EXEC", @"logout",
			@"sendPing:\\\\\t\tSend echo messages", @"ping",
			@"reloadDevice:\\\\\tHalt and perform a cold restart", @"reload",
			@"show:\\\\\t\tShow running system information", @"show",
			@"sendTraceroute:\\\\Trace route to destination", @"traceroute",
			@"notImplemented:\\\\\t\tConfigure VLAN parameters", @"vlan",
			@"telnet:\\\\\tOpen a telnet connection", @"telnet",
			@"notImplemented:\\\\\t\tWrite running configuration to memory, network, or terminal", @"write", nil];
		
		CA_configDict = [[NSDictionary alloc] initWithObjectsAndKeys:
			@"notImplemented:\\\\\tEnter configuration mode", @"cdp",
			@"exitConfig:\\\\\tExit from configure mode", @"end",
			@"exitConfig:\\\\\tExit from configure mode", @"exit",
			@"setHostname:\\\\Set system's network name", @"hostname",
			@"enterIfConfig:\\\\Select an interface to configure", @"interface",
			@"globalIpConfig:\\\\\tGlobal IP configuration subcommands", @"ip",
			@"enterRouterConfig:\\\\Enable a router process", @"router",
			@"enterLineConfig:\\\\\tConfigure a terminal line", @"line",
			@"notImplemented:\\\\\tConfigure a terminal line", @"line",
			@"notImplemented:\\\\\tNegate a command or set its defaults", @"no",
			@"notImplemented:\\\\\tVlan commands", @"vlan", nil];
    
    
    CA_serialConfigDict = [[NSDictionary alloc] initWithObjectsAndKeys:
			@"notImplemented:\\\\\tEnter configuration mode", @"cdp",
			@"setClockRate:\\\\\tConfigure serial interface clock", @"clock",
			@"enterConfig:\\\\\tExit from interface configure mode", @"exit",
			@"ipConfig:\\\\\tInterface Internet Protocol config commands", @"ip",
			@"negateCmd:\\\\\tNegate a command or set its defaults", @"no",
			@"shutdownPort:\\\\Shutdown the selected interface", @"shutdown",
			nil];
    
    CA_ethernetConfigDict = [[NSDictionary alloc] initWithObjectsAndKeys:
			@"notImplemented:\\\\\t\tEnter configuration mode", @"cdp",
			@"setSpeed:\\\\\t\tConfigure speed operation", @"speed",
			@"enterConfig:\\\\\t\tExit from interface configure mode", @"exit",
			@"setMacAddress:\\\\Manually set interface MAC address", @"mac-address",
			@"ipConfig:\\\\\t\tInterface Internet Protocol config commands", @"ip",
			@"negateCmd:\\\\\t\tNegate a command or set its defaults", @"no",
			@"shutdownPort:\\\\\tShutdown the selected interface", @"shutdown",
			nil];
		
    CA_routerConfigDict = [[NSDictionary alloc] initWithObjectsAndKeys:
		 @"rip:\\\\\tRouting Information Protocol (RIP)", @"rip", nil];
		    
    CA_routerRipConfigDict = [[NSDictionary alloc] initWithObjectsAndKeys:
			@"network:\\\\\tEnable routing on an IP network", @"network",
			@"enterConfig:\\\\\tExit Rip Configuration mode", @"exit",
			nil];
		
		CA_lineConfigDict = [[NSDictionary alloc] initWithObjectsAndKeys:
			@"enterConfig:\\\\\t\tExit from line configuration mode", @"exit",
			@"lineConfigLogin:\\\\\t\tEnable password checking", @"login",
			@"lineConfigPassword:\\\\\tSet a password", @"password",
			nil];
		
		/* Explanation of values above:
			the "\\\\" is a delimeter between the method and the help text */
		
		return self;
}

/*
 Method Name: boot
 Imported values: none
 Exported value: none
 Purpose: This method simulates booting the IOS
 */
- (void)boot
{
	// TODO: display boot information, including ports, etc.
	
	// check for password on console
	if ([[CA_device valueForKey:@"consolePassword"] length] == 0)
		{
		CA_currentState = CA_bootState;
		}
	else
		{
		// need to prompt for a password
		[CA_terminalView appendString:@"\n\nUser Access Verification\n"];
		CA_currentState = CA_bootWithPasswordState;
		}
	[self showPrompt];
}

/*
 Method Name: loginVty
 Imported values: none
 Exported value: none
 Purpose: This method simulates telnetting into the IOS
 */
- (void)loginVty
{
	if ([[CA_device valueForKey:@"vtyPassword"] length] == 0)
		{
		// disallow remote login without password set
		[CA_terminalView appendString:@"\n\nPassword required, but none set\n"];
		[CA_delegate closeSession];
		}
	else
		{
		// need to prompt for a password
		[CA_terminalView appendString:@"\n\nUser Access Verification\n"];
		CA_currentState = CA_telnetWithPasswordState;
		[self showPrompt];
		}
}

/*
 Method Name: showPrompt
 Imported values: none
 Exported value: none
 Purpose: This method displays the appropriate prompt for the current EXEC
 */
- (void)showPrompt
{
	[CA_terminalView appendString:@"\n"];
	switch (CA_currentState)
    {
		case CA_bootState:
            [CA_terminalView appendString:@"\n\nRouter Con0 is now available\n"];
			[CA_terminalView appendString:@"\n\nPress RETURN to get started!\n\n"];
			CA_currentState = CA_userState;
			break;
		case CA_userState:
			[CA_terminalView appendString:[CA_device valueForKey:@"deviceName"]];
			[CA_terminalView appendString:@">"];
			break;
		case CA_privState:
			[CA_terminalView appendString:[CA_device valueForKey:@"deviceName"]];
			[CA_terminalView appendString:@"#"];
			break;
		case CA_configModeState:
			[CA_terminalView appendString:@"Configuring from terminal, memory, or network [terminal]? "];
			break;
		case CA_configState:
			[CA_terminalView appendString:[CA_device valueForKey:@"deviceName"]];
			[CA_terminalView appendString:@"(config)#"];
	    break;
		case CA_serialConfigState:
      [CA_terminalView appendString:[CA_device valueForKey:@"deviceName"]];
			[CA_terminalView appendString:@"(config-if)#"];
			break;
    case CA_ethernetConfigState:
      [CA_terminalView appendString:[CA_device valueForKey:@"deviceName"]];
			[CA_terminalView appendString:@"(config-if)#"];
			break;
    case CA_routerRipConfigState:
      [CA_terminalView appendString:[CA_device valueForKey:@"deviceName"]];
			[CA_terminalView appendString:@"(config-router)#"];
		  break;
		case CA_vtyLineConfigState: case CA_consoleLineConfigState:
			[CA_terminalView appendString:[CA_device valueForKey:@"deviceName"]];
			[CA_terminalView appendString:@"(config-line)#"];
			break;
		case CA_offState:
			// no prompt for this state
			break;
		case CA_enableSecretSetState:
			[CA_terminalView appendString:@"Enter secret: "];
			break;
	  case CA_enterPrivWithSecretState: case CA_lineConfigConsolePasswordSetState:
		case CA_lineConfigVtyPasswordSetState: case CA_bootWithPasswordState:
		case CA_telnetWithPasswordState:
			[CA_terminalView appendString:@"Password: "];
			break;
		default:
			[CA_terminalView appendString:@"Unknown State... must restart"];
			[self boot];
    }
	// set the position in the string of where the input must start (edit area)
	CA_editPos = [[CA_terminalView string] length];
	// set cursor position to 0 characters after start of edit area
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
	else if ([data isEqualToString:@"?"])
    {
		// the help shortcut (?) was typed
		[self displayHelp];
    }
	else if ([data isEqualToString:@"tab"])
    {
		// the tab key was pressed
		[self tabComplete];
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
		// another key was typed, so add it to the string
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
 Method Name: displayHelp
 Imported values: none
 Exported value: none
 Purpose: This method displays the help text for commands in the current state
 */
- (void)displayHelp
{
	int i;  // for loop index
	NSString *key; // key to get command help text
	NSDictionary *tempDict;
	NSString *oldBuffer = [[NSString stringWithString:CA_buffer] autorelease];
	NSString *stateName = @"";
	
	// find the reference for the appropriate state dictionary if only '?' was typed
	if ([CA_buffer isEqualToString:@""])
    {
		switch (CA_currentState)
			{
			case CA_userState:
				tempDict = CA_userDict;
				stateName = @"Exec commands:\n";
				break;
			case CA_privState:
				tempDict = CA_privDict;
				stateName = @"Exec commands:\n";
				break;
			case CA_configState:
				tempDict = CA_configDict;
				stateName = @"Configure commands:\n";
				break;
			case CA_serialConfigState:
				tempDict = CA_serialConfigDict;
				break;
			case CA_ethernetConfigState:
				tempDict = CA_ethernetConfigDict;
				break;
			case CA_routerConfigState:
				tempDict = CA_routerConfigDict;
				break;
			case CA_routerRipConfigState:
				tempDict = CA_routerRipConfigDict;
				break;
			case CA_vtyLineConfigState: case CA_consoleLineConfigState:
				tempDict = CA_lineConfigDict;
				stateName = @"Line configuration commands:\n";
				break;
			default:
				tempDict = nil;
			}
		
		// display the commands and their help text
		if (tempDict != nil)
			{
			[CA_terminalView appendString:@"?\n"];
			[CA_terminalView appendString:stateName];
			for (i = 0; i < [tempDict count]; i++)
				{
				key = [[tempDict allKeys] objectAtIndex:i];
				[CA_terminalView appendString:@"  "];
				[CA_terminalView appendString:key];
				[CA_terminalView appendString:@"\t"];
				[CA_terminalView appendString:[[[tempDict objectForKey: key] 
				  	componentsSeparatedByString: @"\\\\"] objectAtIndex: 1]];
				[CA_terminalView appendString:@"\n"];
				}
			
			[self showPrompt];
			}
    }
	else
    {
		// something other than '?' was typed so pass the command on as if it was entered, and let it
		// display the help instead
		CA_buffer = [CA_buffer stringByAppendingString:@"?"];
		// show it in the terminal view
		[CA_terminalView appendString:@"?"];
		[self parseInput];
    }
	// reset everything and redisplay the queried text like IOS does
	CA_buffer = [NSString stringWithString:oldBuffer];
	[CA_terminalView appendString:CA_buffer];
	CA_cursorPos = [CA_buffer length];
}

/*
 Method Name: showCommandNotFound
 Imported values: none
 Exported value: none
 Purpose: This method shows the error message for errors in commands (note: it must be modified
                                                                      to behave in the same way that IOS does - this code is temporary)
 */
- (void)showCommandNotFound
{
	[CA_terminalView appendString:@"\n% Invalid input detected"];
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
	
	switch (CA_currentState)
    {
		case CA_userState:
			commandMethod = [[[CA_userDict objectForKey: enteredCommand]
                              componentsSeparatedByString: @"\\\\"] objectAtIndex: 0];
			break;
		case CA_privState:
			commandMethod = [[[CA_privDict objectForKey: enteredCommand]
                              componentsSeparatedByString: @"\\\\"] objectAtIndex: 0];
			break;
		case CA_configState:
			commandMethod = [[[CA_configDict objectForKey: enteredCommand]
                              componentsSeparatedByString: @"\\\\"] objectAtIndex: 0];
      break;
    case CA_serialConfigState:
			commandMethod = [[[CA_serialConfigDict objectForKey: enteredCommand]
                              componentsSeparatedByString: @"\\\\"] objectAtIndex: 0];
      break;
    case CA_ethernetConfigState:
			commandMethod = [[[CA_ethernetConfigDict objectForKey: enteredCommand]
                              componentsSeparatedByString: @"\\\\"] objectAtIndex: 0];
      break;
    case CA_routerRipConfigState:
      commandMethod = [[[CA_routerRipConfigDict objectForKey:enteredCommand]
                              componentsSeparatedByString: @"\\\\"] objectAtIndex: 0];
      break; 
    case CA_routerConfigState:
      commandMethod = [[[CA_routerConfigDict objectForKey:enteredCommand]
                              componentsSeparatedByString: @"\\\\"] objectAtIndex: 0];
			break;
		case CA_vtyLineConfigState: case CA_consoleLineConfigState:
			commandMethod = [[[CA_lineConfigDict objectForKey:enteredCommand]
                              componentsSeparatedByString: @"\\\\"] objectAtIndex: 0];
			break;
		default:
			commandMethod = nil;
    }
	
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
			[self showCommandNotFound];
			}
    }
}

/*
 Method Name: notImplemented
 Imported values:
 - (NSArray Pointer)tokens - the command line parameters entered with a command (including the command itself)
 Exported value: none
 Purpose: This method is used for commands that have no implementation in iNetSim (if they are not needed for
          simulaiton or won't be implemented yet).
 */
- (void)notImplemented:(NSArray *)tokens
{
	[CA_terminalView appendString:@"\n% Not implemented\n"];
}

// Added by Leong
// This method simulates interface configuration mode.
- (void)enterIfConfig:(NSArray *)tokens
{
	NSSet *availablePorts;
	availablePorts = [CA_device valueForKey:@"deviceports"];
	// Get all available ports from selected device.
	
	NSEnumerator *portEnum = [availablePorts objectEnumerator];
	NSManagedObject *port;
	BOOL isEnded = NO;  // Used in while loop, exist from the loop when port is found.
	
	if( [tokens count] == 2 )
    {
		while( (port = [portEnum nextObject]) && !isEnded )
			{
			if( [[port valueForKey:@"name"] isEqualToString:[tokens objectAtIndex:1]] )
				{
				if( [[port valueForKey:@"portType"] isEqualToString:@"Serial"] )
					{
					CA_currentState = CA_serialConfigState;
					}
				else if ( [[port valueForKey:@"portType"] isEqualToString:@"Ethernet"] )
					{
					CA_currentState = CA_ethernetConfigState;
					}
				[self setPort:port];
				isEnded = YES;
				}
			}
		
		if( isEnded == NO )
			{
			[CA_terminalView appendString:@"\n% Invalid input detected at ...\n\n"];
			}
    }
	else if( [tokens count] < 2 )
    {
		[CA_terminalView appendString:@"\n% Command not complete.\n\n"];
    }
	
}


- (void)enterRouterConfig:(NSArray *)tokens
{
	if( ([tokens count] == 2) && ([[tokens objectAtIndex:1] isEqualToString:@"rip"]) )
    {
		CA_currentState = CA_routerRipConfigState;
    }
	else if( [tokens count] < 2 )
    {
		[CA_terminalView appendString:@"\n% Command not complete.\n\n"];
    }
}

/*
 Method Name: exitExec
 Imported values:
 - (NSArray Pointer)tokens - the command line parameters entered with a command (including the command itself)
 Exported value: none
 Purpose: This method shuts IOS down and ends the session
 */
- (void)exitExec:(NSArray *)tokens
{
	// display shutdown text
	[CA_terminalView appendString:@"\n\n\n\n\n\n\n\n"];
	[CA_terminalView appendString:[CA_device valueForKey:@"deviceName"]];
	[CA_terminalView appendString:@" con0 is now available\n\n\n\n\n\n"];
	CA_currentState = CA_offState;
	// tell the controller to close this session
	[CA_delegate closeSession];
}

/*
 Method Name: reloadDevice
 Imported values:
 - (NSArray Pointer)tokens - the command line parameters entered with a command (including the command itself)
 Exported value: none
 Purpose: This method simulates a device reload
 */
- (void)reloadDevice:(NSArray *)tokens
{
	[CA_terminalView appendString:@"\n\n%SYS-5-RELOAD: Reload requested by console.\n\n"];
	[self boot];
}

/*
 Method Name: setHostname
 Imported values:
 - (NSArray Pointer)tokens - the command line parameters entered with a command (including the command itself)
 Exported value: none
 Purpose: This method allows the user to change the hostname of the device
 */
- (void)setHostname:(NSArray *)tokens
{
	
	if ([tokens count] < 2)
    {
		// not enough parameters were entered so display an error message
		[CA_terminalView appendString:@"\n% Incomplete command\n\n"];
    }
	else if ([tokens count] > 2)
    {
		// too many parameneters were entered - also not good so display an error message
		/*for (i = 0; i < CA_promptLength + [[tokens objectAtIndex: 0] length] + [[tokens objectAtIndex: 1] length] + 2; i++)
    {
			[CA_terminal print: @" "];
    }
		[CA_terminal print: @"^\n"];
		[CA_terminal print: @"% Invalid input detected at '^' marker.\n\n"];*/
		[CA_terminalView appendString:@"\n\nbad input --- note, must fix this error message!!\n"];
    }
	else
    {
		// all is good, so change the value of the device in the model entity (change reflected on every binding)
		[CA_device setValue:[tokens objectAtIndex: 1] forKey:@"deviceName"];
    }
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
		[CA_terminalView appendString:@"\nTrying "];
		[CA_terminalView appendString:[tokens objectAtIndex:1]];
		[CA_terminalView appendString:@"...\n"];
		// for this dodged up version, we'll only accept hostnames
		if (![CA_delegate newTelnetSession:[tokens objectAtIndex:1]])
			{
			[CA_terminalView appendString:@"% Destination unreachable; gateway or host down.\n"];
			}
    }
	else
    {
		[CA_terminalView appendString:@"\nUsage: telnet [hostname|ipaddress]\n"];
    }
}

/*
 Method Name: checkPassword
 Imported values:
 - (NSArray Pointer)tokens - the command line parameters entered with a command (including the command itself)
 Exported value: none
 Purpose: This method handles asking for passwords
 Notes: the passwords are echoed to the screen. This is for accessibility purposes
 */
- (void)checkPassword:(NSArray *)tokens
{
	static tryCount = 0;
	
	if (tryCount == 2)
		{
		[CA_terminalView appendString:@"\n% Password incorrect"];
		if (CA_currentState == CA_enterPrivWithSecretState)
			{
			CA_currentState = CA_userState;
			}
		else
			{
			// This would only be when logging into the router, so close the session
			[CA_delegate closeSession];
			}
		tryCount = 0;
		}
	else
		{
		if ((CA_currentState == CA_enterPrivWithSecretState) &&
				[[CA_device valueForKey:@"enableSecret"] isEqualToString:[tokens objectAtIndex:0]])
			{
			CA_currentState = CA_privState;	
			tryCount = 0;
			}
		else if (((CA_currentState == CA_bootWithPasswordState) &&
						 [[CA_device valueForKey:@"consolePassword"] isEqualToString:[tokens objectAtIndex:0]])
						 || ((CA_currentState == CA_telnetWithPasswordState) &&
									[[CA_device valueForKey:@"vtyPassword"] isEqualToString:[tokens objectAtIndex:0]]))
			{
			CA_currentState = CA_userState;
			tryCount = 0;
			}
		else
			{
			tryCount++;
			}
		}
}










@end
