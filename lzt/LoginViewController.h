//
//  LoginViewController.h
//  lzt
//
//  Created by hwq on 2017/11/15.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginRegisterViewController.h"
@interface LoginViewController : UIViewController
//是否是导航栏 push的
@property (nonatomic,assign) BOOL isChildViewController;

@property (nonatomic,assign) BOOL isLoginRegister; //判断是直接点击我的的时候跳转的还是从其他地方。
@property (nonatomic,assign) BOOL isQuitLogin;//是否是从安全退出弹出的登陆框。
@property (nonatomic,assign) NSUInteger selectedIndex;

@property (nonatomic,strong) NSString * telephone;
@property (nonatomic, strong) LoginRegisterViewController *loginregister;

@property (nonatomic, assign) int isCPXQ;

@end
