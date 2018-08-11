//
//  MMGLViewController.m
//  lzt
//
//  Created by hwq on 2017/11/17.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "MMGLViewController.h"
#import "SZJYMMViewController.h"
#import "ModifyLoginPasswordViewController.h"
@interface MMGLViewController ()
@property (weak, nonatomic) IBOutlet UILabel *setYJMMlabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavHeight;

@end

@implementation MMGLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (iPhoneX) {
        _NavHeight.constant += 20;
    }
    [self setTitle:@"密码管理"];
    [self hideBackButtonText];
}
- (void)hideBackButtonText{
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:nil];
}

- (void)loadData {
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
            if([dic[@"hasTradePassword"] boolValue]){//交易密码
                self.setYJMMlabel.text = @"修改";
            }else {
                self.setYJMMlabel.text = @"设置";
            }
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
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}
- (void)viewWillAppear:(BOOL)animated {
    [self loadData];//判断是否已经设置交易密码
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)jymmTouched:(id)sender {
    if ([self.setYJMMlabel.text isEqualToString:@"设置"]) {
        SZJYMMViewController *sz = [self.storyboard instantiateViewControllerWithIdentifier:@"SZJYMMViewController"];
        sz.name = @"交易密码设置";
        [self.navigationController pushViewController:sz animated:true];
    }else {
        SZJYMMViewController *sz = [self.storyboard instantiateViewControllerWithIdentifier:@"SZJYMMViewController"];
        sz.name = @"交易密码修改";
        [self.navigationController pushViewController:sz animated:true];
    }
   
}
- (IBAction)dlmmTouched:(id)sender {
    ModifyLoginPasswordViewController *ml = [self.storyboard instantiateViewControllerWithIdentifier:@"ModifyLoginPasswordViewController"];
    [self.navigationController pushViewController:ml animated:true];
}



@end
