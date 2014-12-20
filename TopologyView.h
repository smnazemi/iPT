//
//  TopologyView.h
//  iNetSimDemo
//
//  Created by Leon Chew on 31/08/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DeviceView.h"


@interface TopologyView : NSView 
{
	@private
	enum {CA_hub, CA_switch, CA_router, CA_pc} CA_deviceType;
	id CA_delegate;
    NSMutableArray *serialPaths;
    NSMutableArray *straightPaths;
    NSMutableArray *consolePaths;
    NSMutableArray *crossoverPaths;
    NSBezierPath *path;
}

- (BOOL)addNewObject:(int)deviceType withObject:(NSManagedObject *)device;
- (id)delegate;
- (void)setDelegate:(id)delegate;
- (NSBezierPath *)serialPath:(NSPoint)p1 :(NSPoint)p4;
- (NSBezierPath *)consolePath:(NSPoint)p1 :(NSPoint)p2;
- (NSBezierPath *)straightPath:(NSPoint)p1 :(NSPoint)p4;
- (NSBezierPath *)crossoverPath:(NSPoint)p1 :(NSPoint)p4;
- (NSPoint)midPoint:(NSPoint)pA :(NSPoint)pB;

- (void)setSerialPaths:(NSMutableArray *)pathArray;
- (NSArray *)serialPaths;
- (void)setStraightPaths:(NSMutableArray *)pathArray;
- (NSArray *)straightPaths;
- (void)setConsolePaths:(NSMutableArray *)pathArray;
- (NSArray *)consolePaths;
- (void)setCrossoverPaths:(NSMutableArray *)pathArray;
- (NSArray *)crossoverPaths;


@end
