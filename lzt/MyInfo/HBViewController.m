//
//  HBViewController.m
//  lzt
//
//  Created by hwq on 2017/11/18.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "HBViewController.h"
#import "LXQScrollerView.h"
#import "NewsDetailViewController.h"
#import "htmlViewController.h"
#import "JXQScrollView.h"
#import "htmlViewController.h"
#import "NavigationController.h"
#import "MyTabbarController.h"
#define TopHeight 64
@interface HBViewController ()
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;
@property (weak, nonatomic) IBOutlet UILabel *headTitle;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavHeight;
@property (nonatomic, strong) LXQScrollerView *scrollerView;
@property (nonatomic, strong) JXQScrollView *jxqscrollerView;
@end

@implementation HBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (iPhoneX) {
        _NavHeight.constant += 20;
    }
    //防止导航栏遮挡
    self.navigationController.navigationBar.translucent = false;
    [self createUI];
    //[self apearNav];
    [self hideBackButtonText];
}

- (void)createUI {
    //监控token失效
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(popToFirst) name:@"tokenlost" object:nil];
    if ([_hborjxq isEqualToString:@"红包"]) {
        self.headTitle.text = @"红包";
         [_rightBtn setTitle:@"红包规则" forState:UIControlStateNormal];
        if (iPhoneX) {
            LXQScrollerView *lxq = [[LXQScrollerView alloc] initWithFrame:CGRectMake(0, TopHeight, DEVW, DEVH-TopHeight) titleArray:@[@"未使用", @"已使用", @"已过期"]];
            lxq.hborjxq = @"红包";
            self.scrollerView = lxq;
            //self.scrollerView.hborjxq = @"红包";
        }
        else {
            LXQScrollerView *lxq = [[LXQScrollerView alloc] initWithFrame:CGRectMake(0, TopHeight, DEVW, DEVH-TopHeight) titleArray:@[@"未使用", @"已使用", @"已过期"]];
            lxq.hborjxq = @"红包";
            [self.view addSubview:lxq];
            //self.scrollerView = lxq;
            //self.scrollerView.hborjxq = @"红包";
        }
        self.scrollerView.con = self;
        [self.view addSubview:self.scrollerView];
    }else {
         self.headTitle.text = @"加息券";
         [_rightBtn setTitle:@"加息券规则" forState:UIControlStateNormal];
        if (iPhoneX) {
            JXQScrollView *lxq = [[JXQScrollView alloc] initWithFrame:CGRectMake(0, TopHeight, DEVW, DEVH-TopHeight) titleArray:@[@"未使用", @"已使用", @"已过期"]];
            lxq.hborjxq = @"加息券";
            self.jxqscrollerView = lxq;
           // self.scrollerView.hborjxq = @"加息券";
        }
        else {
            JXQScrollView *lxq = [[JXQScrollView alloc] initWithFrame:CGRectMake(0, TopHeight, DEVW, DEVH-TopHeight) titleArray:@[@"未使用", @"已使用", @"已过期"]];
            lxq.hborjxq = @"加息券";
            self.jxqscrollerView = lxq;
            //self.scrollerView.hborjxq = @"加息券";
        }
        self.scrollerView.con = self;
        [self.view addSubview:self.jxqscrollerView];
    }
    
  
}
- (IBAction)hbrule:(id)sender {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"HTML" bundle:nil];
    htmlViewController *detail = [s instantiateViewControllerWithIdentifier:@"htmlViewController"];
    //detail.nid = [dataSource[indexPath.row][@"id"] intValue];
    if ([_hborjxq isEqualToString:@"红包"]) {
        [_rightBtn setTitle:@"红包规则" forState:UIControlStateNormal];
        detail.name = @"红包规则";
    }else {
        [_rightBtn setTitle:@"加息券规则" forState:UIControlStateNormal];
        detail.name = @"加息券规则";
    }
    
    [self.navigationController pushViewController:detail animated:true];
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

//显示导航栏
- (void) apearNav{
     [self.navigationController setNavigationBarHidden:NO animated:YES];
    //self.navigationController.navigationBar.hidden = false;
}
- (void)addRightButtonItem:(NSString *)title {
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithTitle:title style: UIBarButtonItemStylePlain target:self action:@selector(hbClicked:)];
    self.navigationItem.rightBarButtonItem = right;
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)hbClicked:(id)sender {
    if ([_hborjxq isEqualToString:@"红包"]) {
        UIStoryboard *s = [UIStoryboard storyboardWithName:@"HTML" bundle:nil];
        htmlViewController *html = [s instantiateViewControllerWithIdentifier:@"htmlViewController"];
        html.name = @"红包规则";
        
        [self.navigationController pushViewController:html animated:true];
    }else {
//        HBRuleViewController *rule = [[HBRuleViewController alloc]init];
//        rule.type = @"红包规则";
//        [self.navigationController pushViewController:rule animated:true];
    }
}
- (void)hideBackButtonText{
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:nil];
}
- (void)viewWillAppear:(BOOL)animated {
    self.automaticallyAdjustsScrollViewInsets = false;
   // [[NSNotificationCenter defaultCenter] postNotificationName:@"tabBarHidden" object:nil];
}

@end
