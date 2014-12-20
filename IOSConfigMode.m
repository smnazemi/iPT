//
//  IOSConfigMode.m
//  iNetSim
//
//  Created by James Hope on 25/10/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "IOSController.h"


@implementation IOSController(IOSConfigMode)

/*
 Method Name: configureMode
 Imported values:
 - (NSArray Pointer)tokens - the command line parameters entered with a command (including the command itself)
 Exported value: none
 Purpose: This method asks the user which configure mode to enter
 */
- (void)configureMode:(NSArray *)tokens
{
   /*
	 This method is called when in priv state or config mode state. When called in priv state,
	 and there is no command line parameters, then switch to config mode state. If there are
	 parameters, check them and switch to the appropriate state.
	 
	 If it is called in config mode state, then if there are no parameters, automatically go to 
	 terminal mode, otherwise check and act accordingly.
	 */
   if ((CA_currentState == CA_privState) && ([tokens containsObject:@"?"]))
      {
      // display the help
      if ([tokens indexOfObject:@"?"] == 1)
         {
         [CA_terminalView appendString:@"\n  memory              Configure from NV memory"];
         [CA_terminalView appendString:@"\n  network             Configure from a TFTP network host"];
         [CA_terminalView appendString:@"\n  overwrite-network   Overwrite NV memory from TFTP network host"];
         [CA_terminalView appendString:@"\n  terminal            Configure from the terminal\n"];
         }
      else
         {
         [CA_terminalView appendString:@"\n  <cr>\n"];
         }
      }
	else if (( CA_currentState == CA_privState) && ([tokens count] == 1))
		{
		CA_currentState = CA_configModeState;
		}
   else
		{
		if (((CA_currentState == CA_configModeState) && 
           ([[tokens objectAtIndex:0] isEqualToString:@""] || [[tokens objectAtIndex:0] isEqualToString:@"terminal"]))
          || (((CA_currentState == CA_privState) && ([[tokens objectAtIndex:1] isEqualToString:@"terminal"] ))))
			{
			[CA_terminalView appendString:@"\nEnter configuration commands, one per line.  End with END."];
			CA_currentState = CA_configState;
			}
       else
			{
			// Only Terminal mode is implemented - same with Packet Tracer 3.2
			[CA_terminalView appendString:@"\n% Not implemented"];
			CA_currentState = CA_privState;
			}
		}
}

/*
 Method Name: enterConfig
 Imported values:
 - (NSArray Pointer)tokens - the command line parameters entered with a command (including the command itself)
 Exported value: none
 Purpose: This method starts terminal config mode
 */
- (void)enterConfig:(NSArray *)tokens
{
	CA_currentState = CA_configState;
}

/*
 Method Name: exitConfig
 Imported values:
 - (NSArray Pointer)tokens - the command line parameters entered with a command (including the command itself)
 Exported value: none
 Purpose: This method exits config mode and displays a message
 */
- (void)exitConfig:(NSArray *)tokens
{
	[CA_terminalView appendString:@"\n%SYS-5-CONFIG_I: Configured from console by console"];
	CA_currentState = CA_privState;
}

@end
