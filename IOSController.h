//
//  IOSController.h
//  iNetSim
//
//  Created by James Hope on 6/10/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OSController.h"


@interface IOSController : OSController 
{
	@private
	NSDictionary *CA_userDict;
	NSDictionary *CA_privDict;
	NSDictionary *CA_configDict;
    NSDictionary *CA_serialConfigDict;
    NSDictionary *CA_ethernetConfigDict;
    NSDictionary *CA_routerConfigDict;
    NSDictionary *CA_routerRipConfigDict;
		NSDictionary *CA_lineConfigDict;

	enum 
    {
		CA_bootState,
		CA_bootWithPasswordState, // added on 23/10/2005 by James
		CA_telnetWithPasswordState, // added on 23/10/2005 by James
		CA_userState,
		CA_privState,
		CA_configState,
		CA_configModeState, // added on 23/10/2005 by James
    CA_serialConfigState,    // added on 16/10/2005 by Leong
    CA_ethernetConfigState,  // added on 16/10/2005 by Leong
    CA_routerRipConfigState,       // added on 20/10/2005 by Leong
    CA_routerConfigState,
		CA_vtyLineConfigState,  // added on 23/10/2005 by James
		CA_consoleLineConfigState, // added on 23/10/2005 by James
		CA_lineConfigConsolePasswordSetState, // added on 23/10/2005 by James
		CA_lineConfigVtyPasswordSetState, // added on 23/10/2005 by James
		CA_enableSecretSetState,  // added on 23/10/2005 by James
		CA_enterPrivWithSecretState, // added on 23/10/2005 by James
		CA_offState
	}terminalState;
	
}

- (void)boot;
- (void)loginVty;
- (void)displayHelp;
- (void)processCommands:(NSArray *)tokens;
- (void)notImplemented:(NSArray *)tokens;
- (void)exitExec:(NSArray *)tokens;
- (void)setHostname:(NSArray *)tokens;
- (void)telnet:(NSArray *)tokens;
- (void)checkPassword:(NSArray *)tokens;
- (void)getDestinationPortsFor:(NSManagedObject *)aRouter withCost:(int)cost;
- (void)setRipTables:(NSMutableArray *)ripTablesArray;
- (NSMutableArray *)ripTables;

- (NSArray *)retriveRouters;

@end

/*
 IOSController components-
 The following components are contained in different files for maintainability purposes.
 */

/*
 Category: IOSPrivMode
 Purpose:  Conatins all the functions for entering/exiting Privileged EXEC mode
 Implementation File: IOSPrivMode.m
 */
@interface IOSController(IOSPrivMode)

- (void)enterPriv:(NSArray *)tokens;
- (void)exitPriv:(NSArray *)tokens;
- (void)setEnablePassword:(NSArray *)tokens;

@end

/*
 Category: IOSConfigMode
 Purpose:  Conatins all the functions for entering/exiting Configuration mode
 Implementation File: IOSConfigMode.m
 */
@interface IOSController(IOSConfigMode)

- (void)configureMode:(NSArray *)tokens;
- (void)enterConfig:(NSArray *)tokens;
- (void)exitConfig:(NSArray *)tokens;

@end

/*
 Category: IOSLineConfig
 Purpose:  Conatins all the functions for Line config mode
 Implementation File: IOSLineConfig.m
 */
@interface IOSController(IOSLineConfig)

- (void)enterLineConfig:(NSArray *)tokens;
- (void)lineConfigLogin:(NSArray *)tokens;
- (void)lineConfigPassword:(NSArray *)tokens;
- (void)lineConfigSetPassword:(NSArray *)tokens;

@end

          