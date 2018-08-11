//
//  TXViewController.m
//  lzt
//
//  Created by hwq on 2017/11/17.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "TXViewController.h"

#import "TZView.h"
#import "htmlViewController.h"
#import "CZJLViewController.h"
#import "NavigationController.h"
#import "MyTabbarController.h"
#import "UIButton+CornerRadium.h"
@interface TXViewController ()<UITextFieldDelegate>
{
    TZView *tz; //输入交易密码界面
    NSString *lastinputNumber; //记录上次输入的提现金额
    double KTXJE;//保存分单位的可提现金额
}
@property (weak, nonatomic) IBOutlet UIButton *txBtn;
@property (weak, nonatomic) IBOutlet UITextField *txjeLabel;
@property (weak, nonatomic) IBOutlet UILabel *ktxjelabel;
@property (weak, nonatomic) IBOutlet UILabel *bankName;
@property (weak, nonatomic) IBOutlet UILabel *cardNumber;
@property (weak, nonatomic) IBOutlet UIImageView *bankImage;
@property (weak, nonatomic) IBOutlet UITextField *sxf;
@property (weak, nonatomic) IBOutlet UITextField *acturlMoney;
@property (weak, nonatomic) IBOutlet UITextField *leftTimes;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavHeight;
@property (assign, nonatomic) double commission;//手续费

@end

@implementation TXViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (iPhoneX) {
        _NavHeight.constant += 20;
    } self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    [self setTitle:@"提现"];
    //[self createUI];
    [self hideBackButtonText];
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}
- (IBAction)txrule:(id)sender {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"HTML" bundle:nil];
    htmlViewController *detail = [s instantiateViewControllerWithIdentifier:@"htmlViewController"];
    //detail.nid = [dataSource[indexPath.row][@"id"] intValue];
    detail.name = @"提现规则";
    [self.navigationController pushViewController:detail animated:true];
}
- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self showHudInView:self.view hint:@"载入中"];
    [self createUI];
    [self hideHud];
}
- (void)createUI {
    
    _txjeLabel.delegate = self;
    [_txjeLabel addTarget:self action:@selector(textChange:) forControlEvents:UIControlEventEditingChanged];
    self.txBtn.layer.cornerRadius = 5;
    
    //获取银行卡。
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

    //  初始化可提现金额
    //[self showHudInView:self.view hint:@"载入中"];
    userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
    url =[NSString stringWithFormat:@"%@%@%@%@?token=%@&from=%@&version=%@", [FuncPublic SharedFuncPublic].rootserver ,@"user/",userInfo[@"userId"],@"/accountInfo", userInfo[@"token"], @"iOS", InnerVersion];
    
    [NetManager GetRequestWithUrlString:url finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        int b = [result[@"resultCode"] intValue];
        if (b == 1) {
            [self showHint:result[@"resultMsg"] yOffset:0];
        }else{
            self.ktxjelabel.text =[NSString stringWithFormat:@"%.2f", [result[@"resultData"][@"money"] longValue] / 100.0];
            KTXJE = [result[@"resultData"][@"money"] intValue];
        }
        [self hideHud];
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
    
    [self getLeftTimesAndSxf:0 andIsFirst:true];
    //[self showHudInView:self.view hint:@"载入中"];
    //获取银行卡
    //userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
    
    
    [self hideHud];
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
//申请提现手续费
- (void)getLeftTimesAndSxf:(double)money  andIsFirst:(BOOL)isFirst{
    
    NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
    
    NSString *url = [NSString stringWithFormat:@"%@%@%@%@?token=%@&from=%@&version=%@&money=%.0f", [FuncPublic SharedFuncPublic].rootserver ,@"user/account/",userInfo[@"userId"],@"/withdraw/info", userInfo[@"token"], @"iOS", InnerVersion, money];
    //[self showHudInView:self.view hint:@"载入中"];
    [NetManager GetRequestWithUrlString:url finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        if ([result[@"resultCode"] boolValue]) {
            [self showHint:result[@"resultMsg"] yOffset:0];
        }else {
            NSDictionary *dic = result[@"resultData"];
            self.leftTimes.text =[NSString stringWithFormat:@"%@", dic[@"count"]];
            double fee = [dic[@"fee"] doubleValue] / 100;
            if (fee > 0) {
                self.sxf.text =[NSString stringWithFormat:@"%.2f", fee];//手续费
            }else {
                self.sxf.text = @"0";
            }
            
            
            // self.sxf.text = @"3";
            _commission = [dic[@"fee"] doubleValue];//保存手续费
            if (isFirst) {
                self.acturlMoney.text = @"0";
            }else {
                self.acturlMoney.text =[NSString stringWithFormat:@"%.2f", money/100 - _commission / 100];
            }
            
        }
        [self hideHud];
    } failed:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        
        if(error.code == -1009){
            [self showHint:@"网络连接失败，请检查网络状态。" yOffset:0];
        }else if(error.code == -1004){
            [self showHint:@"服务器开了个小差。" yOffset:0];
        }else if(error.code == -1001){
            [self showHint:@"请求超时，请检查网络状态。" yOffset:-Screen_Height/4];
        }
        [self hideHud];
    }];
}
- (IBAction)tjBtnClicked:(id)sender {
    [self hidekeyboard:nil];
    if(_txjeLabel.text.length == 0) {
        [self showHint:@"提现金额不能为空！" yOffset:0];
        return;
    }else if([_txjeLabel.text intValue] < 100){
        [self showHint:@"提现金额至少100元起" yOffset:0];
    }else {
         [self animiationAddSubView];
    }
}
//动画效果添加子视图
- (void) animiationAddSubView {
    //载入xib方法。
    tz = [[[NSBundle mainBundle] loadNibNamed:@"TZView" owner:self options:nil] lastObject];
    
    tz.centerView.layer.cornerRadius = 5;
    tz.centerView.layer.masksToBounds = true;
    tz.jyView.layer.cornerRadius = 5;
    tz.password.delegate = self;
    [tz.password addTarget:self action:@selector(textChange) forControlEvents:UIControlEventEditingChanged];
    // tz.alpha = 0.4;
    [tz.okBtn setCornerRadium];
    [tz.okBtn addTarget:self action:@selector(tx:) forControlEvents:UIControlEventTouchUpInside];
    [tz.cancelBtn setCornerRadium];
    tz.frame = CGRectMake(0,  0, Screen_Width , Screen_Height);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard:)];
    [tz addGestureRecognizer:tap];
    //CalculaterView *cal = [[CalculaterView alloc]initWithFrame:CGRectMake(0,  0, Screen_Width , Screen_Height)];
    // CalculaterView *cal = [[CalculaterView alloc]initWithFrame:CGRectMake(100, 100, 200, 200)];
    //cal.layer.zPosition = 10;
    // cal.backgroundColor = [UIColor grayColor];
    [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self.view addSubview:tz];
        [self.view bringSubviewToFront:tz];
    }completion:^(BOOL finished){
        NSLog(@"动画结束");
    }];
}
- (void)tx:(id)sender {
    [self hideKeyboard:nil];
        [self showHudInView:self.view hint:@"提现中"];
        NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
        NSString *url =[NSString stringWithFormat:@"%@%@%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"user/account/",userInfo[@"userId"],@"/withdraw/apply"];
        NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
        // [param setValue:@"6381" forKey:@"code"];
        [param setValue:@"iOS" forKey:@"from"];
        [param setValue:userInfo[@"token"] forKey:@"token"];
        [param setValue:tz.password.text forKey:@"tradePassword"];
        [param setValue:InnerVersion forKey:@"version"];
    //转化为double类型
        long money = [_txjeLabel.text doubleValue] * 100;
        [param setValue:[NSString stringWithFormat:@"%ld", money] forKey:@"money"];
        
        [NetManager requestWithUrlString:url andDic:param finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self hideHud];
            NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
            if ([result[@"resultCode"] boolValue]) {
                [self showHint:result[@"resultMsg"] yOffset:0];
            }else {
                [self showHint:result[@"resultMsg"]];
                //提现成功实时刷新可提现金额
                double txje = [self.txjeLabel.text doubleValue] * 100;
                self.ktxjelabel.text =[NSString stringWithFormat:@"%.2f", (KTXJE - txje)/100.0];
                KTXJE = KTXJE - txje;
                [tz removeFromSuperview];
                [self.navigationController popViewControllerAnimated:true];
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
- (void) hideKeyboard:(id)sender {
    [tz.password resignFirstResponder];
}
- (IBAction)hidekeyboard:(id)sender {
    [_txjeLabel resignFirstResponder];
}

- (IBAction)txjl:(id)sender {
    
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"CZ" bundle:nil];
    CZJLViewController *czjl = [s instantiateViewControllerWithIdentifier:@"CZJLViewController"];
    czjl.type = @"提现记录";
    [self.navigationController pushViewController:czjl animated:true];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//显示导航栏
- (void) apearNav{
     [self.navigationController setNavigationBarHidden:NO animated:YES];
   // self.navigationController.navigationBar.hidden = false;
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
        self.view.frame = CGRectMake(0.0f, -100.0f/*屏幕上移的高度，可以自己定*/, self.view.frame.size.width, self.view.frame.size.height);
    }
    [UIView commitAnimations];
    
   
}
//实时监控输入
-(void)textChange :(UITextField *)theTextField{
    
    //判断是否只包含数字和点号
    if([FuncPublic isOnlyhasNumberAndpointWithString:theTextField.text]){
        //实时计算实际提取金额。
        double money = [theTextField.text doubleValue];
        if([self isTwoDian:theTextField.text]){
            if (money >= 100) {
                if(money * 100 > KTXJE){
                    
                    [self showHint:@"提现金额不能超过可提现金额！" yOffset:-Screen_Height/4];
                    //NSString *value = self.txjeLabel.text;
                  //  self.txjeLabel.text = [value substringToIndex:value.length-1];
                }else {
                    [self getLeftTimesAndSxf:money * 100 andIsFirst:false];
                   // double sxf = [self.sxf.text doubleValue];
                   // self.acturlMoney.text = [NSString stringWithFormat:@"%.2f", (money - sxf)]; //实际提取金额
                }
                
            }else {
                self.acturlMoney.text = @"0";
            }
        }else {
           
            NSString *value = self.txjeLabel.text;
            self.txjeLabel.text = [value substringToIndex:value.length-1];
            [self showHint:@"只能有两位小数" yOffset: -Screen_Height / 2];
        }
    }else {
        NSString *value = self.txjeLabel.text;
        self.txjeLabel.text = [value substringToIndex:value.length-1];
         [self showHint:@"只能输入数字" yOffset: -Screen_Height / 2];
    }
    
    
}
//判断是否只有两个小数点
- (BOOL )isTwoDian:(NSString *)money {
    NSArray *arr = [money componentsSeparatedByString:@"."];
    if (arr.count == 2) {
        if ([arr[1] intValue] >= 100) {
            return false;
        }else {
            return true;
        }
    }else if(arr.count == 1){
        return true;
    }
    return true;
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

- (void)textChange {
    NSString *password = tz.password.text;
   // NSString *confirmPassword = self.confirmPassword.text;
    
    if (password.length>6) {
        tz.password.text = [password substringToIndex:password.length - 1];
        [self showHint:@"只能输入6位数字交易密码" yOffset:-Screen_Height / 3];
    }
}

@end
