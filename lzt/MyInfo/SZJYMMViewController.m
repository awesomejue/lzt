//
//  SZJYMMViewController.m
//  lzt
//
//  Created by hwq on 2017/11/17.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "SZJYMMViewController.h"
#import "NetManager.h"
#import "NavigationController.h"
#import "MyTabbarController.h"

@interface SZJYMMViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *qdBtn;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassword;
@property (weak, nonatomic) IBOutlet UITextField *code;
@property (weak, nonatomic) IBOutlet UILabel *hqyzm;
@property (weak, nonatomic) IBOutlet UILabel *titlename;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavHeight;

@end

@implementation SZJYMMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (iPhoneX) {
        _NavHeight.constant += 20;
    }
    self.titlename.text = self.name;
    //[self setTitle:_name];
    [self createUI];
}

- (IBAction)hqyzmTouched:(id)sender {
        NSString *url =[NSString stringWithFormat:@"%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"sms/trade?"];
        NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
    
        url = [NSString stringWithFormat:@"%@token=%@&from=%@&version=%@", url,userInfo[@"token"], @"iOS", InnerVersion];
        [NetManager GetRequestWithUrlString:url finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
   
            NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
            if ([result[@"resultCode"] boolValue]) {
                [self showHint:result[@"resultMsg"] yOffset:0];
            }else {
                [self openCountdown];
                [self showHint:result[@"resultMsg"] yOffset:0];
            //[self.navigationController popViewControllerAnimated:true];
            }
        
    } failed:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        if(error.code == -1009){
            [self showHint:@"网络连接失败，请检查网络状态。" yOffset:0];
        }else if(error.code == -1004){
            [self showHint:@"服务器开了个小差。" yOffset:0];
        }else if(error.code == -1001){
            [self showHint:@"请求超时，请检查网络状态。" yOffset:0];
        }
    }];
        
    
}

- (void)createUI {
    self.qdBtn.layer.cornerRadius = 5;
    self.hqyzm.layer.borderColor = [UIColor redColor].CGColor;
    self.hqyzm.layer.borderWidth = 1;
    self.hqyzm.layer.cornerRadius = 5;
    self.password.delegate = self;
    self.confirmPassword.delegate = self;
    [self.password addTarget:self action:@selector(textChange) forControlEvents:UIControlEventEditingChanged];
    [self.confirmPassword addTarget:self action:@selector(textChange) forControlEvents:UIControlEventEditingChanged];
    
}
- (IBAction)hidekeyboard:(id)sender {
    [_password resignFirstResponder];
    [_confirmPassword resignFirstResponder];
    [_code resignFirstResponder];
}// 开启倒计时效果
-(void)openCountdown{
    
    __block NSInteger time = 59; //倒计时时间
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    
    dispatch_source_set_event_handler(_timer, ^{
        
        if(time <= 0){ //倒计时结束，关闭
            
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //设置按钮的样式
                [self.hqyzm setText:@"重新发送"];
                //[self.hqyzm setTitle:@"重新发送" forState:UIControlStateNormal];
                //[self.yzmLabel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                self.hqyzm.userInteractionEnabled = YES;
            });
            
        }else{
            
            int seconds = time % 60;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //设置按钮显示读秒效果
                [self.hqyzm setText:[NSString stringWithFormat:@"%.2ds", seconds] ];
                //[self.yzmLabel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                self.hqyzm.userInteractionEnabled = NO;
            });
            time--;
        }
    });
    dispatch_resume(_timer);
}
- (IBAction)okBtnClicked:(id)sender {
    [self hidekeyboard:nil];
    if(_password.text.length == 0) {
        [self showHint:@"交易密码不能为空！" yOffset:-Screen_Height /3];
        return;
    }
    if([FuncPublic isRightJYPassword:_password.text]){
        if (_password.text.length < 6) {
            [self showHint:@"交易密码长度为6位" yOffset:-Screen_Height /3];
            return;
        }
        if (_password.text.length > 6) {
            [self showHint:@"交易密码长度为6位" yOffset:-Screen_Height /3];
            return;
        }
    }else{
        [self showHint:@"交易密码只能为6数字组合" yOffset:-Screen_Height /3];
        return;
    }
    if(_confirmPassword.text.length == 0){
        [self showHint:@"确认交易密码不能为空！" yOffset:-Screen_Height /3];
        return;
    }
    if([FuncPublic isRightJYPassword:_confirmPassword.text]){
        if (_confirmPassword.text.length < 6) {
            [self showHint:@"确认交易密码长度为6位" yOffset:-Screen_Height /3];
            return;
        }
        if (_confirmPassword.text.length > 6) {
            [self showHint:@"确认交易密码长度为6位" yOffset:-Screen_Height /3];
            return;
        }
    }else{
        [self showHint:@"确认交易密码只能为6数字组合" yOffset:-Screen_Height /3];
        return;
    }
    if(_code.text.length == 0){
        [self showHint:@"验证码不能为空！" yOffset:-Screen_Height /3];
        return;
    }
    if(![_confirmPassword.text isEqualToString:_password.text]){
        [self showHint:@"两次输入的密码不一致！" yOffset:-Screen_Height /3];
        return;
    }
        NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
        NSString *url =[NSString stringWithFormat:@"%@%@/%@/%@", [FuncPublic SharedFuncPublic].rootserver , @"user",userInfo[@"userId"], @"account/tradepwd"];
        NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
        // [param setValue:@"6381" forKey:@"code"];
        [param setValue:@"iOS" forKey:@"from"];
        [param setValue:InnerVersion forKey:@"version"];
        [param setValue:userInfo[@"token"] forKey:@"token"];
        [param setValue:_password.text forKey:@"pwd"];
        [param setValue:_code.text forKey:@"code"];
        
        [self showHudInView:self.view hint:@"设置交易密码中"];
        [NetManager requestWithUrlString:url andDic:param finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self hideHud];
            NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
            if ([result[@"resultCode"] boolValue]) {
                [self showHint:result[@"resultMsg"] yOffset:-Screen_Height /4];
            }else {
                NSMutableDictionary *user = [[NSMutableDictionary alloc]init];
                NSDictionary *u = [FuncPublic GetDefaultInfo:mUserInfo];
                [user setDictionary:u];
                [user setValue:[NSString stringWithFormat:@"%d", 1] forKey:@"hasCardId"];
                [user setValue:[NSString stringWithFormat:@"%d", 1]  forKey:@"hasTradePassword"];
                [FuncPublic SaveDefaultInfo:user Key:mUserInfo];
                if (_isSMRZ) {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"设置交易密码成功" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self.navigationController popToRootViewControllerAnimated:TRUE];
                        NavigationController *nav =   (NavigationController *) [UIApplication sharedApplication].keyWindow.rootViewController ;
                        MyTabbarController *tab =  nav.viewControllers[0];
                        tab.selectedIndex = 1;
                    }];
                    [alert addAction:ok];
                    [self presentViewController:alert animated:true completion:nil];
                }else {
                    [self showHint:result[@"resultMsg"] yOffset:-Screen_Height /4];
                    [self.navigationController popViewControllerAnimated:true];
//                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"设置交易密码成功" preferredStyle:UIAlertControllerStyleAlert];
//                    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                        [self.navigationController popToRootViewControllerAnimated:TRUE];
//                        NavigationController *nav =   (NavigationController *) [UIApplication sharedApplication].keyWindow.rootViewController ;
//                        MyTabbarController *tab =  nav.viewControllers[0];
//                        tab.selectedIndex = 1;
//                    }];
//                    [alert addAction:ok];
//                    [self presentViewController:alert animated:true completion:nil];
                }
               
            }
            
        } failed:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@", error);
            if(error.code == -1009){
                [self showHint:@"网络连接失败，请检查网络状态。" yOffset:0];
            }else if(error.code == -1004){
                [self showHint:@"服务器开了个小差。" yOffset:0];
            }else if(error.code == -1001){
                [self showHint:@"请求超时，请检查网络状态。" yOffset:0];
            }
            [self hideHud];
        }];
        
        
    //}
}

- (void)textChange {
    NSString *password = self.password.text;
    NSString *confirmPassword = self.confirmPassword.text;
    
    if (password.length>6) {
        self.password.text = [password substringToIndex:password.length - 1];
        [self showHint:@"只能输入6位数字交易密码" yOffset:-Screen_Height / 3];
    }else if (self.confirmPassword.text.length > 6) {
        self.confirmPassword.text = [confirmPassword substringToIndex:confirmPassword.length - 1];
        [self showHint:@"只能输入6位数字交易密码" yOffset:-Screen_Height / 3];
    }
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated: true];
}

@end
