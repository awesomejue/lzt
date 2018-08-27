//
//  NavigationController.m
//  lzt
//
//  Created by hwq on 2017/10/23.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "NavigationController.h"

@interface NavigationController ()

@end

@implementation NavigationController
//自定义导航栏
- (void)viewDidLoad {
    [super viewDidLoad];
    //去掉导航栏返回按钮的文字
    //[[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                //self.navigationController.navigationBar.barStyle = UIBarStyleBlack;                                    //     forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.barTintColor = [UIColor whiteColor];
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    //self.navigationBar.translucent = false;
//    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:1.0 green:0 / 255.0 blue:0 /255.0 alpha:1]];    [[UINavigationBar appearance] setTitleTextAttributes:
//     [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@ "PingFang SC" size:19.0], NSFontAttributeName, nil]];
	
    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0x2399f7)];
    
    [[UINavigationBar appearance] setTitleTextAttributes:
                                                                                                                         [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@ "PingFang SC" size:19.0], NSFontAttributeName, nil]];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
