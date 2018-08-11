//
//  MyInfoViewController.m
//  lzt
//  Created by hwq on 2017/10/23.
//  Copyright © 2017年 hwq. All rights reserved.
//
#import "MyInfoViewController.h"
#import "CZViewController.h"
#import "SZJYMMViewController.h"
#import "TXViewController.h"
#import "ZJMXViewController.h"
#import "NavigationController.h"
#import "LoginViewController.h"
#import "SettingViewController.h"
#import "CalculaterView.h"
#import "SMRZViewController.h"
#import "HBViewController.h"
#import "MyTabbarController.h"
#import "JXQScrollView.h"
#import "TJYLViewController.h"
#import "htmlViewController.h"
#import "WDTZJLViewController.h"
#import "HKJHViewController.h"
@interface MyInfoViewController ()<UITabBarControllerDelegate, UINavigationControllerDelegate,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wdzcTopLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headVIewLayoutConstraint;
@property (weak, nonatomic) IBOutlet UILabel *account;
@property (weak, nonatomic) IBOutlet UILabel *availableMoney;
@property (weak, nonatomic) IBOutlet UILabel *totalMoney;
@property (weak, nonatomic) IBOutlet UILabel *freezMoney;
@property (weak, nonatomic) IBOutlet UILabel *hkjhTip;
@property (weak, nonatomic) IBOutlet UILabel *hbTip;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavTopHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollviewTopLayout;


@property (weak, nonatomic) IBOutlet UILabel *jxqTip;
@property (assign, nonatomic) long avMoney; //保存可用余额，为提现界面使用
@property (assign, nonatomic) BOOL hasCardId; // 是否实名
@property (assign, nonatomic) BOOL hastradPassword; //是否设置交易密码

@property (assign, nonatomic) BOOL isCanSideBack;
@end

@implementation MyInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (iPhoneX) {
        _NavTopHeight.constant+= 20;
        //_scrollviewTopLayout.constant -= 20;
    }
    self.navigationController.delegate = self;
    [self showHudInView:self.view hint:@"载入中"];
   
    [self hideHud];
   // [self addRightButtonItem:@""];
    [self isIphoneX];
    [self hideBackButtonText];
    [self createUI];
    [self tableHeaderDidTriggerRefresh];
    //[self Tip];//弹出实名提示
}


- (void)createUI {
    self.navigationController.delegate = self;
}
- (void)isIphoneX {
    if (iPhoneX) {
        _wdzcTopLayoutConstraint.constant += 20;
    }
    if (iPhone5) {
        _headVIewLayoutConstraint.constant -= 20;
    }
}
- (IBAction)settingClicked:(id)sender {
    SettingViewController *set = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingViewController"];
    [self.navigationController pushViewController:set animated:true];
}
- (void)set {
    SettingViewController *set = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingViewController"];
    [self.navigationController pushViewController:set animated:true];
}
- (void)viewWillDisappear:(BOOL)animated {
   //  [self.navigationController setNavigationBarHidden:NO animated:YES];
    //self.navigationController.navigationBarHidden = NO;
}
//下拉刷新
- (void)tableHeaderDidTriggerRefresh {
    self.automaticallyAdjustsScrollViewInsets = true;
    
#ifdef __IPHONE_11_0
    if ([self.scrollview respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
        if (@available(iOS 11.0, *)) {
            self.scrollview.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
        }
    }else {
        self.automaticallyAdjustsScrollViewInsets = false;
    }
#endif
    self.scrollview.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
        if (![userInfo isEqual:@""]) {
            self.account.text = [NSString stringWithFormat:@"账户：%@", [FuncPublic getTelephone:userInfo[@"telephone"]]];
        }
        if ([[FuncPublic GetDefaultInfo:userIsLogin] boolValue]) {
            //  [self showHudInView:self.view hint:@"载入中"];
            [self loadData];
            [self hideHud];
        }else {
            
        }
        [self.scrollview.mj_header endRefreshing];
    }];
}
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

     [self.navigationController setNavigationBarHidden:YES animated:NO];
    NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
    if (![userInfo isEqual:@""]) {
        self.account.text = [NSString stringWithFormat:@"账户：%@", [FuncPublic getTelephone:userInfo[@"telephone"]]];
    }
    
    if ([[FuncPublic GetDefaultInfo:userIsLogin] boolValue]) {
        [self loadData];
         [self loadUserInfo];
    }else {
        
    }
    
    //注册通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(Tip:) name:@"fromRegister" object:nil];
}


- (void) Tip:(NSNotification *)notification{
    //NSDictionary * infoDic = [notification object];
        // 这样就得到了我们在发送通知时候传入的字典了
   // if (![infoDic[@"smrz"] boolValue]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请前往实名认证" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIStoryboard *s = [UIStoryboard storyboardWithName:@"SMRZ" bundle:nil];
            SMRZViewController *smrz = [s instantiateViewControllerWithIdentifier:@"SMRZViewController"];
            smrz.isRegister = true;
            [self.navigationController pushViewController:smrz animated:true];
        }];
        
        [ok setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"先逛逛" style:UIAlertActionStyleDefault handler:nil];
        [cancel setValue:[UIColor lightGrayColor] forKey:@"_titleTextColor"];
        [alert addAction:cancel];
        [alert addAction:ok];
        [self presentViewController:alert animated:true completion:nil];
   // }
}
- (void) loadData {
    //[self showHudInView:self.view hint:@"载入中"];
    NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
    NSString *url =[NSString stringWithFormat:@"%@%@%@%@?token=%@&from=%@&version=%@", [FuncPublic SharedFuncPublic].rootserver ,@"user/",userInfo[@"userId"],@"/accountInfo", userInfo[@"token"], @"iOS", InnerVersion];
    
    [NetManager GetRequestWithUrlString:url finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
       
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        int b = [result[@"resultCode"] intValue];
        if (b == 1) {
            [self showHint:result[@"resultMsg"] yOffset:0];
        }else if(b == 2){//token失效
             [self showHint:result[@"resultMsg"] yOffset:0];
            [FuncPublic SaveDefaultInfo:@"0" Key:userIsLogin];
            [FuncPublic SaveDefaultInfo:@"" Key:mSaveAccount];
            [FuncPublic SaveDefaultInfo:@"" Key:mUserInfo];
            [self popToLogin];
        }else{
            _availableMoney.text =[NSString stringWithFormat:@"%.2f", [result[@"resultData"][@"money"] longValue] / 100.0];
            //保存可用余额
            _avMoney = [result[@"resultData"][@"money"] longValue];
            
            _totalMoney.text = [NSString stringWithFormat:@"%.2f", ([result[@"resultData"][@"money"] longValue] +[result[@"resultData"][@"freezingMoney"] longValue] + [result[@"resultData"][@"repaying"] doubleValue])/100.0];
            
            _freezMoney.text = [NSString stringWithFormat:@"%.2f", [result[@"resultData"][@"freezingMoney"] longValue] /100.0];
            
            int hkjhcount = [result[@"resultData"][@"waiting"] intValue];
            if (hkjhcount == 0) {
                _hkjhTip.text = @"暂无待收";
            }else {
                _hkjhTip.text = [NSString stringWithFormat:@"%d个回款计划", hkjhcount];
            }
             int hbcount = [result[@"resultData"][@"pocket"] intValue];
            if (hbcount == 0) {
                _hbTip.text = @"暂无可用";
            }else {
                _hbTip.text = [NSString stringWithFormat:@"%d个红包可用", hbcount];
            }
             int jxqcount = [result[@"resultData"][@"rates"] intValue];
            if (jxqcount == 0) {
                _jxqTip.text = @"暂无可用";
            }else {
                _jxqTip.text = [NSString stringWithFormat:@"%d个加息券可用", jxqcount];
            }
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
    [self hideHud];
}
- (void)loadUserInfo {
    //调用接口判断用户是否实名和设置交易密码
    NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
    NSString *url =[NSString stringWithFormat:@"%@%@%@%@?token=%@&from=%@&version=%@", [FuncPublic SharedFuncPublic].rootserver ,@"user/",userInfo[@"userId"],@"/userInfo", userInfo[@"token"], @"iOS", InnerVersion];
    
    // [self showHudInView:self.view hint:@"载入中"];
    [NetManager GetRequestWithUrlString:url finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self hideHud];
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        if ([result[@"resultCode"] boolValue]) {
            [self showHint:result[@"resultMsg"] yOffset:0];
        }else {
            NSDictionary *dic = result[@"resultData"];
            _hasCardId = [dic[@"hasCardId"] boolValue];
            _hastradPassword = [dic[@"hasTradePassword"] boolValue];
            NSMutableDictionary *user = [[NSMutableDictionary alloc]init];
            NSDictionary *u = [FuncPublic GetDefaultInfo:mUserInfo];
            [user setDictionary:u];
            [user setValue:[NSString stringWithFormat:@"%d", [dic[@"hasCardId"] intValue]] forKey:@"hasCardId"];
            [user setValue:[NSString stringWithFormat:@"%d", [dic[@"hasTradePassword"] intValue]]  forKey:@"hasTradePassword"];
            [FuncPublic SaveDefaultInfo:user Key:mUserInfo];
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
}
- (void) popToLogin{

    [FuncPublic SaveDefaultInfo:@"0" Key:userIsLogin];
    [FuncPublic SaveDefaultInfo:@"" Key:mSaveAccount];
    [FuncPublic SaveDefaultInfo:@"" Key:mUserInfo];
    
    [UIView transitionWithView:self.view duration:2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        //跳回首页
     //   NavigationController *nav =   (NavigationController *) [UIApplication sharedApplication].keyWindow.rootViewController ;
       // MyTabbarController *tab =  nav.viewControllers[0];
        self.tabBarController.selectedIndex = 0;
       // [self.navigationController popViewControllerAnimated:true];
    }completion:^(BOOL finished){
        NSLog(@"动画结束");
    }];
}
-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    [self forbiddenSideBack];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    
    [self resetSideBack];
    
}

/**
 * 禁用边缘返回
 */

-(void)forbiddenSideBack{
    self.isCanSideBack = NO;
    //关闭ios右滑返回
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate=self;
    }
}

/*
* 恢复边缘返回
*/

- (void)resetSideBack {
    
    self.isCanSideBack=YES;
    
    //开启ios右滑返回
    
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer*)gestureRecognizer {
    
    return self.isCanSideBack;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)czTouched:(id)sender {

            if (_hasCardId) {//实名
                if(_hastradPassword){//交易密码
                    UIStoryboard *s = [UIStoryboard storyboardWithName:@"CZ" bundle:nil];
                    CZViewController *cz = [s instantiateViewControllerWithIdentifier:@"CZViewController"];
                    
                    [self.navigationController pushViewController:cz animated:true];
                }else {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"您还未设置交易密码，去设置" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
                     //   [self showHint:@"您还未设置交易密码，请先设置交易密码" yOffset:0];
                        UIStoryboard *s = [UIStoryboard storyboardWithName:@"MMGL" bundle:nil];
                        SZJYMMViewController *cz = [s instantiateViewControllerWithIdentifier:@"SZJYMMViewController"];
                        cz.name = @"交易密码设置";
                        [self.navigationController pushViewController:cz animated:true];
                    }];
                    [ok setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
                    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"先逛逛" style:UIAlertActionStyleDefault handler:nil];
                    [cancel setValue:[UIColor lightGrayColor] forKey:@"_titleTextColor"];
                    [alert addAction:cancel];
                    [alert addAction:ok];
                    [self presentViewController:alert animated:true completion:nil];
                    
                }
            }else{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"您还没有实名认证，去认证" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    UIStoryboard *s = [UIStoryboard storyboardWithName:@"SMRZ" bundle:nil];
                    SMRZViewController *smrz = [s instantiateViewControllerWithIdentifier:@"SMRZViewController"];
                    [self.navigationController pushViewController:smrz animated:true];
                }];
                [ok setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"先逛逛" style:UIAlertActionStyleDefault handler:nil];
                [cancel setValue:[UIColor lightGrayColor] forKey:@"_titleTextColor"];
                [alert addAction:cancel];
                [alert addAction:ok];
                [self presentViewController:alert animated:true completion:nil];
               
            }
            
    
}
- (IBAction)txTouched:(id)sender {
   
            if (_hasCardId) {//实名
                if(_hastradPassword){//交易密码
                    UIStoryboard *s = [UIStoryboard storyboardWithName:@"TX" bundle:nil];
                    TXViewController *cz = [s instantiateViewControllerWithIdentifier:@"TXViewController"];
                    // cz.param = array[0];
                    [self.navigationController pushViewController:cz animated:true];
                }else {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"您还未设置交易密码，去设置" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
                        //   [self showHint:@"您还未设置交易密码，请先设置交易密码" yOffset:0];
                        UIStoryboard *s = [UIStoryboard storyboardWithName:@"MMGL" bundle:nil];
                        SZJYMMViewController *cz = [s instantiateViewControllerWithIdentifier:@"SZJYMMViewController"];
                        cz.name = @"交易密码设置";
                        [self.navigationController pushViewController:cz animated:true];
                    }];
                    [ok setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
                    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"先逛逛" style:UIAlertActionStyleDefault handler:nil];
                    [cancel setValue:[UIColor lightGrayColor] forKey:@"_titleTextColor"];
                    [alert addAction:cancel];
                    [alert addAction:ok];
                    [self presentViewController:alert animated:true completion:nil];
                }
            }else{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"您还没有实名认证，去认证" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    UIStoryboard *s = [UIStoryboard storyboardWithName:@"SMRZ" bundle:nil];
                    SMRZViewController *smrz = [s instantiateViewControllerWithIdentifier:@"SMRZViewController"];
                    [self.navigationController pushViewController:smrz animated:true];
                }];
                [ok setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"先逛逛" style:UIAlertActionStyleDefault handler:nil];
                [cancel setValue:[UIColor lightGrayColor] forKey:@"_titleTextColor"];
                [alert addAction:cancel];
                [alert addAction:ok];
                [self presentViewController:alert animated:true completion:nil];
            }
            
    
        

}
- (IBAction)hbTouched:(id)sender {
    HBViewController *hb = [self.storyboard instantiateViewControllerWithIdentifier:@"HBViewController"];
    hb.hborjxq = @"红包";
    [self.navigationController pushViewController:hb animated:true];
}

- (IBAction)jxqTouched:(id)sender {
    //[self showHint:@"敬请期待" yOffset:0];
    HBViewController *hb = [self.storyboard instantiateViewControllerWithIdentifier:@"HBViewController"];
    hb.hborjxq = @"加息券";
    [self.navigationController pushViewController:hb animated:true];
}
- (IBAction)tzjlTouched:(id)sender {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"WDTZJL" bundle:nil];
    WDTZJLViewController *wdtzjl = [s instantiateViewControllerWithIdentifier:@"WDTZJLViewController"];
    [self.navigationController pushViewController:wdtzjl animated:true];
}
- (IBAction)yqylTouched:(id)sender {
    TJYLViewController *tjyl = [self.storyboard instantiateViewControllerWithIdentifier:@"TJYLViewController"];
    [self.navigationController pushViewController:tjyl animated:true];
//    UIStoryboard *s = [UIStoryboard storyboardWithName:@"HTML" bundle:nil];
//    htmlViewController *html = [s instantiateViewControllerWithIdentifier:@"htmlViewController"];
//    html.name = @"邀请有礼";
//    [self.navigationController pushViewController:html animated:true];
    
}
- (IBAction)hkjhTouched:(id)sender {
    
    HKJHViewController *hb = [self.storyboard instantiateViewControllerWithIdentifier:@"HKJHViewController"];
    [self.navigationController pushViewController:hb animated:true];
}
- (IBAction)zjmxTouched:(id)sender {
    
    ZJMXViewController *zjmx = [self.storyboard instantiateViewControllerWithIdentifier:@"ZJMXViewController"];
    [self.navigationController pushViewController:zjmx animated:true];
}

#pragma mark - UINavigationControllerDelegate
// 将要显示控制器
//- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    // 判断要显示的控制器是否是自己
//    BOOL isShowHomePage = [viewController isKindOfClass:[self class]];
//
//    [self.navigationController setNavigationBarHidden:YES animated:NO];
//}

@end
