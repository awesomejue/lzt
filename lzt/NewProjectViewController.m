//
//  NewProjectViewController.m
//  lzt
//
//  Created by hwq on 2018/1/5.
//  Copyright © 2018年 hwq. All rights reserved.
//

#import "NewProjectViewController.h"
#import "ProjectScrollerView.h"
#define TopHeight 64
@interface NewProjectViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NaviHeight;
@property (nonatomic, strong) ProjectScrollerView *scrollerView;
@end

@implementation NewProjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (iPhoneX) {
        _NaviHeight.constant += 20;
    }
    //防止导航栏遮挡
    self.navigationController.navigationBar.translucent = false;
    [self createUI];
    
}
- (void)createUI {
    if (iPhoneX) {
        ProjectScrollerView *lxq = [[ProjectScrollerView alloc] initWithFrame:CGRectMake(0, TopHeight, DEVW, DEVH-TopHeight) titleArray:@[@"新手专享", @"投标宝", @"产融宝"]];
        lxq.con = self;
      //  lxq.hborjxq = @"红包";
        self.scrollerView = lxq;
       // self.scrollerView.con = self;
        //self.scrollerView.hborjxq = @"红包";
    }
    else {
        ProjectScrollerView *lxq = [[ProjectScrollerView alloc] initWithFrame:CGRectMake(0, TopHeight, DEVW, DEVH-TopHeight) titleArray:@[@"新手专享", @"投标宝", @"产融宝"]];
        lxq.con = self;
       // lxq.hborjxq = @"红包";
        [self.view addSubview:lxq];
         //self.scrollerView.con = self;
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
