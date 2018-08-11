//
//  RegisterViewController.m
//  lzt
//
//  Created by hwq on 2017/11/15.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "RegisterViewController.h"
#import <AdSupport/AdSupport.h>
#import "RuleRegisterController.h"
#import "NetManager.h"
#import "NavigationController.h"
#import "CPXQViewController.h"
#import "MyTabbarController.h"
#import "LoginViewController.h"
#import "ForgetPasswordViewController.h"
#import "htmlViewController.h"
//推送
#import <GTSDK/GeTuiSdk.h>     // GetuiSdk头文件应用
#define FONT  [UIFont fontWithName:@"PingFang SC" size:16]

@interface RegisterViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *zcToplayoutconstraint;
@property (weak, nonatomic) IBOutlet UILabel *yzmLabel;
@property (weak, nonatomic) IBOutlet UIButton *ZCBtn;
- (IBAction)ljqgBtn:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *telephone;
@property (weak, nonatomic) IBOutlet UITextField *code;
@property (weak, nonatomic) IBOutlet UITextField *loginpassword;
@property (weak, nonatomic) IBOutlet UITextField *jypassword;
@property (weak, nonatomic) IBOutlet UITextField *recommendPhone;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
    [self hideBackButtonText];
    if (iPhoneX) {
        _zcToplayoutconstraint.constant += 20;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)createUI {
    self.ZCBtn.layer.cornerRadius = 5;
    self.yzmLabel.layer.borderColor = [UIColor redColor].CGColor;
    self.yzmLabel.layer.borderWidth = 1;
    self.yzmLabel.layer.cornerRadius = 5;
    if (_isLoginRegister) {
        self.telephone.text = _phone;
    }
    
    _telephone.delegate = self;
    _telephone.font = FONT;
    _code.font = FONT;
    _jypassword.font = FONT;
    _loginpassword.font = FONT;
    _recommendPhone.font = FONT;
    _code.delegate = self;
    _jypassword.delegate = self;
    _loginpassword.delegate = self;
    _recommendPhone.delegate = self;
}
- (IBAction)back:(id)sender {
    NSArray *viewcontrollers=self.navigationController.viewControllers;
    if (viewcontrollers.count>1) {
        if ([viewcontrollers objectAtIndex:viewcontrollers.count-1]==self) {
            //push方式
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else{
        //present方式
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    //[self.navigationController popViewControllerAnimated:true];
}
- (IBAction)registerClicked:(id)sender {
    [_telephone resignFirstResponder];
    [_code resignFirstResponder];
    [_loginpassword resignFirstResponder];
    [_jypassword resignFirstResponder];
    [_recommendPhone resignFirstResponder];
    if(_telephone.text.length == 0) {
        [self showHint:@"手机号码不能为空！" yOffset:0];
        return;
    }
    if(_code.text.length == 0) {
        [self showHint:@"验证码不能为空！" yOffset:0];
        return;
    }
    if(_loginpassword.text.length == 0) {
        [self showHint:@"登陆密码不能为空！" yOffset:0];
        return;
    }
    
    if([FuncPublic isRightLoginPassword:_loginpassword.text]){
        if (_loginpassword.text.length < 6) {
            [self showHint:@"登陆密码长度大于6位" yOffset:0];
            return;
        }
        if (_loginpassword.text.length > 16) {
            [self showHint:@"登陆密码长度小于16位" yOffset:0];
            return;
        }
    }else{
        [self showHint:@"登陆密码只能为6～16位字母和数字组合" yOffset:0];
        return;
    }
        NSString *url =[NSString stringWithFormat:@"%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"user/register"];
        NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
        // [param setValue:@"6381" forKey:@"code"];
        [param setValue:@"iOS" forKey:@"from"];
        [param setValue:_telephone.text forKey:@"phone"];
        [param setValue:_code.text forKey:@"code"];
        [param setValue:InnerVersion forKey:@"version"];
        [param setValue:_loginpassword.text forKey:@"password"];
        [param setValue:_recommendPhone.text forKey:@"recommendCode"];
        NSString *clientId = [GeTuiSdk clientId];
        [param setValue:clientId forKey:@"clientId"];
        NSString *adid = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        [param setValue:adid forKey:@"idfa"];
        //[self showHudInView:self.view hint:@"中"];
        [NetManager requestWithUrlString:url andDic:param finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //[self hideHud];
            NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
            if ([result[@"resultCode"] boolValue]) {
                [self showHint:result[@"resultMsg"] yOffset:0];
            }else { //成功
                
                [self showHint:@"注册成功" yOffset:0];
                NSDictionary *dic = @{@"userName":self.telephone.text, @"password":self.loginpassword.text};
                [FuncPublic SaveDefaultInfo:dic Key:mSaveAccount];
                [FuncPublic SaveDefaultInfo:@"1" Key:userIsLogin];
                [param removeAllObjects];
                NSDictionary *userInfo = result[@"resultData"];
                [param setValue:userInfo[@"userId"] forKey:@"userId"];
                [param setValue:userInfo[@"phone"] forKey:@"telephone"];
                [param setValue:userInfo[@"userName"] forKey:@"userName"];
                [param setValue:userInfo[@"token"] forKey:@"token"];
                [param setValue:@"0" forKey:@"hasCardId"];
                [param setValue:@"0" forKey:@"hasTradePassword"];
                [FuncPublic SaveDefaultInfo:param Key:mUserInfo];
                if ([_isChildViewcontroller boolValue]) {
                   // [FuncPublic SaveDefaultInfo:@"0" Key:mSMRZ];//为了在
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                       [[NSNotificationCenter defaultCenter]postNotificationName:@"fromRegister" object:@{@"smrz":@"0"}];
                        
                    }];
                    
                   
                    
                    NavigationController *nav =   (NavigationController *) [UIApplication sharedApplication].keyWindow.rootViewController;
                   // NSArray *array = nav.viewControllers;
                    MyTabbarController *tab =  nav.viewControllers[0];
                    tab.selectedIndex = 3;
                    
                    NavigationController *nav1 = (NavigationController *) self.navigationController;
                    
                    [nav1 dismissViewControllerAnimated:true completion:nil];
                   
                }else if (_isCPXQ == 1) {
                    // [FuncPublic SaveDefaultInfo:@"0" Key:mSMRZ];//为了在
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [[NSNotificationCenter defaultCenter]postNotificationName:@"fromRegister" object:@{@"smrz":@"0"}];
                        
                    }];
                    
                    NavigationController *nav =   (NavigationController *) [UIApplication sharedApplication].keyWindow.rootViewController;
                    NSArray *array = nav.viewControllers;
                    MyTabbarController *tab =  nav.viewControllers[0];
                    tab.selectedIndex = 3;
                    [tab.navigationController popToRootViewControllerAnimated:true];
                    CPXQViewController *cpxq = array[1];
                    [cpxq removeFromParentViewController];
                    NavigationController *nav1 = (NavigationController *) self.navigationController;
                    
                    [nav1 dismissViewControllerAnimated:true completion:nil];
                    
                }else if(_isLoginRegister){
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [[NSNotificationCenter defaultCenter]postNotificationName:@"fromRegister" object:@{@"smrz":@"0"}];
                        
                    }];
                    NavigationController *nav =   (NavigationController *) [UIApplication sharedApplication].keyWindow.rootViewController;
                    // NSArray *array = nav.viewControllers;
                    MyTabbarController *tab =  nav.viewControllers[0];
                    tab.selectedIndex = 3;
                    
                    NavigationController *nav1 = (NavigationController *) self.navigationController;
                    
                    [nav1 dismissViewControllerAnimated:true completion:nil];
                  //  [self.navigationController popViewControllerAnimated:false];
                   // UIStoryboard *s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
//                    LoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
//                    loginVC.isChildViewController = false;
//                    loginVC.isLoginRegister = true;
//                    loginVC.telephone = _telephone.text;
//                  //  loginVC.loginregister = self;
//                    [self.navigationController pushViewController:loginVC animated:true];
                }else {
                  //  [[NSNotificationCenter defaultCenter]postNotificationName:@"fromRegister" object:@{@"smrz":@"0"}];
                    ForgetPasswordViewController *forget = self.forget;
                    [forget.navigationController popViewControllerAnimated:true];
                    [self dismissViewControllerAnimated:true completion:^{
                        
                    }];

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
            //[self hideHud];
        }];
        
    //}
}


- (IBAction)ruleTouched:(id)sender {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"HTML" bundle:nil];
    htmlViewController *html = [s instantiateViewControllerWithIdentifier:@"htmlViewController"];
    html.name = @"注册协议";
    [self.navigationController pushViewController:html animated:true];

//    RuleRegisterViewController *rule = [self.storyboard instantiateViewControllerWithIdentifier:@"RuleRegisterViewController"];
//    [self.navigationController pushViewController:rule animated:true];
}
- (IBAction)hidekeyboard:(id)sender {
    [_telephone resignFirstResponder];
    [_code resignFirstResponder];
    [_loginpassword resignFirstResponder];
    [_jypassword resignFirstResponder];
    [_recommendPhone resignFirstResponder];
}
- (IBAction)hqyzmTouched:(id)sender {
    [self hidekeyboard:nil];
    if(_telephone.text.length == 0) {
        [self showHint:@"手机号码不能为空！" yOffset:0];
        return;
    }else {
        NSString *url =[NSString stringWithFormat:@"%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"sms/register"];
        NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
        // [param setValue:@"6381" forKey:@"code"];
        [param setValue:@"iOS" forKey:@"from"];
        [param setValue:_telephone.text forKey:@"phone"];
        //  [param setValue:_code.text forKey:@"code"];
        [param setValue:InnerVersion forKey:@"version"];
        
        //[self showHudInView:self.view hint:@"中"];
        [NetManager requestWithUrlString:url andDic:param finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //[self hideHud];
            NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
            if ([result[@"resultCode"] boolValue]) {
                [self showHint:result[@"resultMsg"] yOffset:0];
            }else {
                [self openCountdown];//开启倒计时
                [self showHint:result[@"resultMsg"] yOffset:0];
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
            //[self hideHud];
        }];
        
        
    }
}
// 开启倒计时效果
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
                [self.yzmLabel setText:@"重新发送" ];
                //[self.yzmLabel setTitleColor:[UIColor whiteColor] ];
                self.yzmLabel.userInteractionEnabled = YES;
            });
            
        }else{
            
            int seconds = time % 60;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //设置按钮显示读秒效果
                [self.yzmLabel setText:[NSString stringWithFormat:@"%.2ds", seconds]];
                //[self.codeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                self.yzmLabel.userInteractionEnabled = NO;
            });
            time--;
        }
    });
    dispatch_resume(_timer);
}
- (IBAction)closeClicked:(id)sender {
    
}

- (IBAction)ljqgBtn:(id)sender {
}
#pragma mark-uitextfield delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    //假如多个输入，比如注册和登录，就可以根据不同的输入框来上移不同的位置，从而更加人性化
    //键盘高度216
    //滑动效果（动画）
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@ "ResizeForKeyboard"  context:nil];
    [UIView setAnimationDuration:animationDuration];
    if (textField.tag == 2) {
        //将视图的Y坐标向上移动，以使下面腾出地方用于软键盘的显示
        self.view.frame = CGRectMake(0.0f, -180.0f/*屏幕上移的高度，可以自己定*/, self.view.frame.size.width, self.view.frame.size.height);
    }else if (textField.tag == 0) {
        //将视图的Y坐标向上移动，以使下面腾出地方用于软键盘的显示
        self.view.frame = CGRectMake(0.0f, -100.0f/*屏幕上移的高度，可以自己定*/, self.view.frame.size.width, self.view.frame.size.height);
    }else if(textField.tag == 1){
        //将视图的Y坐标向上移动，以使下面腾出地方用于软键盘的显示,/*屏幕上移的高度，可以自己定*/
        self.view.frame = CGRectMake(0.0f, -140.0f, self.view.frame.size.width, self.view.frame.size.height);
    }else if(textField.tag == 3){
        //将视图的Y坐标向上移动，以使下面腾出地方用于软键盘的显示,/*屏幕上移的高度，可以自己定*/
        self.view.frame = CGRectMake(0.0f, -220.0f, self.view.frame.size.width, self.view.frame.size.height);
    }
    
    [UIView commitAnimations];
}
//取消第一响应，也就是输入完毕，屏幕恢复原状
-( void )textFieldDidEndEditing:(UITextField *)textField
{
    //滑动效果
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@ "ResizeForKeyboard"  context:nil];
    [UIView setAnimationDuration:animationDuration];
    //恢复屏幕
    self.view.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}
@end
