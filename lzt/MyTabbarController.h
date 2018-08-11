//
//  MyTabbarController.h
//  lzt
//
//  Created by hwq on 2017/12/1.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FoundationController.h"
#import "MyInfoViewController.h"
#import "HomePageViewController.h"
#import "ProjectController.h"
#import "NewProjectViewController.h"
#import "NewFoundationViewController.h"
@interface MyTabbarController : UITabBarController
@property (nonatomic, strong) HomePageViewController *homePage;
@property (nonatomic, strong) ProjectController *project;
@property (nonatomic, strong) NewProjectViewController *newproject;
@property (nonatomic, strong) FoundationController *found;
@property (nonatomic, strong) NewFoundationViewController *nfound;
@property (nonatomic, strong) MyInfoViewController *myinfo;

@end
