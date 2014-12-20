//
//  IOSSimulation.h
//  iNetSim
//
//  Created by Leon Chew on 24/10/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OSController.h"

@interface OSController(OSSimulation)

- (BOOL)isValidIp:(NSString *)ipAddress;
- (NSString *)networkForIp:(NSString *)ipAddress;
- (BOOL)isIp:(NSString *)ipAddress inRipNetworkOfDevice:(NSManagedObject *)router;
- (BOOL)isIpInWholeRipNetwork:(NSString *)ipAddress;
- (BOOL)isIp:(NSString *)ipAddress fromDevice:(NSManagedObject *)device;
- (BOOL)isIp:(NSString *)ipAddress inRipTable:(NSSet *)ripTable;
- (BOOL)isIp:(NSString *)ipAddress inWholeRipTable:(NSArray *)ripTable;
- (void)linkEthWithSerial:(NSManagedObject *)router;
- (void)showInvalidIpMsgForDOS:(NSString *)ip;
- (void)showInvalidIpMsgForIOS:(NSString *)ip;
- (void)sendPing:(NSArray *)tokens;
- (void)ipConfig:(NSArray *)tokens;
- (void)shutdownPort:(NSArray *)tokens;
- (void)setClockRate:(NSArray *)tokens;
- (void)negateCmd:(NSArray *)tokens;
- (void)setMacAddress:(NSArray *)tokens; 
- (void)network:(NSArray *)tokens; 
- (NSManagedObject *)retrieveSourceOfIp:(NSString *)ipAddress inTable:(NSArray *)ripTable; 
- (NSManagedObject *)selectDestinationPort:(NSManagedObject *)sourcePort; 
- (void)buildRipTable;
- (void)addRipEntryFor:(NSManagedObject *)aRouter 
                source:(NSManagedObject *)sourcePort
           destination:(NSManagedObject *)destinationPort;
- (void)getDestinationPortsFor:(NSManagedObject *)aRouter withCost:(int)cost;
- (void)show:(NSArray *)tokens; 
- (NSMutableArray *)fetchRipTableFrom:(NSManagedObject *)device;
- (NSArray *)retrieveActivePortFrom:(NSManagedObject *)device;
- (BOOL)isIp:(NSString *)ipAddress inSameNetworkFrom:(NSManagedObject *)router;
- (void)scanRouter:(NSManagedObject *)router 
           toTrace:(NSMutableArray *)route
            fromIp:(NSString *)ip1
              toIp:(NSString *)ip2;
- (void)dosTracertTo:(NSString *)ipAddress hop:(int)num time:(NSString *)t1 
                time:(NSString *)t2 time:(NSString *)t3;
- (void)iosTracerouteTo:(NSString *)ipAddress hop:(int)num time:(NSString *)t1 
                   time:(NSString *)t2 time:(NSString *)t3;
- (NSArray *)nextHopFor:(NSManagedObject *)router;
- (void)sendTracert:(NSArray *)tokens;
- (void)sendTraceroute:(NSArray *)tokens;
- (void)globalIpConfig:(NSArray *)tokens;
- (NSString *)lookpUpHostName:(NSString *)hostName;
- (void)showRunningConfig;

@end
