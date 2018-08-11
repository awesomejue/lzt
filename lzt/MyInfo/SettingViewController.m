//
//  SettingViewController.m
//  lzt
//
//  Created by hwq on 2017/11/15.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "SettingViewController.h"
#import "SMRZViewController.h"
#import "MMGLViewController.h"
#import "CacheUtil.h"
#import "AboutViewController.h"
#import "MyTabbarController.h"
#import "LoginViewController.h"
#import "YHKGLViewController.h"
#import "NavigationController.h"

//推送
#import <GTSDK/GeTuiSdk.h>     // GetuiSdk头文件应用

@interface SettingViewController ()
@property (weak, nonatomic) IBOutlet UILabel *yhkglLabel;
@property (weak, nonatomic) IBOutlet UILabel *telephone;
@property (weak, nonatomic) IBOutlet UILabel *cacheSize;
@property (weak, nonatomic) IBOutlet UILabel *modifyPassword;
@property (weak, nonatomic) IBOutlet UIImageView *smrzRightImage;
@property (weak, nonatomic) IBOutlet UILabel *smrzRightLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavHeight;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    [self setTitle:@"设置"];
    if (iPhoneX) {
        _NavHeight.constant += 20;
    }
    [self hideBackButtonText];
    //[self apearNav];
   // [self createUI];
}

//显示导航栏
- (void) apearNav{
     [self.navigationController setNavigationBarHidden:NO animated:YES];
   // self.navigationController.navigationBar.hidden = false;
}
- (void)hideBackButtonText{
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:nil];
}
- (void)createUI {
    _cacheSize.text = [NSString stringWithFormat:@"%.2fMB", [CacheUtil folderSizeAtPath]];
    
    if ([[FuncPublic GetDefaultInfo:userIsLogin] boolValue]) {
        NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
        _telephone.text = [FuncPublic getTelephone:userInfo[@"telephone"]];
    }else {
        _telephone.text = @"未绑定";
    }
    //    //判断是否实名,调用的是获取绑定银行卡的接口
    //    NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
    //    NSString *url =[NSString stringWithFormat:@"%@%@%@%@?token=%@&from=%@&version=%@", ROOTSERVER ,@"user/",userInfo[@"userId"],@"/account/cards", userInfo[@"token"], @"iOS", InnerVersion];
    //   // [self showHudInView:self.view hint:@"载入中"];
    //    [NetManager GetRequestWithUrlString:url finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    //        [self hideHud];
    //        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
    //        NSDictionary *dic = result[@"resultData"];
    NSDictionary *user = [FuncPublic GetDefaultInfo:mUserInfo];
    if (![user[@"hasCardId"] boolValue]) {
        self.smrzRightImage.image = [UIImage imageNamed:@"close.png"];
        self.smrzRightLabel.text = @"未认证";
        self.smrzRightLabel.textColor = [UIColor redColor];
        
        self.yhkglLabel.text = @"未绑定";
    }else {
        self.smrzRightImage.image = [UIImage imageNamed:@"打钩.png"];
        self.smrzRightLabel.text = @"已认证";
        self.yhkglLabel.text = @"已绑定";
        self.smrzRightLabel.textColor = [UIColor colorWithRed:32/255.0 green:204/255.0 blue:133/255.0 alpha:1];
        //self.smrzRightLabel.textColor = [UIColor redColor];
    }
    
    //    } failed:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    //        NSLog(@"%@", error);
    //        [self hideHud];
    //    }];
}
- (IBAction)yhkglTouched:(id)sender {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"SMRZ" bundle:nil];
    SMRZViewController *smrz = [s instantiateViewControllerWithIdentifier:@"SMRZViewController"];
    [self.navigationController pushViewController:smrz animated:true];
}

- (IBAction)bbxxTouched:(id)sender {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"Foundation" bundle:nil];
    AboutViewController *about = [s instantiateViewControllerWithIdentifier:@"AboutViewController"];
    [self.navigationController pushViewController:about animated:true];
}

- (IBAction)quit:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"您确定要退出登陆吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showHudInView:self.view hint:@""];
        NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
        NSString *url = [NSString stringWithFormat:@"%@user/logout/%@",[FuncPublic SharedFuncPublic].rootserver, userInfo[@"userId"]];
        NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
        [param setValue:userInfo[@"token"] forKey:@"token"];
        NSString *clientId = [GeTuiSdk clientId];
        [param setValue:clientId forKey:@"clientId"];
        [NetManager requestWithUrlString:url andDic:param finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self hideHud];
            NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
            if ([result[@"resultCode"] intValue] != 0) {
                
            }else {
                //解绑。
                // NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
                [GeTuiSdk unbindAlias:userInfo[@"userId"] andSequenceNum:@"seq-2" andIsSelf:true];
                
                [FuncPublic SaveDefaultInfo:@"" Key:userIsLogin];
                [FuncPublic SaveDefaultInfo:@"" Key:mSaveAccount];
                [FuncPublic SaveDefaultInfo:@"" Key:mUserInfo];
                // UIStoryboard * s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
                //        LoginViewController *login = [s instantiateViewControllerWithIdentifier:@"LoginViewController"];
                //        login.isChildViewController = false;
                //        login.isQuitLogin = true;
                //        NavigationController *nav = [[NavigationController alloc]initWithRootViewController:login];
                //        [self presentViewController:nav animated:false completion:nil];
                NavigationController *nav =   (NavigationController *) [UIApplication sharedApplication].keyWindow.rootViewController ;
                MyTabbarController *tab =  nav.viewControllers[0];
                tab.selectedIndex = 0;
                
                //[self dismissViewControllerAnimated:true completion:nil];
                [self.navigationController popViewControllerAnimated:true];
                [self showHint:result[@"resultMsg"] yOffset:0];
            }
        } failed:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self showHint:@"退出登陆失败!" yOffset:0];
            [self hideHud];
        }];
        
        
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:cancel];
    [alert addAction:ok];
    [self presentViewController:alert animated:true completion:nil];
    
}
- (IBAction)cacheClearTouched:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"您确定要清理缓存？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //[CacheUtil clearCache];
        [CacheUtil cleanCache:^{
            _cacheSize.text = @"0.00MB";
        }];
        // = [NSString stringWithFormat:@"%.2fMB", [CacheUtil folderSizeAtPath]];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:cancel];
    [alert addAction:ok];
    [self presentViewController:alert animated:true completion:nil];
}
- (IBAction)smrzTouched:(id)sender {
    if ([self.smrzRightLabel.text isEqualToString:@"已认证"]) {
        [self showHint:@"您已实名认证" yOffset:0];
    }else {
        UIStoryboard *s = [UIStoryboard storyboardWithName:@"SMRZ" bundle:nil];
        SMRZViewController *smrz = [s instantiateViewControllerWithIdentifier:@"SMRZViewController"];
        [self.navigationController pushViewController:smrz animated:true];
    }
    
}
- (IBAction)myyhkglTouched:(id)sender {
    if ([self.smrzRightLabel.text isEqualToString:@"未认证"]) {
        [self showHint:@"需要先实名认证" yOffset:0];
        UIStoryboard *s = [UIStoryboard storyboardWithName:@"SMRZ" bundle:nil];
        SMRZViewController *smrz = [s instantiateViewControllerWithIdentifier:@"SMRZViewController"];
        [self.navigationController pushViewController:smrz animated:true];
    }else {
        YHKGLViewController * yhkgl = [self.storyboard instantiateViewControllerWithIdentifier:@"YHKGLViewController"];
        [self.navigationController pushViewController:yhkgl animated:true];
    }
   
}

- (IBAction)mmglTouched:(id)sender {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"MMGL" bundle:nil];
    MMGLViewController *mmgl = [s instantiateViewControllerWithIdentifier:@"MMGLViewController"];
    [self.navigationController pushViewController:mmgl animated:true];
}
- (void)viewWillAppear:(BOOL)animated {
    [self createUI];
    //[self.navigationController setNavigationBarHidden:NO animated:YES];
   // [[NSNotificationCenter defaultCenter] postNotificationName:@"tabBarHidden" object:nil];
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (void)viewWillDisappear:(BOOL)animated {
   // [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)chooseLocal:(id)sender {
    
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
