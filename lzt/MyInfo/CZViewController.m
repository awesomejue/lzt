//
//  CZViewController.m
//  lzt/Users/hwq/Downloads/手机支付SDK对接文档-2/手机支付SDK(ios)/理财demo 2/FYPayFinancialDemo/FYPayFinancialDemo/FUMobilePay.framework
//
//  Created by hwq on 2017/11/16.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "CZViewController.h"

#import "UIButton+CornerRadium.h"
#import <FUMobilePay/FUMobilePay.h>
#import "CZJLViewController.h"
#import "NavigationController.h"
#import "MyTabbarController.h"

@interface CZViewController () <UITextFieldDelegate, FYPayDelegate>
//@interface CZViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *tjBtn;
@property (weak, nonatomic) IBOutlet UITextField *czjeLabel;
@property (weak, nonatomic) IBOutlet UITextField *jymmLabel;
@property (weak, nonatomic) IBOutlet UILabel *bankName;
@property (weak, nonatomic) IBOutlet UILabel *cardNumber;
@property (weak, nonatomic) IBOutlet UIImageView *bankImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavHeight;
@property (weak, nonatomic) IBOutlet UITextField *tip;

@property (assign, nonatomic) int max;

@end

@implementation CZViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (iPhoneX) {
        _NavHeight.constant += 20;
    }
     self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    [self setTitle:@"充值"];
    [self showHudInView:self.view hint:@"载入中"];
    [self createUI];
    [self hideHud];
   
    //[self apearNav];
    [self hideBackButtonText];
}



-(void)createUI {
    
    _czjeLabel.delegate = self;
    _jymmLabel.delegate = self;
    [_tjBtn setCornerRadium];
    //获取银行卡,来判断其是否已经实名认证了。
    NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
    NSString * url =[NSString stringWithFormat:@"%@%@%@%@?token=%@&from=%@&version=%@", [FuncPublic SharedFuncPublic].rootserver ,@"user/",userInfo[@"userId"],@"/account/cards", userInfo[@"token"], @"iOS", InnerVersion];
    
    [NetManager GetRequestWithUrlString:url finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        int b = [result[@"resultCode"] intValue];
        if (b == 1) {
            [self showHint:result[@"resultMsg"] yOffset:0];
        }else if(b == 2){//token失效
             [self showHint:result[@"resultMsg"] yOffset:0];
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
            
           
        }else{
            NSArray *array = result[@"resultData"];
            if (array.count == 0) {
            }else {
                self.bankName.text = array[0][@"bankName"];
                self.bankImage.image = [UIImage imageNamed:array[0][@"bankName"]];
                self.cardNumber.text = array[0][@"cardNumber"];
                
                self.max = [array[0][@"currentLimit"] intValue];
                self.tip.text = [NSString stringWithFormat:@"单笔最高%d万，每日限额%d万元", [array[0][@"currentLimit"] intValue]/1000000, [array[0][@"dayLimit"] intValue]/1000000];
            }
            
        }
        //[self hideHud];
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
//显示导航栏
- (void) apearNav{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    //self.navigationController.navigationBar.hidden = false;
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
                    self.bankImage.image = [UIImage imageNamed:d[@"bankName"]];
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


- (IBAction)czjlBtnClicked:(id)sender {
    CZJLViewController *czjl = [self.storyboard instantiateViewControllerWithIdentifier:@"CZJLViewController"];
    czjl.type = @"充值记录";
    [self.navigationController pushViewController:czjl animated:true];
}

- (IBAction)czTouched:(id)sender {
    [_czjeLabel resignFirstResponder];
    [_jymmLabel resignFirstResponder];
}
- (void)viewWillAppear:(BOOL)animated {
   // [[NSNotificationCenter defaultCenter] postNotificationName:@"tabBarHidden" object:nil];
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

#pragma mark -fydelegate
-(void) payCallBack:(BOOL) success responseParams:(NSDictionary*) responseParams{
    NSLog(@"test");
    NSLog(@"fuiouPay");
    if ([responseParams[@"RESPONSEMSG"] isEqualToString:@"成功"]) {
        [self showHint:responseParams[@"RESPONSEMSG"]  yOffset:0];
           [self.navigationController popViewControllerAnimated:true];
    }else if([responseParams[@"RESPONSEMSG"] isEqualToString:@"验证码失效或错误"]){
        
    }else{
       [self showHint:responseParams[@"RESPONSEMSG"]  yOffset:0];
    }
    
//    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:responseParams[@"RESPONSEMSG"] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
//    [alert show];
 
}
//
- (void)fuWeiXinPayCallBackWithResponseParams:(NSDictionary *)responseParams {

}
- (IBAction)jtBtnClicked:(id)sender {
    [_czjeLabel resignFirstResponder];
    [_jymmLabel resignFirstResponder];
    if(_czjeLabel.text.length == 0) {
        [self showHint:@"充值金额不能为空！" yOffset:0];
        return;
    }else if(_jymmLabel.text.length == 0){
        [self showHint:@"交易密码不能为空！" yOffset:0];
        return;
    }else if([_czjeLabel.text intValue] < 100){
        [self showHint:@"充值金额100元起！" yOffset:0];
        return;
    }else if([_czjeLabel.text intValue] > self.max / 100){
        [self showHint:[NSString stringWithFormat:@"单笔最高%d万元", self.max / 1000000] yOffset:0];
        return;
    }else {
        [self showHudInView:self.view hint:@"充值中"];
        NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
        NSString *url =[NSString stringWithFormat:@"%@%@%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"user/",userInfo[@"userId"],@"/account/recharge/ios"];
        NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
        // [param setValue:@"6381" forKey:@"code"];
        [param setValue:@"iOS" forKey:@"from"];
        [param setValue:userInfo[@"token"] forKey:@"token"];
        [param setValue:_jymmLabel.text forKey:@"tradePassword"];
        [param setValue:InnerVersion forKey:@"version"];
        long money = [_czjeLabel.text intValue] * 100;
        [param setValue:[NSString stringWithFormat:@"%ld", money] forKey:@"money"];
        
        [NetManager requestWithUrlString:url andDic:param finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self hideHud];
            NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
            if ([result[@"resultCode"] boolValue]) {
                [self showHint:result[@"resultMsg"] yOffset:0];
            }else {
                // [self showHint:result[@"resultMsg"]];
                NSDictionary *data = result[@"resultData"];
                //调用富有支付接口
                NSString * myVERSION = data[@"version"];
                NSString * myMCHNTCD = [NSString stringWithFormat:@"%@", data[@"mchntcd"]];
                NSString * myMCHNTORDERID = [NSString stringWithFormat:@"%@", data[@"mchntorderid"]];
                NSString * myUSERID = [NSString stringWithFormat:@"%@", data[@"userid"]];
                NSString * myAMT = [NSString stringWithFormat:@"%@", data[@"amt"]];
                NSString * myBANKCARD = [NSString stringWithFormat:@"%@", data[@"bankcard"]];;
                NSString * myBACKURL = data[@"backurl"];
                NSString * myNAME = data[@"name"];
                NSString * myIDNO = [NSString stringWithFormat:@"%@", data[@"idno"]];
                NSString * myIDTYPE = [NSString stringWithFormat:@"%@", data[@"idtype"]];
                NSString * myTYPE = [NSString stringWithFormat:@"%@", data[@"type"]];
                NSString * mySIGNTP = [NSString stringWithFormat:@"%@", data[@"signtp"]];
                // NSString * myMCHNTCDKEY = [NSString stringWithFormat:@"d8n0dh23w2yzrnez52ocqb4ckzp7t0fs"];
                
                NSString * mySIGN = [NSString stringWithFormat:@"%@", data[@"sign"]];
                //添加环境参数  BOOL 变量 @"TEST"   YES 是测试  NO 是生产
                BOOL test = NO;
                  //BOOL test = YES;
                NSNumber * testNumber = [NSNumber numberWithBool:test];
                
                NSDictionary * dicD = @{@"TYPE":myTYPE,@"VERSION":myVERSION,@"MCHNTCD":myMCHNTCD,@"MCHNTORDERID":myMCHNTORDERID,@"USERID":myUSERID,@"AMT":myAMT,@"BANKCARD":myBANKCARD,@"BACKURL":myBACKURL,@"NAME":myNAME,@"IDNO":myIDNO,@"IDTYPE":myIDTYPE,@"SIGNTP":mySIGNTP,@"SIGN":mySIGN , @"TEST" : testNumber} ;
                NSLog(@"😄dicD =%@ " , dicD);
                FUMobilePay * pay = [FUMobilePay shareInstance];
                if([pay respondsToSelector:@selector(mobilePay:delegate:)])
                        [pay performSelector:@selector(mobilePay:delegate:) withObject:dicD withObject:self];
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
}
#pragma mark-uitextfield delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    //假如多个输入，比如注册和登录，就可以根据不同的输入框来上移不同的位置，从而更加人性化
    //键盘高度216
    //滑动效果（动画）
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@ "ResizeForKeyboard"  context:nil];
    [UIView setAnimationDuration:animationDuration];
    if (textField.tag == 0) {
        //将视图的Y坐标向上移动，以使下面腾出地方用于软键盘的显示
        self.view.frame = CGRectMake(0.0f, -60.0f/*屏幕上移的高度，可以自己定*/, self.view.frame.size.width, self.view.frame.size.height);
    }else if (textField.tag == 1) {
        //将视图的Y坐标向上移动，以使下面腾出地方用于软键盘的显示
        self.view.frame = CGRectMake(0.0f, -100.0f/*屏幕上移的高度，可以自己定*/, self.view.frame.size.width, self.view.frame.size.height);
    }
    [UIView commitAnimations];
}
//取消第一响应，也就是输入完毕，屏幕恢复原状
-( void )textFieldDidEndEditing:(UITextField *)textField
{
    //滑动效果
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@ "ResizeForKeyboard"  context:nil];
    [UIView setAnimationDuration:animationDuration];
    //恢复屏幕
    self.view.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}



@end
