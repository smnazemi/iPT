//
//  Port.h
//  Topology
//
//  Created by Leon Chew on 17/09/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Port : NSManagedObject 
{

}

- (NSString *)uniqueName;
- (int)randomDigit:(int)max;
- (NSString *)hexPair;
- (NSString *)genMacAddress;

@end
