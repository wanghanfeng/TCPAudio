//
//  TCPServerModel.m
//  TCPAudio
//
//  Created by whf on 16/12/9.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "TCPServerModel.h"
#import "GCDAsyncSocket.h"

#define sendTimeOut -1


@interface TCPServerModel()<GCDAsyncSocketDelegate>

@property(strong, nonatomic)GCDAsyncSocket *serverSocket;
@property(strong, nonatomic)NSMutableArray *clientList;

@end

@implementation TCPServerModel

- (instancetype)init{
    self = [super init];
    if (self) {
        _serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        _clientList = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (int)openPort:(NSString *)port{
    unsigned short portInt = [port integerValue];
    NSError *error = nil;
    BOOL status = [_serverSocket acceptOnPort:portInt error:&error];
    if (status&&!error) {
        return openSuccessful;
    }
    else{
        return openFailed;
    }
}

- (void)closePort{
    [_serverSocket disconnect];
}

- (void)sendMessage:(NSData *)data{
    //默认全局发送
    for (int i=0; i<_clientList.count; i++) {
        [(GCDAsyncSocket *)_clientList[i] writeData:data withTimeout:sendTimeOut tag:0];
    }
}
#pragma mark - delegate
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{
    
    [_clientList addObject:newSocket];
    if ([self.delegate respondsToSelector:@selector(hadNewConnection:)]) {
        NSString *remoteName =  [newSocket.connectedHost stringByAppendingString:[NSString stringWithFormat:@" %d",newSocket.connectedPort]];
        [self.delegate hadNewConnection:remoteName];
    }
    [newSocket readDataWithTimeout:- 1 tag:0];
}


- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    if ([self.delegate respondsToSelector:@selector(receivedClientMessage:)]) {
        [self.delegate receivedClientMessage:data];
        [sock readDataWithTimeout:- 1 tag:0];
    }
}

/**
 * Called when a socket has read in data, but has not yet completed the read.
 * This would occur if using readToData: or readToLength: methods.
 * It may be used to for things such as updating progress bars.
 **/
- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
    
}

/**
 * Called when a socket has completed writing the requested data. Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    
}

/**
 * Called when a socket has written some data, but has not yet completed the entire write.
 * It may be used to for things such as updating progress bars.
 **/
- (void)socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
    
}

@end
