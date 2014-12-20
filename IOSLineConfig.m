//
//  IOSLineConfig.m
//  iNetSim
//
//  Created by James Hope on 23/10/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "IOSController.h"


@implementation IOSController(IOSLineConfig)

/*
 Method Name: enterLineConfig
 Imported values:
 - (NSArray Pointer)tokens - the command line parameters entered with a command (including the command itself)
 Exported value: none
 Purpose: This method turns on line configuration mode
 */
- (void)enterLineConfig:(NSArray *)tokens
{
	// check parameters
	if ([tokens containsObject:@"?"])
		{
		// user has asked for help
		switch ([tokens indexOfObject:@"?"])
			{
			case 1:
				// note that commented out commands aren't implemented in this version of iNetSim
				//[CA_terminalView appendString:@"\n  <0-198>  First Line number"];
				// [CA_terminalView appendString:@"\n  aux      Auxiliary line"];
				[CA_terminalView appendString:@"\n  console  Primary terminal line"];
				//[CA_terminalView appendString:@"\n  tty      Terminal controller"];
				[CA_terminalView appendString:@"\n  vty      Virtual terminal"];
				//[CA_terminalView appendString:@"\n  x/y      Slot/Port for Modems"];
				//[CA_terminalView appendString:@"\n  x/y/z    Slot/Subslot/Port for Modems"];
				[CA_terminalView appendString:@"\n"];
				break;
			case 2:
				[CA_terminalView appendString:@"\n  <0-0>  First Line number\n"];
				break;
			case 3:
				[CA_terminalView appendString:@"\n  <0-0> Last Line number\n"];
				break;
			default:
				[CA_terminalView appendString:@"\n  <cr>\n"];
			}
		}
	else
		{
		if ([tokens count] < 4)
			{
			[CA_terminalView appendString:@"\n% Imcomplete command"];
			}
		else
			{
			if ([[tokens objectAtIndex:1] isEqualToString:@"vty"])
				{
				CA_currentState = CA_vtyLineConfigState;
				}
			else if ([[tokens objectAtIndex:1] isEqualToString:@"console"])
				{
				CA_currentState = CA_consoleLineConfigState;
				}
			else
				{
				[self showCommandNotFound];
				}
			}
		}
}

/*
 Method Name: lineConfigLogin
 Imported values:
 - (NSArray Pointer)tokens - the command line parameters entered with a command (including the command itself)
 Exported value: none
 Purpose: stub
 */
- (void)lineConfigLogin:(NSArray *)tokens
{
	// This actually does nothing in iNetSim - just put in for completeness
   
   // check for help parameter, and display "<cr>" if present
   if ([tokens containsObject:@"?"])
      {
      [CA_terminalView appendString:@"\n  <cr>\n"];
      }
}

/*
 Method Name: lineConfigPassword
 Imported values:
 - (NSArray Pointer)tokens - the command line parameters entered with a command (including the command itself)
 Exported value: none
 Purpose: This method prompts the user for a new password
 */
- (void)lineConfigPassword:(NSArray *)tokens
{
   // check for help parameter, and display "<cr>" if present
   if ([tokens containsObject:@"?"])
      {
      [CA_terminalView appendString:@"\n  <cr>\n"];
      }
   else if (([tokens count] == 1) || ([[tokens objectAtIndex:1] length] == 0))
		{
		if (CA_currentState == CA_consoleLineConfigState)
			{
			CA_currentState = CA_lineConfigConsolePasswordSetState;
			}
		else if (CA_currentState == CA_vtyLineConfigState)
			{
			CA_currentState = CA_lineConfigVtyPasswordSetState;
			}
		}
	else
		{
		[self showCommandNotFound];
		}
}

/*
 Method Name: lineConfigSetPassword
 Imported values:
 - (NSArray Pointer)tokens - the command line parameters entered with a command (including the command itself)
 Exported value: none
 Purpose: This method sets the passwords in the device for console/vty
 */
- (void)lineConfigSetPassword:(NSArray *)tokens
{
   // check password
   if ( [[tokens objectAtIndex:0] isEqualToString:@"iddqd"] )
      {
      [CA_terminalView appendString:@"\nThis is not doom!\n"];
      }
	// This can set the password for console or vty, depending on the current state
	if (CA_currentState == CA_lineConfigConsolePasswordSetState)
		{
		[CA_device setValue:[tokens objectAtIndex:0] forKey:@"consolePassword"];
		CA_currentState = CA_consoleLineConfigState;
		}
	else if (CA_currentState == CA_lineConfigVtyPasswordSetState)
		{
		[CA_device setValue:[tokens objectAtIndex:0] forKey:@"vtyPassword"];
		CA_currentState = CA_vtyLineConfigState;
		}
}

@end
