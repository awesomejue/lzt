//
//  YHKGLViewController.m
//  lzt
//
//  Created by hwq on 2017/11/21.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "YHKGLViewController.h"

@interface YHKGLViewController ()
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIImageView *imageview;
@property (weak, nonatomic) IBOutlet UILabel *cardNumber;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *bankName;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavHeight;

@property (weak, nonatomic) IBOutlet UILabel *flag;
@end

@implementation YHKGLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (iPhoneX) {
        _NavHeight.constant += 20;
    }
    [self setTitle:@"银行卡管理"];
    [self createUI];
    [self loadData];
}
- (void)createUI {
    _bgView.layer.cornerRadius = 5;
    _bgView.layer.masksToBounds = YES;
}
- (void)loadData {
    NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
    NSString *url =[NSString stringWithFormat:@"%@%@%@%@?token=%@&from=%@&version=%@", [FuncPublic SharedFuncPublic].rootserver ,@"user/",userInfo[@"userId"],@"/account/cards", userInfo[@"token"], @"iOS", InnerVersion];
    
    [self showHudInView:self.view hint:@"载入中"];
    [NetManager GetRequestWithUrlString:url finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self hideHud];
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        if ([result[@"resultCode"] boolValue]) {
            [self showHint:result[@"resultMsg"] yOffset:0];
        }else {
            NSArray *array = result[@"resultData"];
            if (array.count > 0) {
                self.cardNumber.text = array[0][@"cardNumber"];
                self.name.text = array[0][@"realName"];
                self.flag.text = @"已绑定";
                self.imageview.image = [UIImage imageNamed:array[0][@"bankName"]];
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

- (void)getBankName:(NSString *)bankCode {
    //载入数据
    NSString *url =[NSString stringWithFormat:@"%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"user/bankcode/list"];
    url = [NSString stringWithFormat:@"%@?from=%@&version=%@", url, @"iOS", InnerVersion];
    [NetManager GetRequestWithUrlString:url finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        if ([result[@"resultCode"] boolValue]) {
            [self showHint:result[@"resultMsg"] yOffset:0];
        }else {
            NSArray *dataSoure =  result[@"resultData"];
            for (NSDictionary *d in dataSoure) {
                if ([d[@"bankCode"] isEqualToString:bankCode]) {
                    self.bankName.text = d[@"bankName"];
                    self.imageview.image = [UIImage imageNamed:d[@"bankName"]];
                }
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
    }];
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}
@end
