//
//  TCPClientModel.h
//  TCPAudio
//
//  Created by whf on 16/12/9.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#define openSuccessful 1
#define openFailed 0

@protocol TCPClientDelegate <NSObject>

- (void)didConnectToHost:(NSString *)hostInfo;
- (void)receivedServerMessage:(NSData *)data;

@end

@interface TCPClientModel : NSObject

@property(assign, nonatomic) id<TCPClientDelegate> delegate;

- (int)connectToServerHost:(NSString *)host port:(NSString *)port;
- (void)closeConnected;
- (void)sendMessage:(NSData *)data;
@end
