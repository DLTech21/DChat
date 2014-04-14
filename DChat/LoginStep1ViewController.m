//
//  LoginStep1ViewController.m
//  qunyou
//
//  Created by Donal on 13-12-3.
//  Copyright (c) 2013年 vikaa. All rights reserved.
//

#import "LoginStep1ViewController.h"
#import "RegexUtil.h"

@interface LoginStep1ViewController () <UITextFieldDelegate, UIAlertViewDelegate>
{
    BOOL canVertify;
    int leftSecond;
}
@property (weak, nonatomic) IBOutlet UITextField *mobileTF;
@property (weak, nonatomic) IBOutlet UIButton *loginWechatButton;
@end

@implementation LoginStep1ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUI];
}

-(void)setUI
{
    canVertify = YES;
    UILabel *titleLabel                    = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    titleLabel.text                        = @"手机号登录";
    titleLabel.textAlignment               = UITextAlignmentCenter;
    titleLabel.backgroundColor             = [UIColor clearColor];
    titleLabel.textColor                   = [UIColor whiteColor];
    self.navigationItem.titleView          = titleLabel;
    _mobileTF.delegate                     = self;
    
    
    UIView *padView1                       = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 17, _mobileTF.frame.size.height)];
    _mobileTF.leftView                     = padView1;
    _mobileTF.leftViewMode                 = UITextFieldViewModeAlways;
    CALayer *aLayer                        = [CALayer layer];
    aLayer.frame                           = CGRectMake(0, _loginWechatButton.frame.size.height-4, _loginWechatButton.frame.size.width, 1);
    aLayer.backgroundColor                 = _loginWechatButton.titleLabel.textColor.CGColor;
    [_loginWechatButton.layer addSublayer:aLayer];
    
    UIButton *addButton                              = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setTitle:@"下一步" forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addButton setTitleColor:UIColorFromRGB(0x088ec1, 1) forState:UIControlStateHighlighted];
    addButton.titleLabel.font              = [UIFont systemFontOfSize:14];
    [addButton setFrame:CGRectMake(0, 0, 65, 44)];
//    [addButton addTarget:self action:@selector(step2) forControlEvents:UIControlEventTouchUpInside];
    [addButton setBackgroundColor:UIColorFromRGB(0x29bb10, 1)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    [_mobileTF becomeFirstResponder];
}

-(void)step2
{
    if ([RegexUtil isMobileNo:_mobileTF.text]) {
        [_mobileTF resignFirstResponder];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确认手机号码" message:[NSString stringWithFormat:@"我们将发送验证码短信到这个号码:\n%@", _mobileTF.text] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"好", nil];
        [alert show];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"手机号码错误" message:@"你输入的是一个无效的手机号码" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)vertifyMobileSuccess
{
    setIsLogin;
    [_delegate vertifySuccess];
}

-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSMutableString *text = [textField.text mutableCopy] ;
    [text replaceCharactersInRange:range withString:string];
    return [text length] <= 11;
}

-(void)getVertifiedCode:(NSString *)mobile
{
//    [SVProgressHUD show];
//    __weak id this = self;
//    [[AppClient sharedInstance] getVertifiedCode:mobile
//                                         Success:^(NSDictionary *json) {
//                                             [SVProgressHUD dismiss];
//                                             if ([[json objectForKey:@"status"] intValue] == 1) {
//                                                 [this showStep2:[json objectForKey:@"info"]];
//                                             }
//                                             else {
//                                                 [SVProgressHUD showErrorWithStatus:[json objectForKey:@"info"]];
//                                             }
//                                         }
//                                         failure:^(NSString *message) {
//                                             [SVProgressHUD showErrorWithStatus:message];
//                                         }];
}

#pragma mark count down
-(void)countDown
{
    __block int timeout=60; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
//            dispatch_release(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                canVertify = YES;
            });
        }else{
            //            int minutes = timeout / 60;
            int seconds = timeout % 60;
            dispatch_async(dispatch_get_main_queue(), ^{
                canVertify = NO;
                leftSecond = seconds;
            });
            timeout--;
            
        }
    });
    dispatch_resume(_timer);
}

#pragma mark alertview delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0) {
        [self getVertifiedCode:_mobileTF.text];
    }
}

@end
