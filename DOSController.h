//
//  DOSController.h
//  iNetSim
//
//  Created by James Hope on 6/10/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OSController.h"

@interface DOSController : OSController 
{
	@private
	NSDictionary *CA_commandDict;
	enum terminalState
    {
		CA_normalState
	};
	
}

- (void)boot;
- (void)showHelp:(NSArray *)tokens;
- (void)processCommands:(NSArray *)tokens;
- (void)showDir:(NSArray *)tokens;
- (void)exitDOS:(NSArray *)tokens;



@end
