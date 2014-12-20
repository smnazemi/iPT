//
//  IOSPrivMode.m
//  iNetSim
//
//  Created by James Hope on 30/10/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "IOSController.h"


@implementation IOSController(IOSPrivMode)

/*
 Method Name: enterPriv
 Imported values:
 - (NSArray Pointer)tokens - the command line parameters entered with a command (including the command itself)
 Exported value: none
 Purpose: This method turns on privileged EXEC
 */
- (void)enterPriv:(NSArray *)tokens
{
  if ([tokens containsObject:@"?"])
    {
    [CA_terminalView appendString:@"\n  <cr>"];
    }
  else if ([tokens count] == 1)
		{
		// check if the enable secret is set first
		if ([[CA_device valueForKey:@"enableSecret"] length] == 0)
			{
			// no password, so don't ask for one
			CA_currentState = CA_privState;
			}
		else
			{
			// there is a password, so ask for it
			CA_currentState = CA_enterPrivWithSecretState;
			}
		}
  else
    {
    [self showCommandNotFound];
    }
}

/*
 Method Name: exitPriv
 Imported values:
 - (NSArray Pointer)tokens - the command line parameters entered with a command (including the command itself)
 Exported value: none
 Purpose: This method switches off privileged EXEC
 */
- (void)exitPriv:(NSArray *)tokens
{
	CA_currentState = CA_userState;
}

/*
 Method Name: setEnablePassword
 Imported values:
 - (NSArray Pointer)tokens - the command line parameters entered with a command (including the command itself)
 Exported value: none
 Purpose: This method handles setting the enable secret
 */
- (void)setEnablePassword:(NSArray *)tokens
{
  if (CA_currentState == CA_enableSecretSetState)
    {
    [CA_device setValue:[tokens objectAtIndex:0] forKey:@"enableSecret"];
    CA_currentState = CA_privState;
    }
  else
    {
    if ([tokens containsObject:@"?"])
      {
      switch ([tokens indexOfObject:@"?"])
        {
        case 1:
          [CA_terminalView appendString:@"\n  secret   Set the enable secret"];
          [CA_terminalView appendString:@"\n  <cr>"];
          break;
        case 2:
          if ([[tokens objectAtIndex:1] isEqualToString:@"secret"])
            {
            [CA_terminalView appendString:@"\n  <password>   The new enable secret"];
            }
          // don't break here, because we still want <cr> to be displayed.
        default:
          [CA_terminalView appendString:@"\n  <cr>"];
        }
      }
    else if (([tokens count] == 1) || ([[tokens objectAtIndex:1] length] == 0))
      {
      // do nothing, because we are in Priv EXEC already
      }
    else if ((([tokens count] == 2) || ([[tokens objectAtIndex:2] length] == 0))
             && [[tokens objectAtIndex:1] isEqualToString:@"secret"])
      {
      // get ready to prompt user for password
      CA_currentState = CA_enableSecretSetState;
      }
    else if ((([tokens count] == 3) || ([[tokens objectAtIndex:3] length] == 0))
             && [[tokens objectAtIndex:1] isEqualToString:@"secret"])
      {
      // password has been specified, so set it.
      [CA_device setValue:[tokens objectAtIndex:2] forKey:@"enableSecret"];
      }
    else
      {
      [self showCommandNotFound];
      }
    }
}

@end
