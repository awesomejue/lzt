//
//  TGJLViewController.m
//  lzt
//
//  Created by hwq on 2018/3/8.
//  Copyright © 2018年 hwq. All rights reserved.
//

#import "TGJLViewController.h"
#import "TGJLScrollView.h"
#import "NavigationController.h"
#import "MyTabbarController.h"
#define TopHeight 64
@interface TGJLViewController ()

@property (weak, nonatomic) IBOutlet UILabel *headTitle;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavHeight;
@property (nonatomic, strong) TGJLScrollView *scrollerView;

@end

@implementation TGJLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (iPhoneX) {
        _NavHeight.constant += 20;
    }
    //防止导航栏遮挡
    self.navigationController.navigationBar.translucent = false;
    [self createUI];
}
- (IBAction)back:(id)sender {
}

- (void)popToFirst {
    [self showHint:@"登陆失效，请重新登录" yOffset:0];
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
}
- (void)createUI {
    //监控token失效
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(popToFirst) name:@"tokenlost" object:nil];
    if (iPhoneX) {
        TGJLScrollView *lxq = [[TGJLScrollView alloc] initWithFrame:CGRectMake(0, TopHeight, DEVW, DEVH-TopHeight) titleArray:@[@"推广记录", @"红包记录"]];
        self.scrollerView = lxq;
    }
    else {
        TGJLScrollView *lxq = [[TGJLScrollView alloc] initWithFrame:CGRectMake(0, TopHeight, DEVW, DEVH-TopHeight) titleArray:@[@"推广记录", @"红包记录"]];
        self.scrollerView = lxq;
        //[self.view addSubview:lxq];
        //self.scrollerView = lxq;
        //self.scrollerView.hborjxq = @"红包";
    }
    self.scrollerView.con = self;
    [self.view addSubview:self.scrollerView];
    
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
