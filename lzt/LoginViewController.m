//
//  LoginViewController.m
//  lzt
//
//  Created by hwq on 2017/11/15.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "ForgetPasswordViewController.h"
#import "MyInfoViewController.h"
#import "NetManager.h"
#import "MyTabbarController.h"
#import "AppDelegate.h"
#import "NavigationController.h"
#import "HomePageViewController.h"

#define FONT  [UIFont fontWithName:@"PingFang SC" size:16]
@interface LoginViewController () <UITextFieldDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dlTopLayoutconstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *usernameTopLayoutconstraint;
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;

@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (nonatomic, strong) MyInfoViewController *myInfo;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (iPhoneX) {
        _dlTopLayoutconstraint.constant += 20;
    }
//    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(22, 400, 120, 222)];
//    view.backgroundColor = [UIColor redColor];
//    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
//    window.windowLevel = UIWindowLevelNormal;
//    
//    [window addSubview:view];
    [self setTitle:@"登陆"];
    [self createUI];
    [self hideBackButtonText];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [self hideNavigationBar];
    [super viewWillAppear:animated];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"tabBarHidden" object:nil];
}

- (void)hideNavigationBar {
    // [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    self.navigationController.navigationBar.hidden = YES;
}
- (void)createUI {
    self.loginBtn.layer.cornerRadius = 5;
    self.username.delegate = self;
    self.password.delegate = self;
    [self.password setSecureTextEntry:true];
    _username.font = FONT;
    _password.font = FONT;
    if (_isLoginRegister) {
        self.username.text = _telephone;
        self.registerBtn.hidden = YES;
    }
}
- (void)hideBackButtonText{
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:nil];
}
- (IBAction)registerClicked:(id)sender {
   // UIStoryboard *s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    RegisterViewController *reg = [self.storyboard instantiateViewControllerWithIdentifier:@"RegisterViewController"];
    reg.isChildViewcontroller = @"1"; //push
    [self.navigationController pushViewController:reg animated:true];
}

- (IBAction)forgetPasswordClicked:(id)sender {
    [self hidekeyboard:nil];
    ForgetPasswordViewController *forget = [self.storyboard instantiateViewControllerWithIdentifier:@"ForgetPasswordViewController"];
    [self.navigationController pushViewController:forget animated:true];
}
- (IBAction)loginClicked:(id)sender {
    
    [self hidekeyboard:sender];
    if(_username.text.length == 0) {
        [self showHint:@"手机号码不能为空！" yOffset:0];
        return;
    }
    if(_password.text.length == 0){
        [self showHint:@"密码不能为空！" yOffset:0];
        return;
    }
    if([FuncPublic isRightLoginPassword:_password.text]){
        if (_password.text.length < 6) {
            [self showHint:@"密码长度大于6位" yOffset:0];
            return;
        }
        if (_password.text.length > 16) {
            [self showHint:@"密码长度小于16位" yOffset:0];
            return;
        }
    }else{
        [self showHint:@"密码只能为6～16位字母和数字组合" yOffset:0];
        return;
    }
    
        NSString *userNameString = self.username.text;
        NSString *passwordString = self.password.text;
        NSLog(@"%@", self.username.text);
    NSLog(@"%@", self.password.text);
        NSString *url =[NSString stringWithFormat:@"%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"user/login"];
    
        NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
        // [param setValue:@"6381" forKey:@"code"];
        [param setValue:@"iOS" forKey:@"from"];
        [param setValue:userNameString forKey:@"name"];
        [param setValue:passwordString forKey:@"password"];
        [param setValue:InnerVersion forKey:@"version"];
        NSString *clientId = [GeTuiSdk clientId];
        [param setValue:clientId forKey:@"clientId"];
        [self showHudInView:self.view hint:@"登陆中"];
        [NetManager requestWithUrlString:url andDic:param finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self hideHud];
            NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
            if ([result[@"resultCode"] boolValue]) {
                [self showHint:result[@"resultMsg"] yOffset:0];
            }else {
                
                NSDictionary *dic = @{@"userName":userNameString, @"password":passwordString};
                [FuncPublic SaveDefaultInfo:dic Key:mSaveAccount];
                [FuncPublic SaveDefaultInfo:@"1" Key:userIsLogin];
                [param removeAllObjects];
                NSDictionary *userInfo = result[@"resultData"][@"userInfo"];
                [param setValue:userInfo[@"userId"] forKey:@"userId"];
                [param setValue:userInfo[@"phone"] forKey:@"telephone"];
                userInfo = result[@"resultData"][@"user"];
                [param setValue:userInfo[@"name"] forKey:@"userName"];
                userInfo = result[@"resultData"][@"userAuth"];
                [param setValue:userInfo[@"token"] forKey:@"token"];
                [param setValue:result[@"resultData"][@"hasCardId"] forKey:@"hasCardId"];
                [param setValue:result[@"resultData"][@"hasTradePassword"] forKey:@"hasTradePassword"];
                [FuncPublic SaveDefaultInfo:param Key:mUserInfo];
                /*调试状态设为0，以后正式改为1**/
                [FuncPublic SaveDefaultInfo:@"1" Key:userIsLogin];//保存用户登陆状态
                if (_isLoginRegister) { //是注册登录页present
                    if (_isCPXQ) {
                        [self.navigationController dismissViewControllerAnimated:true completion:nil];
                    }else {
                    //ReadBookController要跳转的界面
                    NavigationController *nav =   (NavigationController *) [UIApplication sharedApplication].keyWindow.rootViewController ;
                    MyTabbarController *tab =  nav.viewControllers[0];
                    tab.selectedIndex = 3;
                    [self.navigationController dismissViewControllerAnimated:true completion:^{
                       
                    }];
                    }
                   
//                    [nav1 dismissViewControllerAnimated:true completion:^{
//                         [vc dismissViewControllerAnimated:false completion:nil];
//                        //[[NSNotificationCenter defaultCenter]postNotificationName:@"dismiss" object:nil];
//                        // [(LoginRegisterViewController *)nav1.presentedViewController dismissViewControllerAnimated:false completion:nil];
//                        NavigationController *nav =   (NavigationController *) [UIApplication sharedApplication].keyWindow.rootViewController ;
//                        MyTabbarController *tab =  nav.viewControllers[0];
//                        tab.selectedIndex = 3;
//                    }];
                    
                }else {
                    [self dismissViewControllerAnimated:true completion:nil];
                }
                
                //绑定别名
                [GeTuiSdk bindAlias:userInfo[@"userId"] andSequenceNum:@"seq-1"];
                
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
- (IBAction)closedClicked:(id)sender {
    if (_isChildViewController) {
        [self.navigationController popViewControllerAnimated:false];
        // [[NSNotificationCenter defaultCenter] postNotificationName:@"homePageAction" object:nil];
    }else if (_isLoginRegister) { //是注册登录页present
        if (_isCPXQ) {
            [self.navigationController dismissViewControllerAnimated:true completion:nil];
        }else {
            NavigationController *nav =   (NavigationController *) [UIApplication sharedApplication].keyWindow.rootViewController ;
            MyTabbarController *tab =  nav.viewControllers[0];
            tab.selectedIndex = 0;
            [self.navigationController dismissViewControllerAnimated:true completion:nil];
        }
        
        //        [self.loginregister dismissViewControllerAnimated:false completion:^{
        //             [[NSNotificationCenter defaultCenter] postNotificationName:@"dismiss" object:nil];
        //            NavigationController *nav =   (NavigationController *) [UIApplication sharedApplication].keyWindow.rootViewController ;
        //            MyTabbarController *tab =  nav.viewControllers[0];
        //            tab.selectedIndex = 0;
        //            NavigationController *nav1 = (NavigationController *)self.navigationController;
        //            [nav1 dismissViewControllerAnimated:true completion:nil];
        //        }];
        
        
    }else {
        // NavigationController *nav =   (NavigationController *) [UIApplication sharedApplication].keyWindow.rootViewController ;
        // MyTabbarController *tab =  nav.viewControllers[0];
        // tab.selectedIndex = 0;
        [self dismissViewControllerAnimated:true completion:nil];
    }
    
}

- (IBAction)hidekeyboard:(id)sender {
    [_username resignFirstResponder];
    [_password resignFirstResponder];
   // _usernameTopLayoutconstraint.constant += 30;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-uitextfield delegate 实现上移视图，防止键盘遮挡。
- (void)textFieldDidBeginEditing:(UITextField *)textField{
     //假如多个输入，比如注册和登录，就可以根据不同的输入框来上移不同的位置，从而更加人性化
    //键盘高度216
    //滑动效果（动画）
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@ "ResizeForKeyboard"  context:nil];
    [UIView setAnimationDuration:animationDuration];
    //将视图的Y坐标向上移动，以使下面腾出地方用于软键盘的显示
    self.view.frame = CGRectMake(0.0f, -80.0f/*屏幕上移的高度，可以自己定*/, self.view.frame.size.width, self.view.frame.size.height);
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

#pragma mark - UINavigationControllerDelegate
// 将要显示控制器
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 判断要显示的控制器是否是自己
    BOOL isShowHomePage = [viewController isKindOfClass:[self class]];
    
    [self.navigationController setNavigationBarHidden:isShowHomePage animated:YES];
}
@end
