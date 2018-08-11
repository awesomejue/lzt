//
//  LoginRegisterViewController.m
//  lzt
//
//  Created by hwq on 2017/12/8.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "LoginRegisterViewController.h"
#import "NavigationController.h"
#import "MyTabbarController.h"
#import "RegisterViewController.h"
#import "LoginViewController.h"

@interface LoginRegisterViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *telephone;
@property (weak, nonatomic) IBOutlet UIButton *btn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavHeight;
@end

@implementation LoginRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (iPhoneX) {
        _NavHeight.constant += 20;
    }
    self.navigationController.navigationBar.hidden = true;
    [self createUI];
    
}
- (void)createUI {
    _btn.layer.cornerRadius = 5;
    _telephone.delegate = self;
    [_telephone addTarget:self action:@selector(OK:) forControlEvents:UIControlEventEditingChanged];
     [_telephone addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}
- (void)textFieldDidChange:(id)sender {
    
    if ([FuncPublic deptNumInputShouldNumber:self.telephone.text]) {
        [self showHint:@"手机号码有误" yOffset:-Screen_Height / 3];
    }
    if([self.telephone.text length] > 11){
        [self showHint:@"手机号码有误" yOffset:-Screen_Height / 3];
    }
    if ([self.telephone.text length] < 11) {
        [self.btn setBackgroundColor:[UIColor lightGrayColor]];
    }
}
- (void)OK:(id)sender {
    if ([FuncPublic isOnlyhasNumberAndpointWithString:_telephone.text] ) {
        if ( [_telephone.text length] == 11) {
            [_btn setBackgroundColor:[UIColor redColor]];
            [_btn setEnabled:true];
        }
    }
}
- (IBAction)hidekeyboard:(id)sender {
    [self.telephone resignFirstResponder];
}

- (IBAction)close:(id)sender {
    [self hidekeyboard:nil];
    if (_isCPXQ) {
//        NavigationController *nav =   (NavigationController *) [UIApplication sharedApplication].keyWindow.rootViewController ;
//        MyTabbarController *tab =  nav.viewControllers[0];
//        tab.selectedIndex = 1;
        [self dismissViewControllerAnimated:true completion:nil];
    }else{
        
   
    NavigationController *nav =   (NavigationController *) [UIApplication sharedApplication].keyWindow.rootViewController ;
    MyTabbarController *tab =  nav.viewControllers[0];
    tab.selectedIndex = 0;
    [self dismissViewControllerAnimated:true completion:nil];
    }
}
- (IBAction)inputTouched:(id)sender {
    [_telephone becomeFirstResponder];
}

- (IBAction)nextBtnClicked:(id)sender {
    [self hidekeyboard:nil];
    if ([FuncPublic deptNumInputShouldNumber:self.telephone.text] && [self.telephone.text length] == 11) {
        [self showHint:@"手机号码有误" yOffset:0];
    }else {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dismissSelf) name:@"dismiss" object:nil];
        
        NSString *url =[NSString stringWithFormat:@"%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"user/check"];
        NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
        // [param setValue:@"6381" forKey:@"code"];
        [param setValue:@"iOS" forKey:@"from"];
        [param setValue:_telephone.text forKey:@"phone"];
        //  [param setValue:_code.text forKey:@"code"];
        [param setValue:InnerVersion forKey:@"version"];
        
        [self showHudInView:self.view hint:@"载入中"];
        [NetManager requestWithUrlString:url andDic:param finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //[self hideHud];
            NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
            if ([result[@"resultCode"] boolValue]) {
                [self showHint:result[@"resultMsg"] yOffset:0];
            }else {
                bool resigter = [result[@"resultData"][@"registered"] boolValue];
                if (resigter) {//已注册
                    
                    UIStoryboard *s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
                    LoginViewController *loginVC = [s instantiateViewControllerWithIdentifier:@"LoginViewController"];
                    loginVC.isChildViewController = false;
                    loginVC.isLoginRegister = true;
                    loginVC.telephone = _telephone.text;
                    loginVC.loginregister = self;
                    if (self.isCPXQ == 1) {
                        loginVC.isCPXQ = 1;
                    }
                    // NavigationController *nav = [[NavigationController alloc]initWithRootViewController:loginVC];
                    //                [self presentViewController:nav animated:false completion:^{
                    //
                    //                }];
                    [self.navigationController pushViewController:loginVC animated:true];
                    // [self dismissViewControllerAnimated:false completion:nil];
                }else {//未注册
                    RegisterViewController *reg = [self.storyboard instantiateViewControllerWithIdentifier:@"RegisterViewController"];
                    //reg.isChildViewcontroller = @"1"; //push
                    reg.isLoginRegister = true;
                    reg.phone = _telephone.text;
                    if (self.isCPXQ == 1) {
                        reg.isCPXQ = 1;
                    }
                    [self.navigationController pushViewController:reg animated:true];
                }
                //[self showHint:result[@"resultMsg"] yOffset:0];
            }
            [self hideHud];
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
    }
    
}
- (void)dismissSelf{
    [self dismissViewControllerAnimated:true completion:nil];
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
