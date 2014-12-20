//
//  Link.m
//  iNetSim
//
//  Created by Leon Chew on 20/09/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "Link.h"


@implementation Link



- (void)awakeFromInsert
{
    static int tempID = 1;
    [super awakeFromInsert];
    [self setValue:[NSNumber numberWithInt:tempID++]
            forKey:@"linkId"];
    [self setValue:[NSString stringWithFormat:@"L%@", [self valueForKey:@"linkId"]]
            forKey:@"name"];
}

@end
