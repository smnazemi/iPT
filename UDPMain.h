//
//  UDPMain.h
//  iNetSim
//
//  Created by Cisco on 28/12/2014.
//
//

#ifndef iNetSim_UDPMain_h
#define iNetSim_UDPMain_h

#import "UDPEcho.h"

@interface UDPMain : NSObject <UDPEchoDelegate>
{
    UDPEcho *      echo;
    NSTimer *      sendTimer;
    NSUInteger     sendCount;
    NSString* receivedMessage;
}

- (BOOL)runServerOnPort:(NSUInteger)port;
- (BOOL)runClientWithHost:(NSString *)host port:(NSUInteger)port;
- (void)sendPacket : (NSString*) message;

@end

@interface UDPMain ()

@property (nonatomic, strong, readwrite) UDPEcho *      echo;
@property (nonatomic, strong, readwrite) NSTimer *      sendTimer;
@property (nonatomic, assign, readwrite) NSUInteger     sendCount;
@property (nonatomic, assign, readwrite) NSString*     receivedMessage;

@end

#endif
