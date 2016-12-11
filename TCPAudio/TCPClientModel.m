//
//  TCPClientModel.m
//  TCPAudio
//
//  Created by whf on 16/12/9.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "TCPClientModel.h"
#import "GCDAsyncSocket.h"

#define sendTimeOut -1

@interface TCPClientModel()<GCDAsyncSocketDelegate>

@property(strong, nonatomic)GCDAsyncSocket *clientSocket;

@end

@implementation TCPClientModel

- (instancetype)init{
    self = [super init];
    if (self) {
        _clientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

- (int)connectToServerHost:(NSString *)host port:(NSString *)port{
    unsigned short portInt = [port integerValue];
    NSError *error = nil;
    BOOL status = [_clientSocket connectToHost:host onPort:portInt withTimeout:1000 error:&error];
    if (status&&!error) {
        return openSuccessful;
    }
    else{
        return openFailed;
    }
}

- (void)closeConnected{
    [_clientSocket disconnect];
}

- (void)sendMessage:(NSData *)data{
    [_clientSocket writeData:data withTimeout:sendTimeOut tag:0];
}


#pragma mark - delegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    if ([self.delegate respondsToSelector:@selector(didConnectToHost:)]) {
        NSString *hostInfo = [host stringByAppendingString:[NSString stringWithFormat:@" %d",port]];
        [self.delegate didConnectToHost:hostInfo];
    }
    [_clientSocket readDataWithTimeout:-1 tag:0];
}

/**
 * Called when a socket has completed reading the requested data into memory.
 * Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    if ([self.delegate respondsToSelector:@selector(receivedServerMessage:)]) {
        [self.delegate receivedServerMessage:data];
    }

    [_clientSocket readDataWithTimeout:- 1 tag:0];
}

/**
 * Called when a socket has read in data, but has not yet completed the read.
 * This would occur if using readToData: or readToLength: methods.
 * It may be used to for things such as updating progress bars.
 **/
- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
    
}

@end
