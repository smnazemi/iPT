//
//  TopologyView.m
//  iNetSimDemo
//
//  Created by Leon Chew on 31/08/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "TopologyView.h"


@implementation TopologyView

- (void)awakeFromNib
{
	// Set the accessibility attributes for the topology view
	[self accessibilitySetOverrideValue:@"Topology" 
												 forAttribute:NSAccessibilityTitleAttribute];
	[self accessibilitySetOverrideValue:@"Work Area" 
												 forAttribute:NSAccessibilityRoleDescriptionAttribute];
	[self accessibilitySetOverrideValue:@"View" 
												 forAttribute:NSAccessibilityRoleAttribute];    
}

- (id)initWithFrame:(NSRect)frame 
{
	self = [super initWithFrame:frame];
	if (self) 
    {
    }
	return self;
}


- (void)dealloc
{
    [serialPaths release];
    [straightPaths release];
    [consolePaths release];
    [crossoverPaths release];
    
    serialPaths = nil;
    straightPaths = nil;
    consolePaths = nil;
    crossoverPaths = nil;
    
    [super dealloc];
}


- (NSPoint)midPoint:(NSPoint)pA :(NSPoint)pB
{
    NSPoint midP;
    
    midP.x = (pA.x+pB.x)/2;
    midP.y = (pA.y+pB.y)/2;
    
    return midP;
}


// Change the point obtained from the location of a device view to the center of the device view.
// A device view has width of 50 and height of 50.
- (NSPoint)centreP:(NSPoint)p
{
    NSPoint tempP;
    tempP.x = p.x + 25.0;
    tempP.y = p.y + 25.0;
    return tempP;
}



- (NSBezierPath *)crossoverPath:(NSPoint)p1 :(NSPoint)p4
{
    NSBezierPath *path1 = [NSBezierPath bezierPath];
    float pattern[] = {7.0, 3.0};
    
    [path1 moveToPoint:[self centreP:p1]];
    [path1 lineToPoint:[self centreP:p4]];
    [path1 setLineDash:pattern count:2 phase:0.0];
    [path1 setLineWidth:2.0];
    
    return path1;
}


- (NSBezierPath *)straightPath:(NSPoint)p1 :(NSPoint)p4
{
    NSBezierPath *path1 = [NSBezierPath bezierPath];
    
    [path1 moveToPoint:[self centreP:p1]];
    [path1 lineToPoint:[self centreP:p4]];
    [path1 setLineWidth:2.0];
    
    return path1;
}



- (NSBezierPath *)serialPath:(NSPoint)p1 :(NSPoint)p4
{
    NSPoint p2, p3, midP;
    NSBezierPath *path1 = [NSBezierPath bezierPath];
    
    midP = [self midPoint:[self centreP:p1] :[self centreP:p4]];
    p2.x = midP.x + 8;
    p2.y = midP.y - 8;
    p3.x = midP.x - 8;
    p3.y = midP.y + 8;
    
    [path1 moveToPoint:[self centreP:p1]];
    [path1 lineToPoint:p2];
    [path1 lineToPoint:p3];
    [path1 lineToPoint:[self centreP:p4]];
    [path1 setLineWidth:2.0];
    
    return path1;
}


- (NSBezierPath *)consolePath:(NSPoint)p1 :(NSPoint)p2
{
    NSBezierPath *path1 = [NSBezierPath bezierPath];
    float pattern[] = {2.0, 2.0};
    NSPoint c1, c2;
    
    c1.x = [self centreP:p1].x + 50;
    c1.y = [self centreP:p1].y - 50;
    c2.x = [self centreP:p2].x - 50;
    c2.y = [self centreP:p2].y - 50;
    
    [path1 moveToPoint:[self centreP:p1]];
    [path1 curveToPoint:[self centreP:p2] controlPoint1:c1 controlPoint2:c2];
    [path1 setLineDash:pattern count:2 phase:0.0];
    [path1 setLineWidth:2.0];
    return path1;
}



- (void)setSerialPaths:(NSMutableArray *)pathArray
{
    if( serialPaths != pathArray )
    {
        [serialPaths release];
        serialPaths = pathArray;
    }
}
- (NSArray *)serialPaths
{
    return serialPaths;
}


- (void)setStraightPaths:(NSMutableArray *)pathArray
{
    if( straightPaths != pathArray )
    {
        [straightPaths release];
        straightPaths = pathArray;
    }
}


- (NSArray *)straightPaths
{
    return straightPaths;
}



- (void)setConsolePaths:(NSMutableArray *)pathArray
{
    if( consolePaths != pathArray )
    {
        [consolePaths release];
        consolePaths = pathArray;
    }
}



- (NSArray *)consolePaths
{
    return consolePaths;
}



- (void)setCrossoverPaths:(NSMutableArray *)pathArray
{
    if( crossoverPaths != pathArray )
    {
        [crossoverPaths release];
        crossoverPaths = pathArray;
    }
}



- (NSArray *)crossoverPaths
{
    return crossoverPaths;
}




- (void)drawRect:(NSRect)rect 
{
	// Drawing code here.
	[[NSColor whiteColor] set];
	NSRectFill([self bounds]);
    
    NSEnumerator *serialEnum = [serialPaths objectEnumerator];
    NSEnumerator *straightEnum = [straightPaths objectEnumerator];
    NSEnumerator *consoleEnum = [consolePaths objectEnumerator];
    NSEnumerator *crossoverEnum = [crossoverPaths objectEnumerator];

    
    while( path = [serialEnum nextObject] )
    {
        [[NSColor redColor] set];
        [path stroke];
    }
    
    while( path = [straightEnum nextObject] )
    {
        [[NSColor blackColor] set];
        [path stroke];
    }
    
    
    while( path = [consoleEnum nextObject] )
    {
        [[NSColor blackColor] set];
        [path stroke];
    }
    
    
    while( path = [crossoverEnum nextObject] )
    {
        [[NSColor blackColor] set];
        [path stroke];
    }
    
    
}

- (BOOL)accessibilityIsIgnored
{
	return NO;
}

/*
 Method Name: addNewObject:withObject:
 Imported values:
  - (int)deviceType - states the type of the device, as per the deviceType enumeration (see header file)
  - (NSManagedObject *)device - a pointer to the device model object containing all the data about the device
 Exported value: (BOOL)isAdded - states whether or not a device view was successfully added to this topology view
 Purpose: This method creates a device view with the appropriate icon for the type of device, and places it on
          this topology view.
 */
- (BOOL)addNewObject:(int)deviceType withObject:(NSManagedObject *)device
{
	NSImage *icon;           // Device icon
	BOOL isAdded = NO;       // flag to return stating if device view was added or not (default is NO)
	NSString *iconName;      // the string containing the name of the device icon
	NSNumber *xLoc;          // x coordinate of the device view
	NSNumber *yLoc;          // y coordinate of the device view
	NSString *deviceName;    // The name of the device
	DeviceView *deviceView;  // the device view itself
	
	/*
	 The following switch statement checks the device type specified by
	 the sender, and chooses the correct icon for the device
	 */
	switch (deviceType)
		{
		case CA_hub:
			iconName = @"Hub";
			break;
		case CA_switch:
			iconName = @"Switch";
			break;
		case CA_router:
			iconName = @"Router";
			break;
		case CA_pc:
			iconName = @"PC";
			break;
		}
	// create the NSImage that contains the device icon
  icon = [NSImage imageNamed:iconName];
	
	// Get the name, x coordinate, and y coordinate of the device from the device managed object
	deviceName = [device valueForKey:@"deviceName"];
	xLoc = [device valueForKey:@"xCoord"];
	yLoc = [device valueForKey:@"yCoord"];
	
	NSLog(@"Adding icon.....with name = %@", deviceName);
	
	// if the device icon NSImage object was successfully created, go on to create the device view
	if(icon)
		{
		NSLog(@"Icon is created.......");
		
		// set the location for the view
		NSPoint newPoint;
		newPoint.x = [xLoc floatValue];
		newPoint.y = [yLoc floatValue];
		
		// create the view
		deviceView = [[DeviceView alloc] initWithFrame:
			NSMakeRect(newPoint.x, newPoint.y, 50, 50)];
		
		// set the appropriate attributes for the view (self explanatory)
		[deviceView setBordered:NO];
		[deviceView setImagePosition:NSImageAbove];
		[deviceView setTitle:deviceName];
		[deviceView setImage:icon];
		[deviceView setLocation:newPoint];
		[deviceView setDelegate:CA_delegate];
		[deviceView bind:@"title" toObject:device withKeyPath:@"deviceName" options:nil];
		[deviceView bind:@"xLoc" toObject:device withKeyPath:@"xCoord" options:nil];
		[deviceView bind:@"yLoc" toObject:device withKeyPath:@"yCoord" options:nil];
		[self addSubview:deviceView];
		[self setNextKeyView:deviceView];
		[self setNeedsDisplay:YES];
		
		// set the flag to say it was successfully added
		isAdded = YES;
		}
	
	// release the icon because it is no longer needed
	[icon release];
	
	return isAdded;
}

- (BOOL)isFlipped
{
	return YES;
}

- (void)mouseDown:(NSEvent *)e
{
	NSPoint aPoint;
	aPoint = [self convertPoint:[e locationInWindow] toView:nil];
	NSLog(@"Topology point = (%2f, %2f)", aPoint.x, aPoint.y);

	// TODO: handle the device view selection
	
}

/*
 Method Name: delegate
 Imported values: none
 Exported value: (id)CA_delagate - topology controller delegate
 Purpose: This method returns a reference to the topology controller
 */
- (id)delegate
{
  return [[CA_delegate retain] autorelease];
}

/*
 Method Name: setDelegate:
 Imported values:
 - (id)delegate - the new topology controller delegate for this topology view
 Exported value: none
 Purpose: This method sets the topology controller delegate for this topology view
 */
- (void)setDelegate:(id)delegate
{
  if (delegate != CA_delegate)
    {
		[CA_delegate release];
		CA_delegate = [delegate retain];
		}
}

@end
