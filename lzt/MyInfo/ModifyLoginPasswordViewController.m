//
//  ModifyLoginPasswordViewController.m
//  lzt
//
//  Created by hwq on 2017/11/17.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "ModifyLoginPasswordViewController.h"
#import "UIButton+CornerRadium.h"
#import "NetManager.h"
#import "LoginViewController.h"
#import "NavigationController.h"
@interface ModifyLoginPasswordViewController ()
@property (weak, nonatomic) IBOutlet UIButton *qdxgBtn;
@property (weak, nonatomic) IBOutlet UITextField *oldPassword;
@property (weak, nonatomic) IBOutlet UITextField *newpassword;
@property (weak, nonatomic) IBOutlet UITextField *againNewPasswordAgain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavHeight;

@end

@implementation ModifyLoginPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (iPhoneX) {
        _NavHeight.constant += 20;
    }
    [self setTitle:@"修改登陆密码"];
    [self hideBackButtonText];
    [_qdxgBtn setCornerRadium];
}
- (IBAction)hidekeyboard:(id)sender {
    [_qdxgBtn resignFirstResponder];
    [_newpassword resignFirstResponder];
    [_againNewPasswordAgain resignFirstResponder];
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)okBtnClicked:(id)sender {
    [self hidekeyboard:nil];
    
    if(_oldPassword.text.length == 0) {
        [self showHint:@"原密码不能为空！" yOffset:-Screen_Height /4];
        return;
    }
    if(_newpassword.text.length == 0){
        [self showHint:@"新密码不能为空！" yOffset:-Screen_Height /4];
        return;
    }
    if([FuncPublic isRightLoginPassword:_newpassword.text]){
        if (_newpassword.text.length < 6) {
            [self showHint:@"新密码长度大于6位" yOffset:-Screen_Height /4];
            return;
        }
        if (_newpassword.text.length > 16) {
            [self showHint:@"新密码长度小于16位" yOffset:-Screen_Height /4];
            return;
        }
    }else{
        [self showHint:@"新密码只能为6～16位字母和数字组合" yOffset:-Screen_Height /4];
        return;
    }
    if(_againNewPasswordAgain.text.length == 0){
        [self showHint:@"确认新密码不能为空！" yOffset:-Screen_Height /4];
        return;
    }
    if([FuncPublic isRightLoginPassword:_againNewPasswordAgain.text]){
        if (_againNewPasswordAgain.text.length < 6) {
            [self showHint:@"确认新密码长度大于6位" yOffset:-Screen_Height /4];
            return;
        }
        if (_againNewPasswordAgain.text.length > 16) {
            [self showHint:@"确认新密码长度小于16位" yOffset:-Screen_Height /4];
            return;
        }
    }else{
        [self showHint:@"确认新密码只能为6～16位字母和数字组合" yOffset:-Screen_Height /4];
        return;
    }
    if(![_againNewPasswordAgain.text isEqualToString:_newpassword.text]){
        [self showHint:@"两次输入的密码不一致！" yOffset:-Screen_Height /4];
        return;
    }
    NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
    NSString *url =[NSString stringWithFormat:@"%@%@/%@/%@", [FuncPublic SharedFuncPublic].rootserver , @"user",userInfo[@"userId"], @"updatePassword"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    // [param setValue:@"6381" forKey:@"code"];
    [param setValue:@"iOS" forKey:@"from"];
    [param setValue:userInfo[@"token"] forKey:@"token"];
    [param setValue:_newpassword.text forKey:@"passwordNew"];
    [param setValue:_oldPassword.text forKey:@"password"];
    [param setValue:InnerVersion forKey:@"version"];
    [self showHudInView:self.view hint:@"修改密码中"];
    [NetManager requestWithUrlString:url andDic:param finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self hideHud];
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        if ([result[@"resultCode"] boolValue]) {
            [self showHint:result[@"resultMsg"] yOffset:0];
        }else {
            [self showHint:result[@"resultMsg"] yOffset:0];
            NSDictionary *dic = @{@"userName":userInfo[@"userName"], @"password":_newpassword.text};
            [FuncPublic SaveDefaultInfo:dic Key:mSaveAccount];
            
            //                UIStoryboard *s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
            //                LoginViewController *loginVC = [s instantiateViewControllerWithIdentifier:@"LoginViewController"];
            //                NavigationController *nav = [[NavigationController alloc]initWithRootViewController:loginVC];
            //                [self presentViewController:nav animated:true completion:nil];
            
            [self.navigationController popViewControllerAnimated:true];
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
    
    
    // }
    
}
@end
