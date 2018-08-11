//
//  HKJHViewController.m
//  lzt
//
//  Created by hwq on 2017/11/21.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "HKJHViewController.h"
#import "HKJHScrollerView.h"
#import "NavigationController.h"
#import "MyTabbarController.h"
#define TopHeight 64

@interface HKJHViewController ()

@property (nonatomic, strong) HKJHScrollerView *scrollerView;

@property (nonatomic, assign) double repayedCorpus;//已收本金
@property (nonatomic, assign) double repayedInterest;//已收利息
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavHeight;

@end

@implementation HKJHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (iPhoneX) {
        _NavHeight.constant += 20;
    }
    [self setTitle:@"回款计划"];
    //防止导航栏遮挡
    self.navigationController.navigationBar.translucent = false;
    [self createUI];
    [self hideBackButtonText];
    //[self apearNav];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
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
- (void)viewWillAppear:(BOOL)animated {
    self.automaticallyAdjustsScrollViewInsets = YES;
    //[self loadViewHeaderData];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"tabBarHidden" object:nil];
}
- (void) loadViewHeaderData{
    NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
    NSString *url = [NSString stringWithFormat:@"%@%@%@%@", [FuncPublic SharedFuncPublic].rootserver, @"user/",userInfo[@"userId"],@"/totalData"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setValue:userInfo[@"token"] forKey:@"token"];
    [NetManager GetRequestWithUrlString:url andDic:param finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        if ([result[@"resultCode"] boolValue]) {
            [self showHint:result[@"resultMsg"] yOffset:0];
        }else {
            NSDictionary *dic = result[@"resultData"];
            _repayedCorpus = [dic[@"repayedCorpus"] doubleValue];
            _repayedInterest = [dic[@"repayedInterest"] doubleValue];
            //            _repayedCorpus.text =[NSString stringWithFormat:@"%@", dic[@"repayedCorpus"]];
            //            _repayedInterest.text = [NSString stringWithFormat:@"%@",dic[@"repayedInterest"]];
        }
        //  [self.con hideHud];
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
- (void)createUI {
    NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
    NSString *url = [NSString stringWithFormat:@"%@%@%@%@", [FuncPublic SharedFuncPublic].rootserver, @"user/",userInfo[@"userId"],@"/totalData"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setValue:userInfo[@"token"] forKey:@"token"];
    [NetManager GetRequestWithUrlString:url andDic:param finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        int b = [result[@"resultCode"] intValue];
        if (b == 1) {
            [self showHint:result[@"resultMsg"] yOffset:0];
        }else if(b == 2){//token失效
            [self showHint:result[@"resultMsg"] yOffset:0];
            [FuncPublic SaveDefaultInfo:@"0" Key:userIsLogin];
            [FuncPublic SaveDefaultInfo:@"" Key:mSaveAccount];
            [FuncPublic SaveDefaultInfo:@"" Key:mUserInfo];
            [UIView transitionWithView:self.view duration:1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                //跳回首页
                NavigationController *nav =   (NavigationController *) [UIApplication sharedApplication].keyWindow.rootViewController ;
                MyTabbarController *tab =  nav.viewControllers[0];
                tab.selectedIndex = 0;
                [self.navigationController popViewControllerAnimated:true];
            }completion:^(BOOL finished){
                NSLog(@"动画结束");
            }];
            
        }else {
            NSDictionary *dic = result[@"resultData"];
            _repayedCorpus = [dic[@"repayedCorpus"] doubleValue];
            _repayedInterest = [dic[@"repayedInterest"] doubleValue];
            if (iPhoneX) {
                HKJHScrollerView *hkjh = [[HKJHScrollerView alloc] initWithFrame:CGRectMake(0, TopHeight, DEVW, DEVH-TopHeight) titleArray:@[@"待回款", @"已回款"]];
                hkjh.repayedCorpus = _repayedCorpus;
                hkjh.repayedInterest = _repayedInterest;
                self.scrollerView = hkjh;
            }
            else {
                HKJHScrollerView *hkjh = [[HKJHScrollerView alloc] initWithFrame:CGRectMake(0, TopHeight, DEVW, DEVH-TopHeight) titleArray:@[@"待回款", @"已回款"]];
                hkjh.repayedCorpus = _repayedCorpus;
                hkjh.repayedInterest = _repayedInterest;
                self.scrollerView = hkjh;
            }
            
            self.scrollerView.con = self;
            [self.view addSubview:self.scrollerView];
        }
        //  [self.con hideHud];
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
@end
