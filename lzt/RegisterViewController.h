//
//  RegisterViewController.h
//  lzt
//
//  Created by hwq on 2017/11/15.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParentsViewController.h"
#import "ForgetPasswordViewController.h"
@interface RegisterViewController : ParentsViewController

@property(nonatomic , assign)NSString *isChildViewcontroller;

@property(nonatomic, strong)ForgetPasswordViewController *forget;

@property (nonatomic,assign) BOOL isLoginRegister; //判断是直接点击我的的时候跳转的还是从其他地方

@property (nonatomic,strong) NSString * phone;

@property (nonatomic, assign) int isCPXQ;

@end
