//
//  Port.m
//  Topology
//
//  Created by Leon Chew on 17/09/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "Port.h"


@implementation Port

- (NSString *)uniqueName
{
    return [NSString stringWithFormat:@"%@, (%@)", 
        [self valueForKeyPath:@"deviceport.deviceName"],
        [self valueForKey:@"name"]];
}


- (int)randomDigit:(int)max
{
    int generated;
    
    generated = (random() % max);
    return generated;
}


- (NSString *)hexPair
{
    NSString *temp1 = @"1234567890ABCDEF";
    NSString *temp2;
    char c1, c2;
    
    c1 = [temp1 characterAtIndex:[self randomDigit:16]];
    c2 = [temp1 characterAtIndex:[self randomDigit:16]];
    
    temp2 = [NSString stringWithFormat:@"%c%c", c1, c2];
    
    return temp2;
}


- (NSString *)genMacAddress
{
    NSString *tempPair;
    NSString *tempAddress;
    NSString *macAddress;
    int i;
    
    tempAddress = [NSString stringWithString:[self hexPair]];
    
    for (i = 0; i < 5; i++)
    {
        tempPair = [NSString stringWithFormat:@":%@", [self hexPair]];
        NSLog(@"tempPair = %@", tempPair);
        tempAddress = [tempAddress stringByAppendingString:tempPair];
    }
    macAddress = tempAddress;
    return macAddress;
}





+ (void)initialize
{
    if (self == [Port class])
    {
        NSArray *keys = [NSArray arrayWithObjects:@"name", @"portType", nil];
        [self setKeys:keys triggerChangeNotificationsForDependentKey:@"uniqueName"];
    }
}

@end
