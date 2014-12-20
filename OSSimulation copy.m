//
//  IOSSimulation.m
//  iNetSim
//
//  Created by Leon Chew on 24/10/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "OSSimulation.h"


@implementation OSController(OSSimulation)

// Added on 26/10/2005 by Leong
/*
 Method Name: isValidIp:
 Imported values:
 - (NSString *)ipAddress - an ip address to be validated.
 Exported value:  YES if valid No otherwise.
 Purpose: Check to make sure ip address is valid.
 */
- (BOOL)isValidIp:(NSString *)ipAddress
{
    // Split IP address into 4 components separated by "."
    NSArray *ipParts = [ipAddress componentsSeparatedByString:@"."];
    NSEnumerator *ipPartEnum = [ipParts objectEnumerator];
    NSString *ipPart;
    int totalValid = 0;
    BOOL isValid = NO;
    
    // Check whether the ip  contains 4 components.
    if( [ipParts count] == 4 )
    {
        // For all ip components
        while( ipPart = [ipPartEnum nextObject] )
        {
            // Check whether the component value is between 0 and 255 inclusive.
            if( ([ipPart intValue] >= 0) && ([ipPart intValue] <= 255) )
            {
                // make sure all 4 components are valid.
                totalValid += 1;
            }
        }
        // if all 4 components of ip are valid set isValid to YES.
        if( totalValid == 4 )
        {
            isValid = YES;
        }
    }
    return isValid;
}


// Added on 25/10/2005 by Leong
/*
 Method Name: networkForIp:
 Imported values:
 - (NSString *)ipAddress - an ip address to be checked.
 Exported value: (NSString *)networkIp - network ip address for the given ip.
 Purpose: Get the network ip for a given ip address.
 */
// Requires -isValidIp method to make sure a given ip is valid
- (NSString *)networkForIp:(NSString *)ipAddress
{
    NSString *networkIp = @"";
    //if ipAddress is valid
    if([self isValidIp:ipAddress])
    {
        // Get the 1st 3 components of the ip address
        NSArray *ipParts = [ipAddress componentsSeparatedByString:@"."];
        int i;

        for( i = 0; i < 3; i++ )
        {
            networkIp = [networkIp stringByAppendingString:[ipParts objectAtIndex:i]];
            networkIp = [networkIp stringByAppendingString:@"."];
        }
        // Append a 0 as the last component
        networkIp = [networkIp stringByAppendingString:@"0"];
    }
    else
    {
        networkIp = @"";
    }
    return networkIp;
}

// Added on 25/10/2005 by Leong
/*
 Method Name: isIp:inRipNetworkOfDevice:
 Imported values:
 - (NSString *)ipAddress - an ip address to be checked.
 - (NSManagedObject *)router - router with the rip table.
 Exported value: 
 - YES if true No otherwise.
 Purpose: Check whether an ip is accessible through the rip networks.
 */
- (BOOL)isIp:(NSString *)ipAddress inRipNetworkOfDevice:(NSManagedObject *)router
{	
    NSLog(@"Entering isIP:inRipNetworkOfDevice:");
	NSString *ip1 = [self networkForIp:ipAddress];
    NSSet *networks = [router valueForKey:@"networks"];
    NSEnumerator *networkEnum = [networks objectEnumerator];
    NSManagedObject *network;
    BOOL isFound = NO;
    
    NSLog(@"network count = %d", [networks count] );
    // For all rip enabled network in router
    while( network = [networkEnum nextObject] )
    {
        // if the destination ip is in one of the rip network
        if( [ip1 isEqualToString:[network valueForKey:@"ipAddress"]] )
        {
            NSLog(@"destIp is inRipNetworkOfDevice");
            // Set isFound to YES
            isFound = YES;
        }
    }
	
	return isFound;
}


// Added on 25/10/2005 by Leong
/*
 Method Name: isIp:inWholeRipNetwork:
 Imported values:
 - (NSString *)ipAddress - an ip address to be checked.
 - (NSManagedObject *)router - router with the rip table.
 Exported value: 
 - YES if true No otherwise.
 Purpose: Check whether an ip is accessible through the rip networks.
 */
- (BOOL)isIpInWholeRipNetwork:(NSString *)ipAddress 
{	
    NSLog(@"Entering isIP:inWholeRipNetwork:");
	NSString *ip1 = [self networkForIp:ipAddress];
    NSSet *networks = [self fetchRipNetwork];
    NSEnumerator *networkEnum = [networks objectEnumerator];
    NSManagedObject *network;
    BOOL isFound = NO;
    
    NSLog(@"network count = %d", [networks count] );
    // For all rip enabled network in router
    while( network = [networkEnum nextObject] )
    {
        // if the destination ip is in one of the rip network
        if( [ip1 isEqualToString:[network valueForKey:@"ipAddress"]] )
        {
            NSLog(@"destIp is inWholeRipNetwork");
            // Set isFound to YES
            isFound = YES;
        }
    }
	
	return isFound;
}


// Added on 25/10/2005 by Leong
/*
 Method Name: isIp:fromDevice:
 Imported values:
 - (NSString *)ipAddress - an ip address to be checked.
 - (NSManagedObject *)device - any device.
 Exported value: 
 - YES if true No otherwise.
 Purpose: 
 - Check whether the ip is from a network that belongs to a given device
   Without checking the rip network.  
   IP address that is valid according to this method can be ping from the
   router without setting network in rip.
 */
// Last modified by Leong on 27/10/2005

- (BOOL)isIp:(NSString *)ipAddress fromDevice:(NSManagedObject *)device
{
    NSLog(@"Entering isIpFromDevice");
    NSSet *ports = [device valueForKey:@"deviceports"];
    NSEnumerator *portEnum = [ports objectEnumerator];
    NSManagedObject *port;

    BOOL isFound = NO;
    
    // For all ports
    while( (port = [portEnum nextObject]) && !isFound )
    {
        if( [ipAddress isEqualToString:[port valueForKey:@"ipAddress"]] )
        {
            isFound = YES;
        }
    }
    return isFound;
}


/*
 Method Name: isIp:inRipTable:
 Imported values:
 - (NSString *)ipAddress - an ip address to be checked.
 - (NSSet *)ripTable - a ripTable from a router.
 Exported value: 
 - YES if true No otherwise.
 Purpose: Check whether ipAddress is in rip table.
 */
- (BOOL)isIp:(NSString *)ipAddress inRipTable:(NSSet *)ripTable   // Added by Leong on 22/10/2005
{
	NSEnumerator *ripEnum = [ripTable objectEnumerator];
	NSManagedObject *ripEntry;
	BOOL isFound = NO;
    
    NSLog(@"is ip in rip table?");
    
    // For all rip entry
    while( (ripEntry = [ripEnum nextObject]) && !isFound )
    {  
        // Check whether ipAddress is one of the destination ip in rip table
        if( [[ripEntry valueForKeyPath:@"destination.ipAddress"] isEqualToString:ipAddress])
        {
            isFound = YES;
        }
    }

	return isFound;
}



/*
 Method Name: isIp:inWholeRipTable:
 Imported values:
 - (NSString *)ipAddress - an ip address to be checked.
 - (NSArray *)ripTable - a ripTable from a router.
 Exported value: 
 - YES if true No otherwise.
 Purpose: Check whether ipAddress is in the whole rip entries.
 */
- (BOOL)isIp:(NSString *)ipAddress inWholeRipTable:(NSArray *)ripTable   // Added by Leong on 22/10/2005
{
	NSEnumerator *ripEnum = [ripTable objectEnumerator];
	NSManagedObject *ripEntry;
	BOOL isFound = NO;
    
    
    
    // For all rip entry
    while( (ripEntry = [ripEnum nextObject]) && !isFound )
    {  
        // Check whether ipAddress is one of the destination ip in rip table
        if( [[ripEntry valueForKeyPath:@"destination.ipAddress"] isEqualToString:ipAddress] )
        {
            isFound = YES;
        }
    }
    if(isFound)
    {
        NSLog(@"%@ in rip table", ipAddress);
    }
    else
    {
        NSLog(@"%@ not in rip table", ipAddress);
    }
    
	return isFound;
}

// Added by Leong on 26/10/2005
/*
 Method Name: linkEthWithSerial:
 Imported values:
 - (NSManagedObject *)router - a router with eth and serial ports.
 Exported value: 
 - none.
 Purpose: Provide a connection from eth network to serial network.
 Extra note: 
 - This method need to be improve because this only apply to a topology
   with 2 routers and multiple PCs.
*/
- (void)linkEthWithSerial:(NSManagedObject *)router
{
    NSSet *ports = [router valueForKey:@"deviceports"];
    NSEnumerator *portEnum = [ports objectEnumerator];
    NSManagedObject *port;
    NSManagedObject *ethPort;
    NSManagedObject *serialPort;

    ethPort = nil;
    serialPort = nil;
    
    // Choosing relevant ethernet port and serial port
    while( port = [portEnum nextObject] )
    {
        if( [[port valueForKey:@"portType"] isEqualToString:@"Ethernet"] &&
            [[port valueForKey:@"enabled"] boolValue] == YES )
        {
            ethPort = [[port retain] autorelease];
        }
        else if( [[port valueForKey:@"portType"] isEqualToString:@"Serial"] &&
                [[port valueForKey:@"enabled"] boolValue] == YES )
        {
            serialPort = [[port retain] autorelease];
        }
    }
    
    // If ethPort and serialPort are configured and ready
    // make a link between them.
    if( (ethPort != nil) && (serialPort != nil) )
    {
        [self addRipEntryFor:router 
                      source:ethPort
                 destination:serialPort];
        
        [self addRipEntryFor:router
                      source:serialPort
                 destination:ethPort];
    }
    NSLog(@"Exited from linkEthWithSerial");
}


/*
 Method Name: showInvalidIpMsgForDOS:
 Imported values:
 - (NSString *)ip - an invalid ip address.
 Exported value: 
 - none.
 Purpose: Display invalid ip address msg.
 */
// Added on 31/10/2005 by Leong
- (void)showInvalidIpMsgForDOS:(NSString *)ip
{
    NSString *msg;
    msg = [NSString stringWithFormat:@"\nPing request could not find host %@.\n",
        ip];
    [CA_terminalView appendString:msg];
    msg = [NSString stringWithFormat:@"Please check the name and try again.\n"];
    [CA_terminalView appendString:msg];
}


/*
 Method Name: showInvalidIpMsgForIOS:
 Imported values:
 - (NSString *)ip - an invalid ip address.
 Exported value: 
 - none.
 Purpose: Display invalid ip address msg.
 */
// Added on 31/10/2005 by Leong
- (void)showInvalidIpMsgForIOS:(NSString *)ip
{
    NSString *msg;
    msg = [NSString stringWithFormat:@"\nTranslating \"%@\"...domain server (255.255.255.255)\n",
        ip];
    [CA_terminalView appendString:msg];
    msg = [NSString stringWithFormat:@"%% unrecognized host or address, or protocol not running.\n"];
    [CA_terminalView appendString:msg];
}

/*
 Method Name: sendPing:
 Imported values:
 - (NSArray *)tokens - an string array of command and arguement
 Exported value: 
 - none.
 Purpose: Simulate IOS ping
 */
- (void)sendPing:(NSArray *)tokens  // Added by Leong on 22/10/2005
{
    // Check whether the arguements are valid
	if( ([tokens count] == 2) && [self isValidIp:[tokens objectAtIndex: 1]] )
    {
        NSLog(@"Entering send Ping");
		NSString *temp;
        NSString *ip = [tokens objectAtIndex: 1];
        [self buildRipTable];
		BOOL isSuccess = NO;
		NSArray *ripTable = [self fetchRipTable];
		
		temp = [NSString stringWithFormat:@"\nSending 5, 100-byte ICMP Echos to %@, time out is 2 seconds:\n", 
			ip];
		[CA_terminalView appendString:temp];
		
        // Pinging ports from netwroks owned by current router.
        if( [self isIp:ip fromDevice:CA_device] )
        {
            NSLog(@"ip is from current router");
            [self pingProgressIndicator:@"!"];
			[CA_terminalView appendString:@"\n"];
			[CA_terminalView appendString:@"Success rate is 100 percent (5/5), round-trip min/avg/max = 4/4/4 ms\n"];
			isSuccess = YES;
        }
        else if( [self isIp:ip inSameNetworkFrom:CA_device] && 
                 [self isIp:ip inRipTable:[CA_device valueForKey:@"ripTable"]] )
        {
            NSLog(@"ip is from current router");
            [self pingProgressIndicator:@"!"];
			[CA_terminalView appendString:@"\n"];
			[CA_terminalView appendString:@"Success rate is 100 percent (5/5), round-trip min/avg/max = 4/4/4 ms\n"];
			isSuccess = YES;
        }
		// Pinging ports from other networks.
		else if ( [CA_device valueForKey:@"networks"] != 0 )
        {
            NSLog(@"Access different networks..");
            int i;
            
            NSManagedObject *temp1;
            NSManagedObject *temp2;
            NSArray *allRouter = [self retriveRouters];
            NSEnumerator *ripEnum = [ripTable objectEnumerator];

            // get the source port of given ipAddress
            temp1 = [self retrieveSourceOfIp:[tokens objectAtIndex: 1] inTable:ripTable];
            
            
            for( i = 0; i < ([allRouter count] - 1); i++ )
            {
                while( [ripEnum nextObject] && !isSuccess )
                {
                    // Check to see if temp1 is within current router's rip network, 
                    // if yes, ping success.
                    if( [self isIp:[temp1 valueForKey:@"ipAddress"] inRipNetworkOfDevice:CA_device] )
                    {
                        [self pingProgressIndicator:@"!"];
                        [CA_terminalView appendString:@"\n"];
                        [CA_terminalView appendString:@"Success rate is 100 percent (5/5), round-trip min/avg/max = 4/4/4 ms\n"];
                        isSuccess = YES;
                    }
                    // otherwise search for source of temp1
                    else
                    {
                        temp2 = [self retrieveSourceOfIp:[temp1 valueForKey:@"ipAddress"] inTable:ripTable];
                        temp1 = temp2;
                    }
                }
            }
        }
        
        // Pinging unreachable devices.
        // Ping fail.
		if( !isSuccess )
        {
			[self pingProgressIndicator:@"."];
			[CA_terminalView appendString:@"\n"];
			[CA_terminalView appendString:@"Success rate is 0 percent (0/5), round-trip min/avg/max = 0/0/0 ms\n"];
        }
    }
    else if( ![self isValidIp:[tokens objectAtIndex:1]] )
    {
        [self showInvalidIpMsgForIOS:[tokens objectAtIndex:1]];
    }
    else
    {
        [self showCommandNotFound];
    }
}


// Added by Leong
/*
 Method Name: ipConfig:
 Imported values:
 - (NSArray *)tokens - an string array of command and arguement
 Exported value: 
 - none.
 Purpose: Simulate IOS command for configuring ip address, subnet mask required.
 */
- (void)ipConfig:(NSArray *)tokens
{
	if( ([tokens count] == 4) && ([[tokens objectAtIndex: 1] isEqualToString:@"address"]) &&
        [self isValidIp:[tokens objectAtIndex: 2]] && [self isValidIp:[tokens objectAtIndex: 3]] )
    {
		[CA_port setValue:[tokens objectAtIndex: 2] forKey:@"ipAddress"];
		[CA_port setValue:[tokens objectAtIndex: 3] forKey:@"subnetMask"];
    }
	else
    {
		[CA_terminalView appendString:@"\nIncomplete command!!\n"];
    }
}


// Added by Leong
/*
 Method Name: shutdownPort:
 Imported values:
 - (BOOL)isOff - YES to turn off, NO to turn on.
 Exported value: 
 - none.
 Purpose: This method is used to turn off an interface/port.
 */
- (void)shutdownPort:(BOOL)isOff
{
	NSString *temp;
	NSCalendarDate *time;
	time = [NSCalendarDate date];
	[time setCalendarFormat:@"%H:%M:%S"];
	[CA_port setValue:[NSNumber numberWithBool:!isOff] forKey:@"enabled"];
	temp = [NSString stringWithFormat:@"\n%@ %LINK-3-UPDOWN:  Interface %@, changed state to up\n", time, [CA_port valueForKey:@"name"]];
	[CA_terminalView appendString:temp];
	temp = [NSString stringWithFormat:@"%@ %LINEPROTO-5-UPDOWN:  Line protocol on interface %@, changed state to up\n", time, [CA_port valueForKey:@"name"]];
	[CA_terminalView appendString:temp];
}



// Added by Leong
/*
 Method Name: setClockRate:
 Imported values:
 - (NSArray *)tokens - an string array of command and arguement
 Exported value: 
 - none.
 Purpose: This method is used to set the clock rate for serial interface/port.
 */

- (void)setClockRate:(NSArray *)tokens
{
	// Need to check whether the entered rate is valid numeric digit.
	if( [tokens count] == 3 && [[tokens objectAtIndex: 1] isEqualToString:@"rate"] )
    {
		[CA_port setValue:[tokens objectAtIndex: 2] forKey:@"clockRate"];
    }
	else
    {
		[CA_terminalView appendString:@"\n% Should output proper Error...\n\n"];
    }
}




// Added by Leong
/*
 Method Name: negateCmd:
 Imported values:
 - (NSArray *)tokens - an string array of command and arguement
 Exported value: 
 - none.
 Purpose: This method is used to negate command.
 */
- (void)negateCmd:(NSArray *)tokens
{
	NSLog(@"negateCmd is called");
	if( ([tokens count] == 2) && ([[tokens objectAtIndex: 1] isEqualToString:@"shutdown"]) )
    {
		[self shutdownPort:NO];
		NSLog(@"port enabled = %d", [CA_port valueForKey:@"enabled"]);
    }
	else
    {
		[CA_terminalView appendString:@"\n% Should output proper Error...\n\n"];
    }
}


// Added by Leong

/*
 Method Name: setMacAddress:
 Imported values:
 - (NSArray *)tokens - an string array of command and arguement
 Exported value: 
 - none.
 Purpose: This method is used to set mac address manually.
 */
- (void)setMacAddress:(NSArray *)tokens
{
	// Need to check whether the entered MAC address is valid.
	if( [tokens count] == 2 )
    {
		[CA_port setValue:[tokens objectAtIndex: 1] forKey:@"macAddress"];
    }
	else
    {
		[CA_terminalView appendString:@"\n% Should output proper Error...\n\n"];
    }
	
}


/*
 Method Name: network:
 Imported values:
 - (NSArray *)tokens - an string array of command and arguement
 Exported value: 
 - none.
 Purpose: This method set the rip network for current router
 */ 
- (void)network:(NSArray *)tokens   // Added by Leong on 22/10/2005
{
	if( [tokens count] == 2 )
    {
        
		NSManagedObject *network;
		
		network = [NSEntityDescription insertNewObjectForEntityForName:@"Network"
                                                inManagedObjectContext:[CA_networkArray managedObjectContext]];
		[network setValue:[tokens objectAtIndex:1] forKey:@"ipAddress"];
		[network setValue:CA_device forKey:@"router"];
		[self buildRipTable];
    }
	else
    {
		[CA_terminalView appendString:@"\nIncomplete command!!\n"];
    }
}

// Added by Leong on 25/10/2005
/*
 Method Name: retrieveSourceOfIp:inTable:
 Imported values:
 - (NSString *)ipAddress - an ip address to be checked.
 - (NSArray *)ripTable - a ripTable to search from.
 Exported value: 
 - (NSManagedObject *)source - source port for a given ip address.
 Purpose: 
 - This method retrieve the source port for a given ip address from a given
   rip table.
 */ 
- (NSManagedObject *)retrieveSourceOfIp:(NSString *)ipAddress inTable:(NSArray *)ripTable
{
    NSLog(@"Entering retrieveSourceOfIp");
    NSEnumerator *ripEnum = [ripTable objectEnumerator];
    NSManagedObject *ripEntry;
    NSManagedObject *source = nil;
    BOOL isFound = NO;
    
    while( (ripEntry = [ripEnum nextObject]) && !isFound )
    {
        if( [[ripEntry valueForKeyPath:@"destination.ipAddress"]
            isEqualToString:ipAddress] )
        {
            if( [[ripEntry valueForKeyPath:@"source.ipAddress"] isEqualToString:ipAddress] )
            {
                NSLog(@"dest ip = source ip");
                source = nil;
            }
            else
            {
                source = [ripEntry valueForKey:@"source"];
                isFound = YES;
            }
        }
    }
    return source;
}


/*
 Method Name: selectDestinationPort:
 Imported values:
 - (NSManagedObject *)sourcePort - a source port.
 Exported value: 
 - (NSManagedObject *)destPort - destination port for the source port.
 Purpose: 
 - This method select the destination port for a given port.
   It assume that the two port are connected.
 */ 
- (NSManagedObject *)selectDestinationPort:(NSManagedObject *)sourcePort    // added by Leong on 21/10/2005
{
	NSManagedObject *destPort;
	
	if( [sourcePort valueForKey:@"linkEnd1"] != nil )
    {
		destPort = [[sourcePort valueForKey:@"linkEnd1"] valueForKey:@"port2"];
    }
	else if( [sourcePort valueForKey:@"linkEnd2"] != nil )
    {
		destPort = [[sourcePort valueForKey:@"linkEnd2"] valueForKey:@"port1"];
    }
	else
    {
		destPort = nil;
    }
	return destPort;
}


/*
 Method Name: buildRipTable:
 Imported values:
 - none.
 Exported value: 
 - none.
 Purpose: 
 - Building Rip Table.
 */ 
- (void)buildRipTable   // Added by Leong on 21/10/2005
{
    // Get all router from topology
	NSArray *allRouters = [self retriveRouters];
	NSEnumerator *routerEnum = [allRouters objectEnumerator];
    
    // Declare variables to hold ripEntry
	NSSet *ripEntrySet = [NSSet new];
    NSEnumerator *ripEnum;
    
	NSManagedObject *router;
    NSManagedObject *ripEntry;
	
    // For all router in topology
	while( router = [routerEnum nextObject] )
    {
        // Get ripTable from each router
        ripEntrySet = [router valueForKey:@"ripTable"];
        ripEnum = [ripEntrySet objectEnumerator];
        
        //For each rip entry
        while( ripEntry = [ripEnum nextObject] )
        {
            // Clear all rip entry before getting the latest
            [[CA_ripEntryArray managedObjectContext] deleteObject:ripEntry];
        }
        
        // Clear ripTable of router
		[router setValue:[NSSet new] forKey:@"ripTable"];
        
        // Repopulate ripTable
		[self getDestinationPortsFor:router withCost:0];
        [self linkEthWithSerial:router];
    }
}


/*
 Method Name: buildRipTable:
 Imported values:
 - (NSManagedObject *)aRouter - a router to add the rip entry.
 - (NSManagedObject *)sourcePort - source port for rip entry.
 - (NSManagedObject *)destinationPort - destination port for rip entry.
 Exported value: 
 - none.
 Purpose: 
 - Add rip entry to managed object context.
 */ 
//added by Leong on 26/10/2005
- (void)addRipEntryFor:(NSManagedObject *)aRouter 
                source:(NSManagedObject *)sourcePort
           destination:(NSManagedObject *)destinationPort
{
    // Specify the Managed Object Context to add the ripEntry
    NSManagedObjectContext *moc = [[self ripEntryArray] managedObjectContext];
    
    // Create and insert a new ripEntry
    NSManagedObject *ripEntry;
    ripEntry = [NSEntityDescription insertNewObjectForEntityForName:@"RipEntry"
                                             inManagedObjectContext:moc];
    
    // Set the value of ripEntry
    [ripEntry setValue:aRouter forKey:@"belongsTo"];
    [ripEntry setValue:sourcePort forKey:@"source"];
    [ripEntry setValue:destinationPort forKey:@"destination"];
}

// Added by Leong on 18/10/2005
/*
 Method Name: getDestinationPortsFor:withCost
 Imported values:
 - (NSManagedObject *)aRouter - any router acted as source
 - (int)cost - a cost to get to destination.
 Exported value: 
 - none.
 Purpose: 
 - Get the destination ports for a router.
 */ 
- (void)getDestinationPortsFor:(NSManagedObject *)aRouter withCost:(int)cost
{
    NSLog(@"entering getDestinationPort");
	NSSet *ports;
	NSSet *networks;
	NSManagedObject *tempPort;
	NSManagedObject *destPort;
	NSManagedObject *network;
	BOOL isInNetwork = NO;
	
    // Get all port of aRouter
	ports = [aRouter valueForKey:@"deviceports"]; 
    NSEnumerator *portEnum = [ports objectEnumerator];
    
    // Get the RIP enabled networks of aRouter 
	networks = [aRouter valueForKey:@"networks"];
    NSEnumerator *networkEnum = [networks objectEnumerator];
    
	
    // For all ports af aRouter
	while( tempPort = [portEnum nextObject] )
    {
        // Only consider the ports that are on
		if( [[tempPort valueForKey:@"enabled"] boolValue] == YES )  // Port is on
        {
            // Get the destination ports for an available.
			destPort = [self selectDestinationPort:tempPort];
         
            // Destination port exist and is on
			if( (destPort != nil) && ([[destPort valueForKey:@"enabled"] boolValue] == YES) )
            {
                // Declare two variables for checking whether ports are:
                //  i) from networks belongs to same router
                // ii) from networks belongs to different routers
                NSString *destIp;
                NSString *tempIp;
                
                // If destPort is from a PC
                if( [[destPort valueForKeyPath:@"deviceport.deviceType"] 
                               isEqualToString:@"PC"] )
                {
                    // Set destIp as the device's gateway ip
                    destIp = [destPort valueForKeyPath:@"deviceport.gateway"];
                    // Set tempIp as the current port ip
                    tempIp = [tempPort valueForKey:@"ipAddress"];
                }
                // If destPort is from a Router
                else if( [[destPort valueForKeyPath:@"deviceport.deviceType"] 
                               isEqualToString:@"Router"] )
                {
                    // Set destIp as the destPort ip
                    destIp = [self networkForIp:[destPort valueForKey:@"ipAddress"]];
                    // Set the tempIp as the curernt port ip
                    tempIp = [self networkForIp:[tempPort valueForKey:@"ipAddress"]];
                }
                
                // After getting destIp and tempIp, check whether they are equal.
                // If destPort's default gateway is current router. 
                // Destination port belongd to a PC that connected directly to PC.
				if( [destIp isEqualToString:tempIp] )
                {
                    [self addRipEntryFor:aRouter 
                                  source:tempPort
                             destination:destPort];
                }
				else    // Devices from different networks
                {
                    // Search whether the destPort's network is reachable from current router
					while( (network = [networkEnum nextObject]) && !isInNetwork )
                    {
						isInNetwork = [self isIp:[destPort valueForKey:@"ipAddress"]
                                       inRipNetworkOfDevice:aRouter];
                    }
					
					if( isInNetwork )   // destPort is in reachable networks
                    {
                        [self addRipEntryFor:aRouter 
                                      source:tempPort
                                 destination:destPort];
                    }
                }                
            }
        }
    }
    NSLog(@"exit from getDestinationPort");
}








- (void)show:(NSArray *)tokens
{
	if( [tokens count] == 1 )
    {
        NSString *msg;
        msg = @"\n% Type \"show ?\" for a list of subcommands\n";
        [CA_terminalView appendString:msg];
    }
    else if( [tokens count] == 2 )
    {
        NSString *msg;
        /*
        if( [[tokens objectAtIndex:1] isEqualToString:@"host"] )
        {
            NSSet *hostTable;
            NSManagedObject *hostTableEntry;
            
            hostTable = [CA_device valueForKey:@"hostTable"];
            NSEnumerator *hostEnum = [hostTable objectEnumerator];
            
            msg = @"Host \t\t\t Address(es)";
            [CA_terminalView appendString:msg];
            
            while( hostTableEntry = [hostEnum nextObject] )
            {
                msg = [NSString stringWithFormat:@"%@\t\t\t %@\n", 
                    [hostTableEntry valueForKey:@"hostName"], 
                    [hostTableEntry valueForKey:@"ipAddress"]];
                [CA_terminalView appendString:msg];
            }
            
            [CA_terminalView appendString:@"\n"];
        }*/
        if( [[tokens objectAtIndex:1] isEqualToString:@"running-config"] )
        {
            [self showRunningConfig];
        }
    }
    else
    {
        [self showCommandNotFound];
    }

}

// Added on 27/10/2005 by Leong
/*
 Method Name: fetchRipTableFrom:
 Imported values:
 - (NSManagedObject *)device - any router acted as source
 Exported value: 
 - (NSMutableArray *)ripTable.
 Purpose: 
 - Get rip table from a router.
 */ 
- (NSMutableArray *)fetchRipTableFrom:(NSManagedObject *)device
{
    NSLog(@"Entering fetchRipTableFrom..");
    NSSet *temp;
    NSMutableArray *ripTable;
    NSManagedObject *router;
    NSManagedObject *ripEntry;
    
    if( [[device valueForKey:@"deviceType"] isEqualToString:@"Router"] )
    {
        router = [device retain];
    }
    else if( [[device valueForKey:@"deviceType"] isEqualToString:@"PC"] )
    {
        NSManagedObject *port;
        port = [self retrievePortWithIp:[device valueForKey:@"gateway"]];
        router = [[port valueForKey:@"deviceport"] retain];
    }
    NSLog(@"router is %@", [router valueForKey:@"deviceName"]);
    temp = [[router valueForKey:@"ripTable"] retain];
    NSEnumerator *tempEnum = [temp objectEnumerator];
    
    NSLog(@"Converting set to array..count = %@", [temp count]);
    
    while( ripEntry = [tempEnum nextObject] )
    {
        [ripTable addObject:ripEntry];
    }
    
    return ripTable;
    NSLog(@"Exited from fetchRipTableFrom");
}




// Added on 27/10/2005 by Leong
/*
 Method Name: retrieveActivePortFrom:
 Imported values:
 - (NSManagedObject *)device - any device.
 Exported value: 
 - (NSArray *)activePorts - all ports that are on.
 Purpose: 
 - Get active ports from a give device.
 */
- (NSArray *)retrieveActivePortFrom:(NSManagedObject *)device
{
    NSSet *ports = [device valueForKey:@"deviceports"];
    NSEnumerator *portEnum = [ports objectEnumerator];
    NSManagedObject *port;
    NSMutableArray *activePorts = [NSMutableArray new];
    
    while( port = [portEnum nextObject] )
    {
        if( [self isValidIp:[port valueForKey:@"ipAddress"]] && 
            [[port valueForKey:@"enabled"] boolValue] == YES )
        {
            [activePorts addObject:port];
        }
    }
    return activePorts;
}


// Added on 29/10/2005 by Leong
/*
 Method Name: isIp:inSameNetworkFrom:
 Imported values:
 - (NSString *)ipAddress - an ip address to be checked.
 - (NSManagedObject *)router - a router to be checked.
 Exported value: 
 - YES if true NO otherwise.
 Purpose: 
 - Checked whether an ip is the same networks that owned by a router.
 */
- (BOOL)isIp:(NSString *)ipAddress inSameNetworkFrom:(NSManagedObject *)router
{
    NSSet *ports = [router valueForKey:@"deviceports"];
    NSEnumerator *portEnum = [ports objectEnumerator];
    NSManagedObject *port;
    NSString *portIp;
    BOOL isSame = NO;
    
    while( (port = [portEnum nextObject]) && !isSame )
    {
        portIp = [port valueForKey:@"ipAddress"];
        if( [[self networkForIp:ipAddress] isEqualToString:[self networkForIp:portIp]] )
        {
            isSame = YES;
        }
    }
    return isSame;
}

// Added on 28/10/2005 by Leong
/*
 Method Name: scanRouter:toTrace:fromIp:toIp
 Imported values:
 - (NSManagedObject *)router - a router to be checked.
 - (NSMutableArray *)route - an array of ip that form the route.
 - (NSString *)ip1 - source ip.
 - (NSString *)ip2 - destination ip.
 Exported value: 
 - YES if true NO otherwise.
 Purpose: 
 - Check whether the router provide route to destination ip for a given source ip.
 */
- (void)scanRouter:(NSManagedObject *)router 
           toTrace:(NSMutableArray *)route
            fromIp:(NSString *)ip1
              toIp:(NSString *)ip2
{
    NSLog(@"Scanning router %@", [router valueForKey:@"deviceName"]);
    if( ![[router valueForKey:@"scanned"] boolValue] )
    {
        NSLog(@"router %@ has not been scanned yet.", [router valueForKey:@"deviceName"]);
        [router setValue:[NSNumber numberWithBool:YES] forKey:@"scanned"];
        NSSet *ripTable;
        NSArray *wholeRipTable;
        NSEnumerator *ripEnum;
        NSManagedObject *ripEntry;
        
        NSArray *ports;
        NSEnumerator *portEnum;
        NSManagedObject *port;
        
        NSMutableArray *otherPorts = [NSMutableArray new];
        
        ripTable = [router valueForKey:@"ripTable"];
        ripEnum = [ripTable objectEnumerator];
        
        ports = [self retrieveActivePortFrom:router];
        portEnum = [ports objectEnumerator];
        
        NSLog(@"Start checking in ripEntry..count = %d", [ripTable count]);
        NSString *tempIp = @"";
        NSString *destIp = @"";
        NSManagedObject *sourceIp;
        BOOL isInSameNetwork = NO;
        BOOL isDone = NO;
        NSEnumerator *otherPortEnum;
        
        wholeRipTable = [self fetchRipTable];
        NSLog(@"[wholeRipTable count] = %d", [wholeRipTable count]);
        
        if( [[CA_device valueForKey:@"deviceType"] isEqualToString:@"PC"] )
        {
            [route addObject:ip1];
        }
        else if( [[CA_device valueForKey:@"deviceType"] isEqualToString:@"Router"] ) 
        {
            if( [self isIp:ip2 inSameNetworkFrom:router] )
            {
                [route addObject:ip1];
            }
        }
        
        //if( [self isIp:ip2 inWholeRipTable:wholeRipTable] )
        NSLog(@"router name is %@", [router valueForKey:@"deviceName"] );
        if( [self isIpInWholeRipNetwork:ip2 ] )
            
		{
            NSLog(@"*****************");
			while( ripEntry = [ripEnum nextObject] )
			{
				destIp = [ripEntry valueForKeyPath:@"destination.ipAddress"];
				NSLog(@"ip2 = %@, destip = %@", ip2, destIp);
				
				if( [[self networkForIp:ip2] isEqualToString:[self networkForIp:ip1]] )
				{
					isInSameNetwork = YES;
				}
				else if( ![ip2 isEqualToString:[ripEntry valueForKeyPath:@"source.ipAddress"]] &&
						 !isInSameNetwork )
				{
					if( [otherPorts count] == 0 )
					{
						sourceIp = [ripEntry valueForKey:@"source"];
                        NSLog(@"sourceIp = %@", [sourceIp valueForKey:@"ipAddress"] );
                        if([self selectDestinationPort:sourceIp] != nil )
                        {
                            [otherPorts addObject:[self selectDestinationPort:sourceIp]];
                        }
						
					}
					else
					{
						otherPortEnum = [otherPorts objectEnumerator];
						
						while( port = [otherPortEnum nextObject] )
						{
							if( port != [self selectDestinationPort:[ripEntry valueForKey:@"source"]] )
							{
								sourceIp = [ripEntry valueForKey:@"source"];
								if([self selectDestinationPort:sourceIp] != nil )
                                {
                                    [otherPorts addObject:[self selectDestinationPort:sourceIp]];
                                }
							}
						}
					}
				}
			}
		}

        
        NSLog(@"After checking ripEntry...");
        otherPortEnum = [otherPorts objectEnumerator];
        
        while( (port = [otherPortEnum nextObject]) && !isDone )
        {
            NSLog(@"checking ports..%@", [port valueForKey:@"ipAddress"]);
            NSManagedObject *destPort = [self retrievePortWithIp:ip2];
            NSLog(@"device 1 = %@, device 2 = %@", 
                  [port valueForKeyPath:@"deviceport.deviceName"], 
                  [destPort valueForKeyPath:@"deviceport.deviceName"] );
            
            if( ( [port valueForKey:@"deviceport"] == [destPort valueForKey:@"deviceport"] ) &&
                [self isIp:ip2 inRipTable:ripTable] )
            {
                tempIp = [port valueForKey:@"ipAddress"];
                [route addObject:tempIp];
                isDone = YES;
            }
            
            else if( [[port valueForKeyPath:@"deviceport.deviceType"] isEqualToString:@"Router"] )
            {
                [self scanRouter:[port valueForKey:@"deviceport"]
                         toTrace:route
                          fromIp:[port valueForKey:@"ipAddress"]
                            toIp:ip2];
            }
        }  
    }
    NSLog(@"Exited from scanning router %@", [router valueForKey:@"deviceName"]);
}


// Added on 28/10/2005 by Leong
/*
 Method Name: dosTracertTo:hop:time:time:time
 Imported values:
 - (NSString *)ipAddress - destination ip.
 - (int)hop - an integer to indicate number of hop.
 - (NSString *)t1 - a time
 - (NSString *)t2 - a time
 - (NSString *)t3 - a time
 Exported value: 
 - none.
 Purpose: 
 - Display DOS tracert messages.
 */
- (void)dosTracertTo:(NSString *)ipAddress hop:(int)num time:(NSString *)t1 
                time:(NSString *)t2 time:(NSString *)t3
{
    NSString *temp;

    temp = [NSString stringWithFormat:
            @"%2d\t    %@\t    %@\t    %@\t    %@\n",num, t1, t2, t3, ipAddress];
    [CA_terminalView appendString:temp];
}


// Added on 28/10/2005 by Leong
/*
 Method Name: dosTracertTo:hop:time:time:time
 Imported values:
 - (NSString *)ipAddress - destination ip.
 - (int)hop - an integer to indicate number of hop.
 - (NSString *)t1 - a time
 - (NSString *)t2 - a time
 - (NSString *)t3 - a time
 Exported value: 
 - none.
 Purpose: 
 - Display IOS traceroute messages.
 */
- (void)iosTracerouteTo:(NSString *)ipAddress hop:(int)num time:(NSString *)t1 
                   time:(NSString *)t2 time:(NSString *)t3
{
    NSString *temp;
    
    temp = [NSString stringWithFormat:
        @"%2d\t    %@\t    %@\t    %@\t    %@\n",num, ipAddress, t1, t2, t3 ];
    [CA_terminalView appendString:temp];
}


// Added on 28/10/2005 by Leong
/*
 Method Name: nextHopFor:
 Imported values:
 - (NSManagedObject *)router - a router to be checked.
 Exported value: 
 - (NSArray *)nextHops - an arrays of next hop for a given router.
 Purpose: 
 - Get the next hops for a give router.
 */
- (NSArray *)nextHopFor:(NSManagedObject *)router
{
    NSArray *ports = [self retrieveActivePortFrom:router];
    NSEnumerator *portEnum = [ports objectEnumerator];
    NSManagedObject *port;
    NSManagedObject *destPort;
    NSManagedObject *tempRouter = [NSManagedObject new];
    NSMutableArray *nextHops = [NSMutableArray new];
    
    while( port = [portEnum nextObject] )
    {
        destPort = [self selectDestinationPort:port];
        if( [[destPort valueForKeyPath:@"deviceport.deviceType"] isEqualToString:@"Router"] )
        {
            if( [port valueForKey:@"deviceport"] != tempRouter )
            {
                [nextHops addObject:destPort];
            }
            tempRouter = [destPort valueForKey:@"deviceport"];
        }
    }
    return nextHops;
}

// Added on 27/10/2005 by Leong
/*
 Method Name: sendTracert:
 Imported values:
 - (NSArray *)tokens - an string array of command and arguement
 Exported value: 
 - none.
 Purpose: Simulate DOS command for tracert.
 */
- (void)sendTracert:(NSArray *)tokens
{
    if( ([tokens count] == 2) && [self isValidIp:[tokens objectAtIndex:1]] )
    {
        NSString *ip = [tokens objectAtIndex:1];
        NSString *gatewayIp;
        NSString *currentIp;
        NSManagedObject *gatewayPort;
        NSManagedObject *currentPort;
        NSManagedObject *router;
        NSMutableArray *route;
        NSString *msg;
        BOOL isSuccess = NO;
        BOOL isEth = NO;
        NSSet *ports;
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
        
        gatewayIp = [CA_device valueForKey:@"gateway"];
        msg = [NSString stringWithFormat:
            @"\n\nTrace route to %@ over a maximum of 30 hops\n\n", ip];
        [CA_terminalView appendString:msg];
        if(gatewayIp != nil && [self selectDestinationPort:currentPort] != nil)
        {
            gatewayPort = [self retrievePortWithIp:gatewayIp];
            
            router = [gatewayPort valueForKey:@"deviceport"];
            route = [NSMutableArray new];
            
           
            [self buildRipTable];
            
            
            
            NSArray *allRouter = [self retriveRouters];
            NSEnumerator *routerEnum = [allRouter objectEnumerator];
            
            while( router = [routerEnum nextObject] )
            {
                [router setValue:[NSNumber numberWithBool:NO] forKey:@"scanned"];
            }
            
            router = [gatewayPort valueForKey:@"deviceport"];
            if( [currentIp isEqualToString:ip] )
            {
                [route addObject:currentIp];
            }
            else
            {
                [self scanRouter:router
                         toTrace:route 
                          fromIp:gatewayIp
                            toIp:ip];
            }
            
            
            if( [route count] > 0 )
            {
                NSEnumerator *routeEnum = [route objectEnumerator];
                NSString *tempRoute;
                
                int i = 1;
                
                while( tempRoute = [routeEnum nextObject] )
                {
                    [self dosTracertTo:tempRoute hop:i++ time:@"1 ms" time:@"2 ms" time:@"1 ms"];
                    if( [self isIp:ip inWholeRipTable:[self fetchRipTable]] )
                    {
                        isSuccess = YES;
                    }
                }
            }
        }
        
        if( !isSuccess )
        {
            int i;
            
            for( i = [route count] + 1; i <= 30; i++ )
            {
                [self dosTracertTo:@"Request timed out." hop:i time:@"*   " time:@"*   " time:@"*   "];
            }
        }
        [CA_terminalView appendString:@"\n"];
        [CA_terminalView appendString:@"Trace complete.\n"];
    }
    else if( ![self isValidIp:[tokens objectAtIndex:1]] )
    {
        [self showInvalidIpMsgForDOS:[tokens objectAtIndex:1]];
    }
    else
    {
        [self showCommandNotFound];
    }
}

// Added on 28/10/2005 by Leong
/*
 Method Name: sendTraceroute:
 Imported values:
 - (NSArray *)tokens - an string array of command and arguement
 Exported value: 
 - none.
 Purpose: Simulate IOS command for traceroute.
 */
- (void)sendTraceroute:(NSArray *)tokens
{
    if( ([tokens count] == 2) && [self isValidIp:[tokens objectAtIndex:1]] )
    {
        NSString *ip = [tokens objectAtIndex:1];
        NSArray *nextHops = [self nextHopFor:CA_device];
        NSManagedObject *nextHop;
        NSManagedObject *router;

        NSLog(@"nexthops count = %d", [nextHops count] );
        if( [nextHops count] == 1 )
        {
           nextHop = [nextHops objectAtIndex:0];
        }

        NSMutableArray *route = [NSMutableArray new];

        BOOL isSuccess = NO;
        NSString *msg;
        [self buildRipTable];
        
        [CA_terminalView appendString:@"\nType escape sequence to abort.\n"];
        
        msg = [NSString stringWithFormat:
            @"Tracing the route to %@\n\n", ip];
        [CA_terminalView appendString:msg];
        
        NSArray *allRouter = [self retriveRouters];
        NSEnumerator *routerEnum = [allRouter objectEnumerator];
        
        while( router = [routerEnum nextObject] )
        {
            [router setValue:[NSNumber numberWithBool:NO] forKey:@"scanned"];
        }
        
        //NSLog(@"nextHop's ip = %@", [nextHop valueForKey:@"ipAddress"] );
        
        if( [self isIp:ip inRipTable:[CA_device valueForKey:@"ripTable"]] ||
            [self isIp:ip fromDevice:CA_device] )
        {
            [self iosTracerouteTo:ip hop:1 time:@"0 msec" time:@"0 msec"
                             time:@"0 msec"];
            isSuccess = YES;
        }
        else if( nextHop != nil )
        {
            [CA_device setValue:[NSNumber numberWithBool:YES] forKey:@"scanned"];
            
            [self scanRouter:[nextHop valueForKey:@"deviceport"]
                     toTrace:route 
                      fromIp:[nextHop valueForKey:@"ipAddress"]
                        toIp:ip];
            
            NSEnumerator *routeEnum = [route objectEnumerator];
            NSString *tempRoute;
            NSArray *wholeRipTable = [self fetchRipTable];
            
            int i = 1;
            
            while( tempRoute = [routeEnum nextObject] )
            {
                [self iosTracerouteTo:tempRoute hop:i++ time:@"1 msec" time:@"2 msec"
                                 time:@"1 msec"];
                if( [self isIp:tempRoute inWholeRipTable:wholeRipTable] &&
                    [self isIp:ip inWholeRipTable:wholeRipTable] )
                {
                    isSuccess = YES;
                }
                else
                {
                    isSuccess = NO;
                }
            }
            
        }
        if(!isSuccess)
        {
            int i;
            for( i = (1 + [route count]); i <= 30; i++ )
            {
                [self iosTracerouteTo:@"" hop:i time:@"*" time:@"*" time:@"*"];
            }
        }
    }
    else if( ![self isValidIp:[tokens objectAtIndex:1]] )
    {
        [self showInvalidIpMsgForIOS:[tokens objectAtIndex:1]];
    }
    else
    {
        [self showCommandNotFound];
    }
}



// Added by Leong on 01/11/2005
- (void)globalIpConfig:(NSArray *)tokens
{
    if( [tokens count] > 2 )
    {
        if( [[tokens objectAtIndex:1] isEqualToString:@"host"] )
        {
            int i = 0;
            NSString *hostName = [tokens objectAtIndex:3];
            for(i = 0; i < ([tokens count] - 3); i++ )
            {
                NSManagedObject *hostTableEntry;
                
                hostTableEntry = [NSEntityDescription insertNewObjectForEntityForName:@"HostTableEntry"
                                                        inManagedObjectContext:[CA_hostTableArray managedObjectContext]];
                [hostTableEntry setValue:hostName forKey:@"hostName"];
                [hostTableEntry setValue:[tokens objectAtIndex:(i + 3)] forKey:@"ipAddress"];
                [hostTableEntry setValue:CA_device forKey:@"belongsTo"];
            }
        }
    }
    else
    {
        [self showCommandNotFound];
    }
}


// Added by Leong on 01/11/2005
- (NSString *)lookpUpHostName:(NSString *)hostName
{
    
}

// Added by Leong on 02/11/2005
- (void)showRunningConfig
{
    NSSet *ports = [CA_device valueForKey:@"deviceports"];
    NSEnumerator *portEnum = [ports objectEnumerator];
    NSManagedObject *port;
    NSString *msg;
    
    
    [CA_terminalView appendString:@"Building configuration...\n"];
    [CA_terminalView appendString:@"Current configuration: 625 bytes\n"];
    [CA_terminalView appendString:@"!\n"];
    [CA_terminalView appendString:@"version 1.0\n"];
    [CA_terminalView appendString:@"service timestamp debug uptime\n"];
    [CA_terminalView appendString:@"service timestamps log uptime\n"];
    [CA_terminalView appendString:@"no service password-encryption\n"];
    [CA_terminalView appendString:@"!\n"];
    msg = [NSString stringWithFormat:@"hostname = %@\n", [CA_device valueForKey:@"deviceName"]];
    [CA_terminalView appendString:msg];
    [CA_terminalView appendString:@"!\n"];
    [CA_terminalView appendString:@"!\n"];
    [CA_terminalView appendString:@"!\n"];
    [CA_terminalView appendString:@"ip subnet-zero\n"];
    [CA_terminalView appendString:@"!\n"];
    [CA_terminalView appendString:@"!\n"];
    [CA_terminalView appendString:@"!\n"];
    [CA_terminalView appendString:@"!\n"];
    
    while( port = [portEnum nextObject] )
    {
        if( ![[port valueForKey:@"portType"] isEqualToString:@"Console"] )
        {
            msg = [NSString stringWithFormat:@"interface %@\n", [port valueForKey:@"name"]];
            [CA_terminalView appendString:msg];
            if( [[port valueForKey:@"ipAddress"] isEqualToString:@""] ||
                [port valueForKey:@"ipAddress"] == nil )
            {
                [CA_terminalView appendString:@"  no ip address\n"];
            }
            else if( ![[port valueForKey:@"ipAddress"] isEqualToString:@"Not Available"] )
            {
                msg = [NSString stringWithFormat:@"  ip address %@ %@\n", 
                    [port valueForKey:@"ipAddress"], [port valueForKey:@"subnetMask"]];
                [CA_terminalView appendString:msg];
            }
            
            [CA_terminalView appendString:@"  no ip directed-broadcast\n"];
            if( ![[port valueForKey:@"clockRate"] isEqualToString:@""] &&
                ![[port valueForKey:@"clockRate"] isEqualToString:@"Not Available"] &&
                [port valueForKey:@"clockRate"] != nil )
            {
                msg = [NSString stringWithFormat:@"  clockrate %@\n", [port valueForKey:@"clockRate"]];
                [CA_terminalView appendString:msg];
            }
            if( [[port valueForKey:@"enabled"] boolValue] == NO )
            {
                [CA_terminalView appendString:@"  shutdown\n"];
            }
            [CA_terminalView appendString:@"!\n"];
        }
        
    }
    NSSet *networks = [CA_device valueForKey:@"networks"];
    NSEnumerator *networkEnum = [networks objectEnumerator];
    NSManagedObject *network;
    
    if( [networks count] != 0 )
    {
        [CA_terminalView appendString:@"router rip\n"];
        
        while( network = [networkEnum nextObject] )
        {
            msg = [NSString stringWithFormat:@"  %@\n", [network valueForKey:@"ipAddress"]];
            [CA_terminalView appendString:msg];
        }
    }
    
    [CA_terminalView appendString:@"!\n"];
    [CA_terminalView appendString:@"!\n"];
    [CA_terminalView appendString:@"ip classless\n"];
    [CA_terminalView appendString:@"!\n"];
    [CA_terminalView appendString:@"!\n"];
    [CA_terminalView appendString:@"!\n"];
    [CA_terminalView appendString:@"line con 0\n"];
    [CA_terminalView appendString:@"line aux 0\n"];
    [CA_terminalView appendString:@"line vty 0 4\n"];
    [CA_terminalView appendString:@"  login\n"];
    [CA_terminalView appendString:@"!\n"];
    [CA_terminalView appendString:@"end\n"];
}

@end
