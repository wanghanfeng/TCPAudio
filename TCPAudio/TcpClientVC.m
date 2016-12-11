//
//  TcpClientVC.m
//  TCPAudio
//
//  Created by whf on 16/12/9.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "TcpClientVC.h"
#import "TCPClientModel.h"
#import "VoiceConvertHandle.h"

@interface TcpClientVC ()<TCPClientDelegate,VoiceConvertHandleDelegate>
{
    BOOL isConnected;
}


@property (strong, nonatomic) IBOutlet UITextField *hostTF;
@property (strong, nonatomic) IBOutlet UIButton *confirmBtn;
@property (strong, nonatomic) IBOutlet UITextField *portTF;
@property (strong, nonatomic) IBOutlet UITextView *sendTV;
@property (strong, nonatomic) IBOutlet UITextView *recevieTV;
@property (strong, nonatomic) IBOutlet UIButton *sendBtn;

@property(strong, nonatomic)TCPClientModel *tcpClientModel;

@end

@implementation TcpClientVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sendTV.text = @"";
    self.recevieTV.text = @"";
    self.sendTV.backgroundColor = [UIColor grayColor];
    self.recevieTV.backgroundColor = [UIColor grayColor];
    
    _tcpClientModel = [[TCPClientModel alloc] init];
    _tcpClientModel.delegate = self;
    isConnected = NO;
    
    [VoiceConvertHandle shareInstance].delegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
- (IBAction)confirmBtnDidClick:(id)sender {
    NSString *hostStr = self.hostTF.text;
    NSString *portStr = self.portTF.text;
    
    if (isConnected) {
        self.hostTF.enabled = YES;
        self.portTF.enabled = YES;
        [self.confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_tcpClientModel closeConnected];
        isConnected = NO;
        
        [VoiceConvertHandle shareInstance].startRecord = NO;
    }
    else{
        if ([_tcpClientModel connectToServerHost:hostStr port:portStr]==openSuccessful) {
            self.hostTF.enabled = NO;
            self.portTF.enabled = NO;
            [self.confirmBtn setTitle:@"取消" forState:UIControlStateNormal];
            isConnected = YES;
        }
    }
    
}
- (IBAction)sendBtnDidClick:(id)sender {
    NSData *data = [self.sendTV.text dataUsingEncoding:NSUTF8StringEncoding];
    [_tcpClientModel sendMessage:data];
}

#pragma mark - delegate

- (void)didConnectToHost:(NSString *)hostInfo{
    self.recevieTV.text = [self.recevieTV.text stringByAppendingString:[NSString stringWithFormat:@"\n%@",hostInfo]];
    
    [VoiceConvertHandle shareInstance].startRecord = YES;
}

- (void)receivedServerMessage:(NSData *)data{
  //  NSString *receviedStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
   // self.recevieTV.text = [self.recevieTV.text stringByAppendingString:[NSString stringWithFormat:@"\n%@",receviedStr]];
    
    [self.recevieTV scrollRangeToVisible:NSMakeRange([self.recevieTV.text length], 0)];
    
    [[VoiceConvertHandle shareInstance] playWithData:data];
}

-(void)covertedData:(NSData *)data{
    if (isConnected) {
        [_tcpClientModel sendMessage:data];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
