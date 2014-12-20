#import "TopologyController.h"

@implementation TopologyController

- (void)awakeFromNib
{
	// create a new toolbar
	NSToolbar *aToolbar = [[NSToolbar alloc] initWithIdentifier:@"deviceToolbar"];
	
	// Set the toolbar delegate to this class and prepare it
	[aToolbar setDelegate:self];
	[aToolbar setAllowsUserCustomization:YES];
	[aToolbar setAutosavesConfiguration:YES];
	
	// Add the toolbar to the window
	[topologyWindow setToolbar:[aToolbar autorelease]];
	
	// Tell the topology that this is its delegate
	[topologyView setDelegate:self];
	
	// load any devices already in the data model
	[self populateTopologyDevices];
	
	// update the gui with the links (should choose a better name than this)
	[self updateGUI:self];
	
	// set initial position for adding devices
	nextDevicePos.x = 0;
	nextDevicePos.y = 0;
}

/*
 Method Name: addDevice:
 Imported values:
 - (id)sender - the object that is calling this method
 Exported value: none
 Purpose: This method adds a device to the topology view using user specified information
 */
- (IBAction)addDevice:(id)sender
{
	/*
	 This method adds a device from the add device panel.  There are two criteria 
	 for successfully adding a device:
	 1. The name must not be used already
	 2. The coordinates must be valid (i.e. not negative).  Note that blank strings
	 equate to 0. - TODO: watch out for coordinates that are bigger than the 
	 topology view!
	 When these criteria are fulfilled, the device can be added.
	 
	 Ideally, the add device panel should specify coordinates according to a 
	 battleship style grid, i.e. A4, D2, etc.  This would make it much easier for 
	 the vision impaired to use the system.  This should be added to the TODO list!
	 */
	int deviceType;
	NSPoint point;
	
	NSLog(@"%@", [addDevicePanel title]);
	
	// Work out what type of device was added from the title of the panel
	if ([[addDevicePanel title] isEqualToString:@"Add Hub"])
    {
		deviceType = CA_hub;
    }
	else if ([[addDevicePanel title] isEqualToString:@"Add Switch"])
    {
		deviceType = CA_switch;
    }
	else if ([[addDevicePanel title] isEqualToString:@"Add Router"])
    {
		deviceType = CA_router;
    }
	else if ([[addDevicePanel title] isEqualToString:@"Add PC"])
    {
		deviceType = CA_pc;
    }
	else
    {
		// Shouldn't be here, something is really wrong!!
		NSLog(@"Device cannot be determined from add device panel title");
		NSLog(@"Please investigate");
    }
	
	// Check if the name is already used. If so, let the user know and don't close 
	// the window
	if ([self isDeviceNameUsed:[newDeviceName stringValue]])
    {
		// Display alert sheet with error message
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"Name already used"];
		[alert setInformativeText:@"Please choose another name."];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert beginSheetModalForWindow:addDevicePanel modalDelegate:self 
                         didEndSelector:nil 
                            contextInfo:nil];
    }
	else
    {
		// Check that the coordinates are valid
		if (([newDeviceXCoord floatValue] < 0.0) || 
            ([newDeviceYCoord floatValue] < 0.0) ||
				([newDeviceXCoord floatValue] > 450.0) ||
				([newDeviceYCoord floatValue] > 350.0))
        {
			// Display alert sheet with error message
			NSAlert *alert = [[[NSAlert alloc] init] autorelease];
			[alert addButtonWithTitle:@"OK"];
			[alert setMessageText:@"Invalid co-ordinates"];
			// the message assumes a topology size of 500x400 (minus 50px for the device button).
			// This should be changed if it is resized.
			[alert setInformativeText:@"Co-ordinates must be within the work area (0,0) to (450,350)."];
			[alert setAlertStyle:NSWarningAlertStyle];
			[alert beginSheetModalForWindow:addDevicePanel modalDelegate:self 
                             didEndSelector:nil 
                                contextInfo:nil];
        }
		else
        {
			// all required criteria fulfilled, so let's add a new device
			point.x = [newDeviceXCoord floatValue];
			point.y = [newDeviceYCoord floatValue];
			[topologyView addNewObject:deviceType withObject:
				[self addToCoreDataDeviceOfType:deviceType 
                                       withName:[newDeviceName stringValue]
                                    description:[newDeviceDesc stringValue] 
                                        atPoint:point]];
			// move the default device position
			nextDevicePos.x += 50.0;
		  if (nextDevicePos.x > 450.0)
				{
				if (nextDevicePos.y > 350.0)
					{
					nextDevicePos.y = 0.0;
					}
				else
					{
					nextDevicePos.y += 50.0;
				  }
				nextDevicePos.x = 0.0;
				}
			
			// close the panel
			[addDevicePanel performClose:self];
        }
    }
}

/*
 The following four methods do similar things, so they are all described here.
 Method Names:
 - addHub:
 - addSwitch:
 - addRouter:
 - addPC:
 Imported values:
 - (id)sender - the object that is calling the method
 Exported value: none
 Purpose: These methods populate the add device panel for their particular devices, and display it
 */
- (void)addHub
{
	// Popluate add device panel
	[addDevicePanel setTitle:@"Add Hub"];
	[newDeviceName setStringValue:[self generateDeviceName:CA_hub]];
	[newDeviceDesc setStringValue:@"New Hub"];
	[newDeviceXCoord setFloatValue:nextDevicePos.x];
	[newDeviceYCoord setFloatValue:nextDevicePos.y];
	
	// Display add device panel
	[addDevicePanel makeKeyAndOrderFront:self];
}

- (void)addSwitch
{
	// Popluate add device panel
	[addDevicePanel setTitle:@"Add Switch"];
	[newDeviceName setStringValue:[self generateDeviceName:CA_switch]];
	[newDeviceDesc setStringValue:@"New Switch"];
	[newDeviceXCoord setFloatValue:nextDevicePos.x];
	[newDeviceYCoord setFloatValue:nextDevicePos.y];
	
	// Display add device panel
	[addDevicePanel makeKeyAndOrderFront:self];
}

- (void)addRouter
{
	// Popluate add device panel
	[addDevicePanel setTitle:@"Add Router"];
	[newDeviceName setStringValue:[self generateDeviceName:CA_router]];
	[newDeviceDesc setStringValue:@"New Router"];
	[newDeviceXCoord setFloatValue:nextDevicePos.x];
	[newDeviceYCoord setFloatValue:nextDevicePos.y];
	
	// Display add device panel
	[addDevicePanel makeKeyAndOrderFront:self];
}

- (void)addPC
{
	// Popluate add device panel
	[addDevicePanel setTitle:@"Add PC"];
	[newDeviceName setStringValue:[self generateDeviceName:CA_pc]];
	[newDeviceDesc setStringValue:@"New PC"];
	[newDeviceXCoord setFloatValue:nextDevicePos.x];
	[newDeviceYCoord setFloatValue:nextDevicePos.y];
	
	// Display add device panel
	[addDevicePanel makeKeyAndOrderFront:self];
}

/*
 Method Name: displayRemoveDeviceWindow:
 Imported values: none
 Exported value: none
 Purpose: This method displays the remove device window (it is called by the menu and toolbar)
 */
- (void)displayRemoveDeviceWindow
{
	[removeDevicePanel makeKeyAndOrderFront:self];
}

/*
 Method Name: removeDevice:
 Imported values:
 - (id)sender - the object that is calling this method
 Exported value: none
 Purpose: This method removes the device selected by the user and any connected links
 */
- (IBAction)removeDevice:(id)sender
{
	NSLog(@"Removing %@", [removeDeviceSelection titleOfSelectedItem]);
	/*
	 The user has selected a device from the list.  Here's what we need to do to 
	 remove the device:
	 1. Find the device in the device array
	 2. Get the list of links it is associated with
	 3. Remove the link views off the topology view
	 4. Remove the device view from off the topology view
	 5. Remove the device itself from the data model
	 */
	
	// filter data model for the specified device name
	[deviceArray setFilterPredicate: [NSPredicate predicateWithFormat: 
		@"deviceName matches[c] %@", [removeDeviceSelection titleOfSelectedItem]]];
	
	// get the links
	
	// remove links of topology view
	
	// remove the device from the topology view
	NSEnumerator *deviceViewEnum = [[topologyView subviews] objectEnumerator];
	DeviceView *aDevice;
	while (aDevice = [deviceViewEnum nextObject])
    {
		if ([[aDevice title] isEqualToString:[removeDeviceSelection 
			titleOfSelectedItem]])
        {
			// This is the device to remove
			[aDevice removeFromSuperview];  // delete it from the topology view
			[aDevice release];              // release it's memory
			[topologyView setNeedsDisplay:YES];  // redraw the topology view
        }
    }
	// delete it out of the data model
	[deviceArray removeObjectAtArrangedObjectIndex:0];  
	
	// close the remove device window
	[removeDevicePanel performClose:self];
}

/*
 The following four methods set up the toolbar
 */
- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar 
{
	return [NSArray arrayWithObjects:
		@"AddHub", @"AddSwitch", @"AddRouter", @"AddPC", 
		@"RemoveDevice",
		NSToolbarSeparatorItemIdentifier,
		NSToolbarSpaceItemIdentifier,
		NSToolbarFlexibleSpaceItemIdentifier,
		NSToolbarCustomizeToolbarItemIdentifier, nil];
}

- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar 
{
	return [NSArray arrayWithObjects:
		@"AddHub", @"AddSwitch", @"AddRouter", @"AddPC",
		NSToolbarSeparatorItemIdentifier, @"RemoveDevice",
		NSToolbarFlexibleSpaceItemIdentifier, nil];
}

- (NSToolbarItem *) toolbar:(NSToolbar *)toolbar 
      itemForItemIdentifier:(NSString *)itemIdentifier 
  willBeInsertedIntoToolbar:(BOOL)flag
{
	NSToolbarItem *item = [[[NSToolbarItem alloc] initWithItemIdentifier: 
		itemIdentifier] autorelease];
	
	if ([itemIdentifier isEqualToString:@"AddHub"])
    {
		[item setLabel:@"Hub"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"Hub.tif"]];
		[item setTarget:self];
		[item setAction:@selector(addHub)];
    }
	if ([itemIdentifier isEqualToString:@"AddSwitch"])
    {
		[item setLabel:@"Switch"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"Switch.tif"]];
		[item setTarget:self];
		[item setAction:@selector(addSwitch)];
    }
	if ([itemIdentifier isEqualToString:@"AddRouter"])
    {
		[item setLabel:@"Router"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"Router.tif"]];
		[item setTarget:self];
		[item setAction:@selector(addRouter)];
    }
	if ([itemIdentifier isEqualToString:@"AddPC"])
    {
		[item setLabel:@"PC"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"PC.tif"]];
		[item setTarget:self];
		[item setAction:@selector(addPC)];
    }
	if ([itemIdentifier isEqualToString:@"RemoveDevice"])
    {
		[item setLabel:@"Remove Device"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"delete.tiff"]];
		[item setTarget:self];
		[item setAction:@selector(displayRemoveDeviceWindow)];
    }
	return item;
}

-(BOOL)validateToolbarItem:(NSToolbarItem*)toolbarItem
{
	BOOL enable = YES;
	if ([[toolbarItem itemIdentifier] isEqualToString:@"RemoveDevice"])
    {
		// We will return YES
		// only when there are devices that can be deleted
		enable = [deviceArrayStatic canRemove];
    }
	return enable;
}

/*
 Method Name: showInspector:
 Imported values:
 - (NSString pointer)deviceName - the name of the device for which the inspector must be shown
 Exported value: none
 Purpose: This method displays the appopriate inspector panel for the specified device
 */
- (void)showInspector:(NSString *)deviceName
{
	// Filter for the device specified.  Unless there's a terrible bug, 
	// only one device should be found
	[deviceArray setFilterPredicate: [NSPredicate predicateWithFormat: 
        @"deviceName matches %@", deviceName]];
	
	// Select the filtered device
	[deviceArray setSelectedObjects:[deviceArray arrangedObjects]];
	
	// Remove the inspector's subview, only if there is one (this is so we can display the correct inspector panel)
	if ([[inspectorView subviews] count] > 0)
    {
		[[[inspectorView subviews] objectAtIndex:0] removeFromSuperviewWithoutNeedingDisplay];
    }
	
	// Find the device type (the device we want is at position 0 in the array)
	if ([[[[deviceArray selectedObjects] objectAtIndex:0] valueForKey:@"deviceType"] isEqualToString:@"Hub"])
    {
		// Tell the hub array which device is selected
		[hubArray setSelectedObjects:[deviceArray arrangedObjects]];
		// add the correct inspector to the inspector view
		[inspectorView addSubview:hubInspector];
    }
	else if ([[[[deviceArray selectedObjects] objectAtIndex:0] valueForKey:@"deviceType"] isEqualToString:@"Switch"])
    {
		// Tell the switch array which device is selected
		[switchArray setSelectedObjects:[deviceArray arrangedObjects]];
		// add the correct inspector to the inspector view
		[inspectorView addSubview:switchInspector];
    }
	else if ([[[[deviceArray selectedObjects] objectAtIndex:0] valueForKey:@"deviceType"] isEqualToString:@"Router"])
    {
		// Tell the router array which device is selected
		[routerArray setSelectedObjects:[deviceArray arrangedObjects]];
		// add the correct inspector to the inspector view
		[inspectorView addSubview:routerInspector];
    }
	else if ([[[[deviceArray selectedObjects] objectAtIndex:0] valueForKey:@"deviceType"] isEqualToString:@"PC"])
    {
		// Tell the PC array which device is selected
		[pcArray setSelectedObjects:[deviceArray arrangedObjects]];
		// add the correct inspector to the inspector view
		[inspectorView addSubview:pcInspector];
    }
	else
    {
		NSLog(@"The type of the selected device cannot be determined - Device name is %@", 
              [[[deviceArray selectedObjects] objectAtIndex:0] valueForKey:@"deviceName"]);
    }
	
	// Redisplay the inspector view
	[inspectorView setNeedsDisplay:YES];
	
	// Display the inspection panel for the device
	[inspectorPanel makeKeyAndOrderFront:self];
}

/*
 Method Name: moveDevice:
 Imported values:
 - (NSString pointer)deviceName - the name of the device to move
 - (short)xCoord - the X coordinate that the device is to be moved to
 - (short)yCoord - the Y coordinate that the device is to be moved to
 Exported value: none
 Purpose: This method alters the information for the device model that specifies where the 
 device view is located in the topology view
 */
- (void)moveDevice:(NSString *)deviceName toX:(short)xCoord  Y:(short)yCoord
{
	// Filter for the device specified.  Unless there's a terrible bug, 
	// only one device should be found
	[deviceArray setFilterPredicate: [NSPredicate predicateWithFormat: 
		@"deviceName matches %@", deviceName]];
	// Select the filtered device
	[deviceArray setSelectedObjects:[deviceArray arrangedObjects]];
	// if there's only one device (should only be one or zero), set its new 
	// coordinates
	if ([[deviceArray selectedObjects] count] == 1)
    {
		// only change the values if it has actually moved somewhere
		if ([[[[deviceArray selectedObjects] objectAtIndex:0]
                    valueForKey:@"xCoord"] shortValue] != xCoord)
        {
			[[[deviceArray selectedObjects] objectAtIndex:0] 
                    setValue:[NSNumber numberWithShort:xCoord] forKey:@"xCoord"];
        }
		if ([[[[deviceArray selectedObjects] objectAtIndex:0]
                    valueForKey:@"yCoord"] shortValue] != yCoord)
        {
			[[[deviceArray selectedObjects] objectAtIndex:0] 
                    setValue:[NSNumber numberWithShort:yCoord] forKey:@"yCoord"];
        }
    }
}

/*
 Method Name: isDeviceNameUsed:
 Imported values:
 - (NSString pointer)deviceName - the device name to search for
 Exported value: (BOOL)used - if YES, the name is already used, otherwise it isn't.
 Purpose: This method searches through the devices to see if the device name is used with another device already
 */
- (BOOL)isDeviceNameUsed:(NSString *)deviceName
{
	BOOL used = YES;
	
	// filter data model for the specified device name
	[deviceArray setFilterPredicate: [NSPredicate predicateWithFormat: 
		@"deviceName matches[c] %@", deviceName]];
	if ([[deviceArray arrangedObjects] count] == 0)
    {
		used = NO;
    }
	
	return used;
}

/*
 Method Name: generateDeviceName:
 Imported values:
 - (int)deviceType - the type of device (specified by the deviceType enumerator)
 Exported value: (NSString pointer)deviceName - the unique name for the device
 Purpose: This method generates a unique name for a device based on its device type
 */
- (NSString *)generateDeviceName:(int)deviceType
{
	NSString *baseName;
	NSString *deviceName;
	int deviceNum = 0;
	
	// Work out the base name and device array
	switch (deviceType)
    {
		case CA_hub:
			baseName = @"Hub";
			break;
		case CA_switch:
			baseName = @"Switch";
			break;
		case CA_router:
			baseName = @"Router";
			break;
		case CA_pc:
			baseName = @"PC";
			break;
    }
	
	// Generate a unique device name for the particular type by incrementing a 
	// number suffix
	do
    {
        deviceName = [[NSString stringWithString: baseName]
            stringByAppendingFormat: @"%d", deviceNum];  // generate the name
        deviceNum++;  // increment the suffix for the next iteration
    }
	while ([self isDeviceNameUsed:deviceName]);
	
	return [deviceName copy];
}


//Method for creating default ports in a device.
- (void)createPort:(NSManagedObject *)device    //Added by Leong on 12/10/2005
{
    
    int i;
    
    if( [[device valueForKey:@"deviceType"] isEqualToString:@"Router"] )
    {
        for( i = 0; i < 2; i++ )
        {
            [self createPortWithName:@"E" ofType:@"Ethernet" withIndex:i forDevice:device];
        }
        for( i = 0; i < 2; i++ )
        {
            [self createPortWithName:@"S" ofType:@"Serial" withIndex:i forDevice:device];
        }
        [self createPortWithName:@"Console" ofType:@"Console" withIndex:0 forDevice:device];
    }
    else if( [[device valueForKey:@"deviceType"] isEqualToString:@"PC"] )
    {
        [self createPortWithName:@"E" ofType:@"Ethernet" withIndex:0 forDevice:device];
        [self createPortWithName:@"S" ofType:@"Serial" withIndex:0 forDevice:device];
    }
}



/*
 Method Name: addToCoreDataDeviceOfType:withName:description:atPoint:
 Imported values:
 - (int)deviceType - the type of device to add to the data model
 - (NSString pointer)deviceName - the name of the new device
 - (NSString pointer)deviceDescription - the description of the new device
 - (NSPoint)point - the location of the device on the topology view
 Exported value: (NSManagedObject pointer)newDevice - the actual data model object of the device
 Purpose: This method adds a device to the topology view using user specified information
 */
- (NSManagedObject *)addToCoreDataDeviceOfType:(int)deviceType 
                                      withName:(NSString *)deviceName 
                                   description:(NSString *)deviceDescription 
                                       atPoint:(NSPoint)point
{
	/*
	 Assumptions for this method:
	 1. It was called from addDevice()
	 2. deviceType is a valid type from the deviceType enumeration
	 3. deviceName is a unique name
	 4. point is inside the topologyView
	 */
	
	NSArrayController *theArray;
	
	// Work out the device array based on deviceType
	switch (deviceType)
    {
		case CA_hub:
			theArray = hubArray;
			break;
		case CA_switch:
			theArray = switchArray;
			break;
		case CA_router:
			theArray = routerArray;
			break;
		case CA_pc:
			theArray = pcArray;
			break;
    }
	
	// Create new device managed object and add it to the model
	NSManagedObject *newDevice = [NSEntityDescription 
                insertNewObjectForEntityForName:[theArray entityName] 
                         inManagedObjectContext:[theArray managedObjectContext]];
    
	[newDevice setValue:[theArray entityName] forKey: @"deviceType"];
	[newDevice setValue:deviceName forKey: @"deviceName"];
	[newDevice setValue:deviceDescription forKey: @"deviceDescription"];
	[newDevice setValue:[NSNumber numberWithFloat:point.x] forKey:@"xCoord"];
	[newDevice setValue:[NSNumber numberWithFloat:point.y] forKey:@"yCoord"];
	[self createPort:newDevice];
	[theArray addObject: newDevice];
	
	return newDevice;
}


- (void)createPortWithName:(NSString *)name 
                    ofType:(NSString *)type 
                 withIndex:(int)index 
                 forDevice:(NSManagedObject *)device    //Added by Leong on 12/10/2005
{
    NSLog(@"Start Creating port!!");
    Port *port;
    NSString *temp;

    port = [NSEntityDescription insertNewObjectForEntityForName:@"Port"
                                         inManagedObjectContext:[portArray managedObjectContext]];
    
    temp = [NSString stringWithFormat:@"%@%d", name, index];
    [port setValue:temp forKey:@"name"];
    [port setValue:type forKey:@"portType"];
    
    if( [type isEqualToString:@"Ethernet"] )
    {
        [port setValue:[port genMacAddress] forKey:@"macAddress"];
        [port setValue:@"" forKey:@"ipAddress"];
        [port setValue:@"Not Available" forKey:@"clockRate"];
    }
    else if( [type isEqualToString:@"Serial"] )
    {
        [port setValue:@"Not Available" forKey:@"macAddress"];
        [port setValue:@"" forKey:@"ipAddress"];
        [port setValue:@"" forKey:@"clockRate"];
    }
    else if( [type isEqualToString:@"Console"] )
    {
        [port setValue:@"Not Available" forKey:@"macAddress"];
        [port setValue:@"Not Available" forKey:@"ipAddress"];
        [port setValue:@"Not Available" forKey:@"subnetMask"];
        [port setValue:@"Not Available" forKey:@"clockRate"];
    }
    
    [port setValue:device forKey:@"deviceport"];
    
}




- (NSArray *)links  //Added by Leong on 12/10/2005
{
    NSManagedObjectContext *moc = [linkArray managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError *fetchError = nil;
    NSArray *fetchResults;
    
    @try
    {
        NSEntityDescription *entity  = [NSEntityDescription entityForName:@"Link"
                                                   inManagedObjectContext:moc];
        [fetchRequest setEntity:entity];
        fetchResults = [moc executeFetchRequest:fetchRequest error:&fetchError];
    }
    @finally
    {
        [fetchRequest release];
    }
    return fetchResults;
}



- (IBAction)updateGUI:(id)sender
{
    NSArray *tempLinks = [self links];
    NSMutableArray *tempSerialPaths = [NSMutableArray new];
    NSMutableArray *tempStriaghtPaths = [NSMutableArray new];
    NSMutableArray *tempConsolePaths = [NSMutableArray new];
    NSMutableArray *tempCrossoverPaths = [NSMutableArray new];
    NSEnumerator *linkEnum = [tempLinks objectEnumerator];
    NSManagedObject *device1;
    NSManagedObject *device2;
    NSManagedObject *port1;
    NSManagedObject *port2;
    NSManagedObject *link;
    NSBezierPath *path; 
    NSPoint pA, pB;
    
    while( link = [linkEnum nextObject] )
    {
        port1 = [link valueForKey:@"port1"];
        port2 = [link valueForKey:@"port2"];
        
        device1 = [port1 valueForKey:@"deviceport"];
        device2 = [port2 valueForKey:@"deviceport"];
        
        pA.x = [[device1 valueForKey:@"xCoord"] floatValue];
        pA.y = [[device1 valueForKey:@"yCoord"] floatValue];
        pB.x = [[device2 valueForKey:@"xCoord"] floatValue];
        pB.y = [[device2 valueForKey:@"yCoord"] floatValue];
        
        if( [[link valueForKey:@"linkType"] isEqualToString:@"Serial cable"] )
        {
            if( [link valueForKey:@"port1"] != nil && [link valueForKey:@"port2"] != nil )
            {
                path = [topologyView serialPath:pA :pB];
                [tempSerialPaths addObject:path];   
            }
        }
        else if( [[link valueForKey:@"linkType"] isEqualToString:@"Console (Rollover)"] )
        {
            if( [link valueForKey:@"port1"] != nil && [link valueForKey:@"port2"] != nil )
            {
                path = [topologyView consolePath:pA :pB];
                [tempConsolePaths addObject:path];
            }
        }
        else if( [[link valueForKey:@"linkType"] isEqualToString:@"Straight-through cable"] )
        {
            if( [link valueForKey:@"port1"] != nil && [link valueForKey:@"port2"] != nil )
            {
                path = [topologyView straightPath:pA :pB];
                [tempStriaghtPaths addObject:path];
            }
        }
        else if( [[link valueForKey:@"linkType"] isEqualToString:@"Crossover cable"] )
        {
            if( [link valueForKey:@"port1"] != nil && [link valueForKey:@"port2"] != nil )
            {
                path = [topologyView crossoverPath:pA :pB];
                [tempCrossoverPaths addObject:path];
            }
        }
        
    }
    
    [topologyView setSerialPaths:tempSerialPaths];
    [topologyView setStraightPaths:tempStriaghtPaths];
    [topologyView setConsolePaths:tempConsolePaths];
    [topologyView setCrossoverPaths:tempCrossoverPaths];
    
    [topologyView setNeedsDisplay:YES];
}

/*
 Method Name: removeLink
 Imported values:
 - (id)sender - the object that is calling this method
 Exported value: none
 Purpose: This method removes the selected link, and also redisplays the links on the
          topology (added by James Hope 2005-10-17)
 */
- (IBAction)removeLink:(id)sender
{
	if ([linkTableArray canRemove])
		{
		[linkTableArray remove:self];
		}
	[self updateGUI:self];
}


/*
 Method Name: populateTopologyDevices
 Imported values: none
 Exported value: none
 Purpose: This method places all the devices in the data model up on the topology view
 (used when opening a new document)
 */
- (void)populateTopologyDevices
{
	NSError *error = nil;
	NSManagedObjectContext *objectContext = [deviceArray managedObjectContext];
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	
	// Set the fetch request entity to the Device data model
	[request setEntity:[NSEntityDescription entityForName:[deviceArray entityName] 
                                   inManagedObjectContext:objectContext]];
	
	// set the sort descriptor according to asc deviceName (not really important 
	// how it's sorted though)
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] 
                                        initWithKey:@"deviceName" ascending:YES];
	
	[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	
	// fetch the managed device objects
	NSArray *array = [objectContext executeFetchRequest:request error:&error];
	
	// this piece of code is pretty bad, need to find a more graceful way to do it
	if ((error != nil) || (array == nil))
    {
		NSLog(@"Error while fetching\n%@",
              ([error localizedDescription] != nil) ? 
              [error localizedDescription] : @"Unknown Error");
		exit(1);
    }
	
	// create an enumerator of the array elements so that we can easily loop 
	// through them
	NSEnumerator *runEnumerator = [array objectEnumerator];
	NSManagedObject *device;
	while (device = [runEnumerator nextObject])
    {
		// work out the device type
		int deviceType;
		if ([[device valueForKey:@"deviceType"] isEqualToString:@"Hub"])
        {
			deviceType = CA_hub;
        }
		else if ([[device valueForKey:@"deviceType"] isEqualToString:@"Switch"])
        {
			deviceType = CA_switch;
        }
		else if ([[device valueForKey:@"deviceType"] isEqualToString:@"Router"])
        {
			deviceType = CA_router;
        }
		else if ([[device valueForKey:@"deviceType"] isEqualToString:@"PC"])
        {
			deviceType = CA_pc;
        }
		// add the device to the topology
		[topologyView addNewObject:deviceType withObject:device];
    }
}








@end
