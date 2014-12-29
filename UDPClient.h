//
//  UDPClient.h
//  iNetSim
//
//  Created by Cisco on 26/12/2014.
//
//

#ifndef iNetSim_UDPClient_h
#define iNetSim_UDPClient_h


#import <Foundation/Foundation.h>

#include <netinet/in.h>
#include <arpa/inet.h>

typedef enum HandPose
{
    OPEN_HAND,
    GRAB,
    THUMB_UP,
    NO_HAND
} HandPose;

typedef struct HandState
{
    float x;
    float y;
    float z;
    HandPose fingerPose;
    float confidence;
} HandState;


@interface UDPClient : NSObject {
    CFSocketRef cfSocket;
    struct sockaddr_in sa;
}

-(id)initWithDestinationIP:(char *)_ip andPort:(int)_port;
-(void)sendData:(NSData*)_data;
@end

#endif
