//
//  RankViewController.m
//  lzt
//
//  Created by hwq on 2018/1/11.
//  Copyright © 2018年 hwq. All rights reserved.
//

#import "RankViewController.h"
#import "RankScrollView.h"

#define TopHeight 64

@interface RankViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NaviHeight;

@property (nonatomic, strong) RankScrollerView *scrollerView;


@end

@implementation RankViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (iPhoneX) {
        _NaviHeight.constant += 20;
    }
    //防止导航栏遮挡
    self.navigationController.navigationBar.translucent = false;
    [self createUI];
}


- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (void)createUI {
    
    if (iPhoneX) {
        RankScrollerView *lxq = [[RankScrollerView alloc] initWithFrame:CGRectMake(0, TopHeight, DEVW, DEVH-TopHeight) titleArray:@[@"今日", @"本月", @"总榜"]];
        self.scrollerView = lxq;
        //self.scrollerView.hborjxq = @"红包";
    }
    else {
        RankScrollerView *lxq = [[RankScrollerView alloc] initWithFrame:CGRectMake(0, TopHeight, DEVW, DEVH-TopHeight) titleArray:@[@"今日", @"本月", @"总榜"]];
        [self.view addSubview:lxq];
        //self.scrollerView = lxq;
        //self.scrollerView.hborjxq = @"红包";
    }
    self.scrollerView.con = self;
    [self.view addSubview:self.scrollerView];
    
    
    
}

@end
