//
//  TCPServerModel.h
//  TCPAudio
//
//  Created by whf on 16/12/9.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#define openSuccessful 1
#define openFailed 0

@protocol TCPServerDelegate <NSObject>
- (void)hadNewConnection:(NSString *)remoteName;
- (void)receivedClientMessage:(NSData *)data;
@end

@interface TCPServerModel : NSObject

@property(assign, nonatomic) id<TCPServerDelegate> delegate;
- (int)openPort:(NSString *) port;
- (void)closePort;

- (void)sendMessage:(NSData *)data;

@end
