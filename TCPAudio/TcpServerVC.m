//
//  TcpServerVC.m
//  TCPAudio
//
//  Created by whf on 16/12/9.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "TcpServerVC.h"
#import "TCPServerModel.h"
#import "VoiceConvertHandle.h"

@interface TcpServerVC ()<TCPServerDelegate,VoiceConvertHandleDelegate>
{
    BOOL isConnected;
}
@property (strong, nonatomic) IBOutlet UITextField *portTF;
@property (strong, nonatomic) IBOutlet UIButton *confirmBtn;
@property (strong, nonatomic) IBOutlet UITextView *sendTV;
@property (strong, nonatomic) IBOutlet UITextView *receviedTV;
@property (strong, nonatomic) IBOutlet UIButton *sendBtn;

@property (strong, nonatomic) TCPServerModel *tcpServerModel;

@end

@implementation TcpServerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sendTV.text = @"";
    self.receviedTV.text = @"";
    self.sendTV.backgroundColor = [UIColor grayColor];
    self.receviedTV.backgroundColor = [UIColor grayColor];
    
    _tcpServerModel = [[TCPServerModel alloc] init];
    _tcpServerModel.delegate = self;
    isConnected = NO;
    
    [VoiceConvertHandle shareInstance].delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (IBAction)confirmBtnDidClick:(id)sender forEvent:(UIEvent *)event {
    NSLog(@"confirmBtnDidClick:");
    NSString *port =  self.portTF.text;
    if (isConnected) {
        [self.tcpServerModel closePort];
        [self.confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        self.portTF.enabled = YES;
        isConnected = NO;
        
        [VoiceConvertHandle shareInstance].startRecord = NO;
    }
    else{
        if ([self.tcpServerModel openPort:port] == openSuccessful) {
            self.portTF.enabled = NO;
            [self.confirmBtn setTitle:@"取消" forState:UIControlStateNormal];
            isConnected = YES;
        };
    }
    
}

- (IBAction)sendBtnDidClick:(id)sender forEvent:(UIEvent *)event {
    NSLog(@"sendBtnDidClick:");
    NSData *data = [self.sendTV.text dataUsingEncoding:NSUTF8StringEncoding];
    [self.tcpServerModel sendMessage:data];
}

#pragma mark - delegate
- (void)hadNewConnection:(NSString *)remoteName{
    self.receviedTV.text = [self.receviedTV.text stringByAppendingString:[NSString stringWithFormat:@"\n[%@]已经连接",remoteName]];
    [VoiceConvertHandle shareInstance].startRecord = YES;
}

- (void)receivedClientMessage:(NSData *)data{
 //   NSString *receviedStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
 //   self.receviedTV.text = [self.receviedTV.text stringByAppendingString:[NSString stringWithFormat:@"\n%@",receviedStr]];
    
    [self.receviedTV scrollRangeToVisible:NSMakeRange([self.receviedTV.text length], 0)];
    
    [[VoiceConvertHandle shareInstance] playWithData:data];
}

-(void)covertedData:(NSData *)data{
    if (isConnected) {
        [_tcpServerModel sendMessage:data];
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
