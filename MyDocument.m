//  MyDocument.m
//  iNetSimDemo
//
//  Created by Leon Chew on 31/08/05.
//  Copyright __MyCompanyName__ 2005 . All rights reserved.

#import "MyDocument.h"

@implementation MyDocument

- (id)init 
{
    self = [super init];
    if (self != nil) {
        // initialization code
    }
    return self;
}

- (NSString *)windowNibName 
{
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController 
{
    [super windowControllerDidLoadNib:windowController];
    // user interface preparation code
    
//    NSManagedObjectContext *moc = [self managedObjectContext];
//    int i = 0;
//    while(i < 4)
//    {
//        NSManagedObject *portType;
//        NSString *temp;
//        temp = [NSString stringWithFormat:@"ETH%d", i];
//        portType = [NSEntityDescription insertNewObjectForEntityForName:@"PortType"
//                                                 inManagedObjectContext:moc];
//        [portType setValue:temp forKey:@"name"];
//        [portTypeController addObject:portType];
//        i++;
//    }
    
	
}

- (void) canCloseDocumentWithDelegate:(id)delegate shouldCloseSelector:(SEL)shouldCloseSelector contextInfo:(void *)contextInfo;
{

    [controller OnDocumnetClosed];
    
    [super canCloseDocumentWithDelegate:delegate shouldCloseSelector: shouldCloseSelector contextInfo: contextInfo];
}


- (id)initWithType:(NSString *)type error:(NSError **)error //Added by Leong on 11/10/2005
{
    self = [super initWithType:type error:error];
    if( self != nil )
    {
        NSManagedObjectContext *moc = [self managedObjectContext];
        [[moc undoManager] disableUndoRegistration];
        NSManagedObject *portType;
        NSManagedObject *linkType;
        portType = [NSEntityDescription insertNewObjectForEntityForName:@"PortType"
                                             inManagedObjectContext:moc];
        [portType setValue:@"Serial" forKey:@"name"];
        
        portType = [NSEntityDescription insertNewObjectForEntityForName:@"PortType"
                                             inManagedObjectContext:moc];
        [portType setValue:@"Ethernet" forKey:@"name"];
        
        portType = [NSEntityDescription insertNewObjectForEntityForName:@"PortType"
                                                 inManagedObjectContext:moc];
        [portType setValue:@"Console" forKey:@"name"];
        
        linkType = [NSEntityDescription insertNewObjectForEntityForName:@"LinkType"
                                             inManagedObjectContext:moc];
        [linkType setValue:@"Serial cable" forKey:@"name"];
        
        linkType = [NSEntityDescription insertNewObjectForEntityForName:@"LinkType"
                                                 inManagedObjectContext:moc];
        [linkType setValue:@"Console (Rollover)" forKey:@"name"];
        
        linkType = [NSEntityDescription insertNewObjectForEntityForName:@"LinkType"
                                                 inManagedObjectContext:moc];
        [linkType setValue:@"Crossover cable" forKey:@"name"];
        
        linkType = [NSEntityDescription insertNewObjectForEntityForName:@"LinkType"
                                                 inManagedObjectContext:moc];
        [linkType setValue:@"Straight-through cable" forKey:@"name"];
        
        [moc processPendingChanges];
        [[moc undoManager] enableUndoRegistration];
    }
    return self;
}




- (IBAction)showDeviceModelViewer:(id)sender
{
	[deviceModelViewer makeKeyAndOrderFront:self];
}

- (BOOL)validateMenuItem:(NSMenuItem *)anItem 
{ 
	BOOL valid = NO; 
	SEL action; 
	
	action = [anItem action]; 
	
	if (action == @selector(showDeviceModelViewer:)) 
		{ 
		valid = YES; 
		} 
	else if (action == @selector(addHub:)) 
		{ 
		valid = YES; 
		}
	else if (action == @selector(addSwitch:)) 
		{ 
			valid = YES; 
		}
	else if (action == @selector(addRouter:)) 
	{ 
		valid = YES; 
	}
	else if (action == @selector(addPC:)) 
	{ 
		valid = YES; 
	}
	else if (action == @selector(addLink:)) 
	{ 
		valid = YES; 
	}
	else if (action == @selector(removeDevice:)) 
		{ 
		valid = [deviceArray canRemove]; 
		}
	else if (action == @selector(removeLink:)) 
		{ 
		valid = [linkArray canRemove]; 
		}
	else if (action == @selector(showTerminal:))
		{
		// This should only be enabled if the currently selected device
		// is a Switch, Router, or PC.
		if ([[deviceArray selectedObjects] count] == 1)
			{
			NSString *deviceType = [[NSString stringWithString:
				[[[deviceArray selectedObjects] objectAtIndex:0] valueForKey:@"deviceType"]] autorelease];
			if ([deviceType isEqualToString:@"Switch"] || [deviceType isEqualToString:@"Router"]
					|| [deviceType isEqualToString:@"PC"])
				{
				valid = YES;
				}
			}
		}
	else 
		{ 
		// Call super to enable the Save, Save As, Revert, Page Setup 
		// and Print menus when needed 
		valid = [super validateMenuItem:anItem]; 
		} 
	return valid; 
}

/*
 The following methods are called by menus and in turn call the appropriate
 method in the topology controller to perform the action.  This is essentially
 "glue-code" for the view to the controller (which is the real glue-code).
 */
- (IBAction)addHub:(id)sender
{
	[controller addHub];
}

- (IBAction)addSwitch:(id)sender
{
	[controller addSwitch];
}

- (IBAction)addRouter:(id)sender
{
	[controller addRouter];
}

- (IBAction)addPC:(id)sender
{
	[controller addPC];
}

- (IBAction)addLink:(id)sender
{
	[controller addLink];
}

- (IBAction)removeDevice:(id)sender
{
	[controller displayRemoveDeviceWindow];
}

- (IBAction)removeLink:(id)sender
{
	[controller displayRemoveLinkWindow];
}

- (IBAction)showTerminal:(id)sender
{
	NSString *deviceName = [NSString stringWithString:
				[[[deviceArray selectedObjects] objectAtIndex:0] valueForKey:@"deviceName"]];
	[terminalController newSession:deviceName];
}


- (NSError *)willPresentError:(NSError *)inError {
    // The error is a Core Data validation error if its domain is
    // NSCocoaErrorDomain and it is between the minimum and maximum
    // for Core Data validation error codes.
    if (!([[inError domain] isEqualToString:NSCocoaErrorDomain])) {
        return inError;
    }
    int errorCode = [inError code];
    if ((errorCode < NSValidationErrorMinimum) ||
        (errorCode > NSValidationErrorMaximum)) {
        return inError;
    }
    // If there are multiple validation errors, inError is an 
    // NSValidationMultipleErrorsError. If it's not, return it
    if (errorCode != NSValidationMultipleErrorsError) {
        return inError;
    }
    // For an NSValidationMultipleErrorsError, the original errors
    // are in an array in the userInfo dictionary for key NSDetailedErrorsKey
    NSArray *detailedErrors = [[inError userInfo] objectForKey:NSDetailedErrorsKey];
    // For this example, only present error messages for up to 3 validation errors at a time.
    unsigned numErrors = [detailedErrors count];
    NSMutableString *errorString = [NSMutableString stringWithFormat:@"%u validation errors have occurred", numErrors];
    if (numErrors > 4) {
        [errorString appendFormat:@".\nThe first 4 are:\n"];
    } else {
        [errorString appendFormat:@":\n"];
    }
    unsigned i, displayErrors = numErrors > 4 ? 4 : numErrors;
    for (i = 0; i < displayErrors; i++) {
        [errorString appendFormat:@"%@\n",
            [[detailedErrors objectAtIndex:i] localizedDescription]];
    }
    // Create a new error with the new userInfo
    NSMutableDictionary *newUserInfo = [NSMutableDictionary
                dictionaryWithDictionary:[inError userInfo]];
    [newUserInfo setObject:errorString forKey:NSLocalizedDescriptionKey];
    NSError *newError = [NSError errorWithDomain:[inError domain] code:[inError code] userInfo:newUserInfo];  
    return newError;
}

@end
