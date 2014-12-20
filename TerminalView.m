//
//  TerminalView.m
//  iNetSim
//
//  Created by James Hope on 6/10/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "TerminalView.h"


@implementation TerminalView

- (id)init
{
	[super init];
	
	[self setUsesFontPanel:NO];
	[self setSelectable:YES];
	[self setRichText:NO];
	[self setFont:[NSFont fontWithName:@"Monaco" size:12.0]];
	
	return self;
}

- (id)initWithFrame:(NSRect)frame
{
	[super initWithFrame:frame];
	
	[self setUsesFontPanel:NO];
	[self setSelectable:YES];
	[self setRichText:NO];
	[self setFont:[NSFont fontWithName:@"Monaco" size:12.0]];
	
	return self;
}

- (void)setOSController:(OSController *)osController
{
	if (osController != CA_osController)
		{
		[CA_osController release];
		CA_osController = [osController retain];
		}
}

- (OSController *)osController
{
	return [[CA_osController retain] autorelease];
}

// Overridden methods

- (void)insertText:(NSString *)aString
{
	if ([CA_osController sendData:aString])
		{
		[super insertText:aString];
		}
}

- (void)insertNewline:(id)sender
{
	if ([CA_osController sendData:@"newline"])
		{
		[super insertNewLine:sender];
		}
}

- (void)deleteBackward:(id)sender
{
	if ([CA_osController sendData:@"backspace"])
		{
		[super deleteBackward:sender];
		}
}

- (void)moveForward:(id)sender
{
	if ([CA_osController sendData:@"rightarrow"])
		{
		[super moveForward:sender];
		}
}

- (void)moveBackward:(id)sender
{
	if ([CA_osController sendData:@"leftarrow"])
		{
		[super moveBackward:sender];
		}
}

- (void)moveUp:(id)sender
{
	if ([CA_osController sendData:@"uparrow"])
		{
		[super moveUp:sender];
		}
}

- (void)moveDown:(id)sender
{
	if ([CA_osController sendData:@"downarrow"])
		{
		[super moveDown:sender];
		}
}

- (void)insertTab:(id)sender
{
	if ([CA_osController sendData:@"tab"])
		{
		[super insertTab:sender];
		}
}

- (void)appendString:(NSString *)aString
{
	int len = [[self string] length];
	[self replaceCharactersInRange:NSMakeRange(len, 0) withString:aString];
	[self scrollRangeToVisible:NSMakeRange([[self string] length], 0)];
}

// The following methods are just stubs to prevent the super class versions from being invoked
// as the super class versions cause problems
- (void)deleteForward:(id)sender
{
	// Do nothing
}

- (void)moveToEndOfDocument:(id)sender
{
	// Do nothing
}

- (void)moveToBeginningOfDocument:(id)sender
{
	// Do nothing
}

- (void)moveToEndOfLine:(id)sender
{
	// Do nothing
}

- (void)moveToBeginningOfLine:(id)sender
{
	// Do nothing
}

@end
