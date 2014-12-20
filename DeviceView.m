//
//  DeviceView.m
//  iNetSimDemo
//
//  Created by Leon Chew on 31/08/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "DeviceView.h"


@implementation DeviceView

- (void)awakeFromNib
{
    CA_isDragged = NO;
}

- (id)initWithFrame:(NSRect)frame
{
    [super initWithFrame:frame];

    [[self cell] accessibilitySetOverrideValue:@"Device" 
                            forAttribute:NSAccessibilityRoleDescriptionAttribute];
    
    NSLog(@"subview of DeviceView = %@", [self subviews]);
		
		// Set the position of this view
		CA_newLocation.x = [self frame].origin.x;
    CA_newLocation.y = [self frame].origin.y;
		
    return self;
    
}

- (BOOL)accessibilityIsIgnored
{
    return YES;
}

- (void)mouseDown:(NSEvent *)e
{
    NSLog(@"mouseDowned..");
    
    
    if( [e clickCount] == 2 )
    {
		  NSLog(@"Open inspector....");
			
			// This device has been double-clicked, so display the inspector for it (done by controller)
		  [CA_delegate showInspector:[self title]];
    }
}

- (void)keyDown:(NSEvent *)e
{
	if( [[e characters] isEqualToString:@" "] )
	{
		// This device is selected and space bar has been pressed, so show the inspector
		[CA_delegate showInspector:[self title]];
	}
}


- (void)mouseDragged:(NSEvent *)e
{
    CA_isDragged = YES;
    NSPoint aPoint = [e locationInWindow];
    aPoint = [[self superview] convertPoint:aPoint toView:nil];
    
    aPoint.x += [e deltaX];
    aPoint.y += [e deltaY];
    
    CA_newLocation.x = aPoint.x - ([self frame].size.width)/2;
    CA_newLocation.y = aPoint.y - ([self frame].size.height)/2;
    
    [[self superview] setNeedsDisplayInRect:[self frame]];
    [self setFrameOrigin:CA_newLocation];
    [self setNeedsDisplay:YES];
    [[self superview] setNeedsDisplay:YES];
		
		// The device may have been moved, so tell the controller to move it just in case
		[CA_delegate moveDevice:[self title] toX:(short)CA_newLocation.x  Y:(short)CA_newLocation.y];
		// redisplay the links
		[CA_delegate updateGUI:self];
}



- (void)mouseUp:(NSEvent *)e
{
    NSLog(@"MouseUpped..");

    CA_isDragged = NO;
}


- (NSPoint)location
{
    return CA_location;
}

- (void)setLocation:(NSPoint)aPoint
{
    CA_location = aPoint;
}

- (NSNumber *)xLoc
{
    return [[CA_xLoc retain] autorelease];
}
- (void)setXLoc:(NSNumber *)xCoord
{
    if(CA_xLoc != xCoord)
    {
        [CA_xLoc release];
        CA_xLoc = [xCoord copy];
        NSPoint aPoint;
        aPoint.x = [CA_xLoc floatValue];
        aPoint.y = [self frame].origin.y;
        [self setFrameOrigin:aPoint];
        [[self superview] setNeedsDisplay:YES];
    }
}

- (NSNumber *)yLoc
{
    return  [[CA_yLoc retain] autorelease];
}
- (void)setYLoc:(NSNumber *)yCoord
{
    if(CA_yLoc != yCoord)
    {
        [CA_yLoc release];
        CA_yLoc = [yCoord copy];
        NSPoint aPoint;
        aPoint.x = [self frame].origin.x;
        aPoint.y = [CA_yLoc floatValue];
        [self setFrameOrigin:aPoint];
        [[self superview] setNeedsDisplay:YES];
    }
}

/*
 Method Name: delegate
 Imported values: none
 Exported value: (id)CA_delagate - controller delegate
 Purpose: This method returns a reference to the controller
 */
- (id)delegate
{
  return [[CA_delegate retain] autorelease];
}

/*
 Method Name: setDelegate:
 Imported values:
 - (id)delegate - the new controller delegate for this device view
 Exported value: none
 Purpose: This method sets the controller delegate for this device view
 */
- (void)setDelegate:(id)delegate
{
	// set the delegate controller if the new one and the current one aren't the same
  if (delegate != CA_delegate)
    {
	[CA_delegate release];
	CA_delegate = [delegate retain];
	}
}

@end
