//
//  DeviceView.h
//  iNetSim
//
//  Created by Leon Chew on 31/08/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DeviceView : NSButton 
{
    @private
    NSPoint CA_location;
    NSPoint CA_newLocation;
    NSNumber *CA_xLoc;
    NSNumber *CA_yLoc;
    BOOL CA_isDragged;
	  id CA_delegate;
}


- (NSPoint)location;
- (void)setLocation:(NSPoint)aPoint;

- (NSNumber *)xLoc;
- (void)setXLoc:(NSNumber *)xCoord;

- (NSNumber *)yLoc;
- (void)setYLoc:(NSNumber *)yCoord;

- (id)delegate;
- (void)setDelegate:(id)delegate;

@end
