//
//  TZViewController.m
//  lzt
//
//  Created by hwq on 2017/11/18.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "TZViewController.h"
#import "UIButton+CornerRadium.h"
#import "TZView.h"
#import "QRTZ.h"
#import "CZViewController.h"
#import "HBViewController.h"
#import "ProjectHBTableViewController.h"
@interface TZViewController ()<ChooseHBDelegate, UITextFieldDelegate>
{
    TZView *tz; //输入交易密码界面
    QRTZ *result;
    
    NSString *pocketID;
    NSString *jxqID;
    
}
@property (weak, nonatomic) IBOutlet UIButton *qdBtn;
@property (weak, nonatomic) IBOutlet UITextField *buyLabel;
@property (weak, nonatomic) IBOutlet UILabel *allBuyLabel;
@property (weak, nonatomic) IBOutlet UILabel *syktMoney;
@property (weak, nonatomic) IBOutlet UILabel *zhyeMoney;
@property (weak, nonatomic) IBOutlet UITextField *gmjeLabel;
@property (weak, nonatomic) IBOutlet UILabel *minMoney;
@property (weak, nonatomic) IBOutlet UILabel *maxMoney;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavHeight;
@property (weak, nonatomic) IBOutlet UILabel *titleName;

@property (weak, nonatomic) IBOutlet UILabel *anotherZhyeMoney;
@property (weak, nonatomic) IBOutlet UILabel *hbMoney;
@property (weak, nonatomic) IBOutlet UILabel *jxq;

@property(nonatomic, assign)NSString *hborjxq;

@property (weak, nonatomic) IBOutlet UILabel *hbType;

@end

@implementation TZViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (iPhoneX) {
        _NavHeight.constant += 20;
    }
    [self setTitle:_cpData[@"name"]];
    
    [self createUI];
    [self hideBackButtonText];
}

- (IBAction)qdClicked:(id)sender {
    [self hideKeyboard:nil];
   // double i = [_hbMoney.text doubleValue];
    if ([_gmjeLabel.text intValue] == 0) {
        [self showHint:@"请输入投资金额" yOffset:0];
    }else if(_gmjeLabel.text.length == 0){
        [self showHint:@"购买金额不能为空！" yOffset:0];
    }else if([_gmjeLabel.text intValue] < [self.minMoney.text intValue]){
        [self showHint:@"投资金额不能小于起投金额！" yOffset:0];
    }else if([_gmjeLabel.text doubleValue] > [self.zhyeMoney.text doubleValue] + [_hbMoney.text doubleValue]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"账户余额不足，去充值" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            UIStoryboard *s = [UIStoryboard storyboardWithName:@"CZ" bundle:nil];
            CZViewController *cz = [s instantiateViewControllerWithIdentifier:@"CZViewController"];
            
            [self.navigationController pushViewController:cz animated:true];
        }];
        [ok setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
        [cancel setValue:[UIColor lightGrayColor] forKey:@"_titleTextColor"];
        [alert addAction:cancel];
        [alert addAction:ok];
        [self presentViewController:alert animated:true completion:nil];
    }else if([_gmjeLabel.text intValue] >  [self.syktMoney.text intValue]){
        [self showHint:@"投资金额不能大于剩余可投金额" yOffset:0];
    }else if([_gmjeLabel.text intValue] > [self.maxMoney.text intValue]){
        [self showHint:@"投资金额不能大于限投金额！" yOffset:0];
    }else {
        [self animiationAddResult];
    }
    //定向标需要输入特殊密码
   // if ([_cpData[@"specialPlan"] boolValue]) {
    
//    }else {//普通标不需要输入密码
//
//        if(_gmjeLabel.text.length == 0){
//            [self showHint:@"购买金额不能为空！" yOffset:0];
//        }else if([_gmjeLabel.text intValue] < [self.minMoney.text intValue]){
//            [self showHint:@"购买金额不能少于最小投资金额！" yOffset:0];
//        }else if([_gmjeLabel.text intValue] > [self.maxMoney.text intValue]){
//            [self showHint:@"购买金额不能多余于最大投资金额！" yOffset:0];
//        }else if([_gmjeLabel.text intValue] > [self.maxMoney.text intValue]){
//            [self showHint:@"购买金额不能多余于最大投资金额！" yOffset:0];
//        }else if([self.zhyeMoney.text intValue] + [self.hbMoney.text intValue] < [_gmjeLabel.text intValue]){
//            [self showHint:@"账户余额和红包不能少于投资金额！" yOffset:0];
//        }else{
//            [self animiationAddResult];
//        }
//    }
}
- (void)createUI{
    self.titleName.text = _cpData[@"name"];
    _allBuyLabel.layer.cornerRadius = 5;
    _allBuyLabel.layer.borderColor = [UIColor redColor].CGColor;
    _allBuyLabel.layer.borderWidth = 1;
    [_qdBtn setCornerRadium];
    
    _gmjeLabel.delegate = self;
    [_gmjeLabel addTarget:self action:@selector(textChange:) forControlEvents:UIControlEventEditingChanged];
    //self.txBtn.layer.cornerRadius = 5;
    //剩余可投
    long money = [_cpData[@"amount"] doubleValue] - [_cpData[@"nowSum"] doubleValue];
    _syktMoney.text = [FuncPublic countNumAndChangeformat:[NSString stringWithFormat:@"%ld", money /100]];
    _syktMoney.text =[NSString stringWithFormat:@"%ld", money / 100];
}

- (void)animiationAddResult {
    //载入xib方法。
    result = [[[NSBundle mainBundle] loadNibNamed:@"QRTZ" owner:self options:nil] lastObject];
    result.bgView.layer.cornerRadius = 5;
    result.bgView.layer.masksToBounds = true;
    result.bgView.layer.cornerRadius = 5;
    if (![_cpData[@"specialPlan"] boolValue]) {//不是约标,不需要输入交易密码
        result.bgViewHeight.constant -= result.passwordHeight.constant;
        result.passwordHeight.constant = 0;
        result.yblabel.hidden = YES;
        result.jymm.hidden = YES;//约标密码
        result.btnTOP.constant -= 1;
    }else {
        
    }
    // tz.alpha = 0.4;
    [result.okBtn addTarget:self action:@selector(resultOK) forControlEvents:UIControlEventTouchUpInside];
    //[result.cancelBtn];
    result.frame = CGRectMake(0,  0, Screen_Width , Screen_Height);
    
    //初始化界面
    if ([self.hbMoney.text isEqualToString:@"选择"]) {
        result.pocket.text = @"0";
        result.avaiMoney.text = self.gmjeLabel.text;
    }else{
        if([self.hbMoney.text isEqualToString:@"选择"]){
            result.pocket.text = @"0";
        }else {
            result.pocket.text = self.hbMoney.text;
        }
        
        result.avaiMoney.text =[NSString stringWithFormat:@"%.0f", [self.gmjeLabel.text doubleValue] - [self.hbMoney.text doubleValue]] ;

    }
    if ([self.jxq.text  isEqualToString:@"选择"]) {
        result.jxq.text = @"--";
    }else {
        result.jxq.text = self.jxq.text;
    }
    result.totalMoney.text = self.gmjeLabel.text;
    
    [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self.view addSubview:result];
        [self.view bringSubviewToFront:result];
    }completion:^(BOOL finished){
        NSLog(@"动画结束");
    }];
}

//动画效果添加子视图
- (void) animiationAddSubView {
    //载入xib方法。
    tz = [[[NSBundle mainBundle] loadNibNamed:@"TZView" owner:self options:nil] lastObject];
    tz.centerView.layer.cornerRadius = 5;
    tz.centerView.layer.masksToBounds = true;
    tz.jyView.layer.cornerRadius = 5;
   // tz.alpha = 0.4;
    [tz.okBtn setCornerRadium];
    [tz.okBtn addTarget:self action:@selector(specialTZ) forControlEvents:UIControlEventTouchUpInside];
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
- (void)resultOK {
    [self hideKeyboard:nil];
    
    if([_cpData[@"specialPlan"] boolValue]){
        //[result.jymm resignFirstResponder];
        if ([result.jymm.text length] == 0) {
            [self showHint:@"请输入约标密码" yOffset:-Screen_Height / 4];
            [self hideHud];
            return;
        }
    }
    [self showHudInView:self.view hint:@"载入中"];
    NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
    NSString *url =[NSString stringWithFormat:@"%@%@%d%@", [FuncPublic SharedFuncPublic].rootserver ,@"plan/",self.cpId,@"/join"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setValue:userInfo[@"userId"] forKey:@"userId"];
    [param setValue:userInfo[@"userId"] forKey:@"planId"];
    [param setValue:[NSString stringWithFormat:@"%d", [self.gmjeLabel.text intValue] * 100] forKey:@"money"];
    [param setValue:userInfo[@"token"] forKey:@"token"];
    if (![self.hbMoney.text isEqualToString:@"选择"]) {
        [param setValue:[NSString stringWithFormat:@"%@", pocketID] forKey:@"pocketId"];
    }
    ///用于以后扩展使用
    if (![self.jxq.text isEqualToString:@"选择"]) {
        [param setValue:[NSString stringWithFormat:@"%@", jxqID] forKey:@"raisingId"];
    }
    //现流程不传递
    //[param setValue:@"" forKey:@"tradePassword"];
    if ([_cpData[@"specialPlan"] boolValue]) {//是约标,传约标密码
        [param setValue:result.jymm.text forKey:@"specialPlanPassword"];
    }else {
        // [param setValue:@"" forKey:@"tradePassword"];
    }
    [NetManager requestWithUrlString:url andDic:param finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //[self showHudInView:self.view hint:@"载入中"];
        NSDictionary *r = [FuncPublic dictionaryWithJsonData:responseObject];
        if ([r[@"resultCode"] boolValue]) {
            [self showHint:r[@"resultMsg"] yOffset:-Screen_Height / 4];
        }else {
            
            [self showHint:@"投资成功" yOffset:-Screen_Height / 4];
            [result removeFromSuperview];
            // //刷新剩余可投和账户余额
            int sykt = [self.syktMoney.text intValue];
            // double zhye = [self.zhyeMoney.text doubleValue];
            int gmje = [self.gmjeLabel.text intValue];
            self.syktMoney.text = [NSString stringWithFormat:@"%d", sykt - gmje];
            [self loadData];
            self.hbMoney.text = @"选择";
            [self.navigationController popViewControllerAnimated:true];
            // self.zhyeMoney.text = [NSString stringWithFormat:@"%.2f", zhye - gmje];
            // [self.navigationController popViewControllerAnimated:true];
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
}
- (void)specialTZ {
    NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
    NSString *url =[NSString stringWithFormat:@"%@%@%d%@", [FuncPublic SharedFuncPublic].rootserver ,@"plan/",self.cpId,@"/join"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setValue:userInfo[@"userId"] forKey:@"userId"];
    [param setValue:userInfo[@"userId"] forKey:@"planId"];
    [param setValue:[NSString stringWithFormat:@"%d", [self.gmjeLabel.text intValue] * 100] forKey:@"money"];
    [param setValue:userInfo[@"token"] forKey:@"token"];
    if (![self.hbMoney.text isEqualToString:@"选择"]) {
        [param setValue:[NSString stringWithFormat:@"%ld", (long)self.hbMoney.tag] forKey:@"pocketId"];
    }
    if (![self.jxq.text isEqualToString:@"选择"]) {
        [param setValue:[NSString stringWithFormat:@"%ld", (long)self.jxq.tag] forKey:@"raisingId"];
    }
   
    [param setValue:@"" forKey:@"specialPlanPassword"];
    //现流程不传递
    //[param setValue:@"" forKey:@"tradePassword"];
    [NetManager requestWithUrlString:url andDic:param finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self showHudInView:self.view hint:@"载入中"];
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        if ([result[@"resultCode"] boolValue]) {
            [self showHint:result[@"resultMsg"] yOffset:0];
        }else {
            [self showHint:result[@"resultMsg"] yOffset:0];
            [self.navigationController popViewControllerAnimated:true];
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
}

- (IBAction)qtTouched:(id)sender {
    double zhye = [self.zhyeMoney.text doubleValue];
    double sykt = [self.syktMoney.text doubleValue];
    double max = [self.maxMoney.text doubleValue];
    if (zhye < sykt) {
        if (zhye > max) {
            self.gmjeLabel.text = self.maxMoney.text;
        }else {
            int temp = zhye;
            self.gmjeLabel.text = [NSString stringWithFormat:@"%d",temp];
        }
        
    }else {
        if (sykt > max) {
            self.gmjeLabel.text = self.maxMoney.text;
        }else {
            self.gmjeLabel.text = self.syktMoney.text;
        }
        
    }
    
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}
- (void) loadData {
    // [self showHudInView:self.view hint:@"载入中"];
    NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
    NSString *url =[NSString stringWithFormat:@"%@%@%@%@?token=%@&from=%@&version=%@", [FuncPublic SharedFuncPublic].rootserver ,@"user/",userInfo[@"userId"],@"/accountInfo", userInfo[@"token"], @"iOS", InnerVersion];
    [NetManager GetRequestWithUrlString:url finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        if ([result[@"resultCode"] boolValue]) {
            [self showHint:result[@"resultMsg"] yOffset:0];
        }else {
            //账户余额
            _zhyeMoney.text = [NSString stringWithFormat:@"%.2f", [result[@"resultData"][@"money"] longValue] / 100.0];
            _anotherZhyeMoney.text = _zhyeMoney.text;
            //起投金额
            _minMoney.text = [NSString stringWithFormat:@"%d元", [_cpData[@"minAmount"] intValue] /100];
            //限投金额
            _maxMoney.text = [NSString stringWithFormat:@"%d", [_cpData[@"maxAmount"] intValue] /100];
            //红包
            //  self.hbMoney.text = @"选择";
            //加息券
            // self.jxq.text = @"选择";
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
}
- (void) hideKeyboard:(id)sender {
    [tz.password resignFirstResponder];
    [_gmjeLabel resignFirstResponder];
}
- (IBAction)hidekeyboard:(id)sender {
    [_buyLabel resignFirstResponder];
    [_gmjeLabel resignFirstResponder];
    [result.jymm resignFirstResponder];
}

-(void)getAvailablePoceket:(double)money {
    NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
    NSString *url =[NSString stringWithFormat:@"%@%@/%@%@/%d", [FuncPublic SharedFuncPublic].rootserver ,@"user",userInfo[@"userId"],@"/account/canusevouchers", [_cpData[@"planId"] intValue]];
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setValue:@"iOS" forKey:@"from"];
    [param setValue:InnerVersion forKey:@"version"];
    [param setValue:userInfo[@"token"] forKey:@"token"];
    [param setValue:[NSString stringWithFormat:@"%d", 0] forKey:@"type"];
    [param setValue:[NSString stringWithFormat:@"%d", (int)money * 100] forKey:@"amount"];
    // [param setValue:[NSString stringWithFormat:@"%d", _cycle] forKey:@"cycle"];
  //  [param setValue:[NSString stringWithFormat:@"%d", 1] forKey:@"page"];
  //  [param setValue:[NSString stringWithFormat:@"%d", 1] forKey:@"limit"];
    
    [NetManager GetRequestWithUrlString:url andDic:param finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //  [self showHudInView:self.view hint:@"加载中"];
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        if ([result[@"resultCode"] boolValue]) {
            [self showHint:result[@"resultMsg"] yOffset:0];
        }else {
           NSArray * array = result[@"resultData"];
            if (array.count > 0) {
                self.hbMoney.text =[NSString stringWithFormat:@"%d", [array[0][@"voucherValue"] intValue] / 100];
                pocketID = array[0][@"id"];
                self.hbMoney.tag =(NSInteger) [pocketID intValue];
                self.hbType.hidden = false;
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
            [self showHint:@"请求超时，请检查网络状态。" yOffset:0];
        }
        [self hideHud];
    }];
}
- (IBAction)hbTouched:(id)sender {
    [self hideKeyboard:nil];
    self.hborjxq = @"红包";
    if ([_gmjeLabel.text intValue] == 0) {
        [self showHint:@"请先输入投资金额" yOffset:0];
    }else if([_gmjeLabel.text intValue] < [self.minMoney.text intValue]){
        [self showHint:@"投资金额不能小于起投金额" yOffset:0];
    }else if([_gmjeLabel.text intValue] >  [self.syktMoney.text intValue]){
        [self showHint:@"投资金额不能大于剩余可投金额" yOffset:0];
    }else if([_gmjeLabel.text intValue] > [self.maxMoney.text intValue]){
        [self showHint:@"投资金额不能大于限投金额！" yOffset:0];
    }else {
        ProjectHBTableViewController *hb = [self.storyboard instantiateViewControllerWithIdentifier:@"ProjectHBTableViewController"];
        hb.hborjxq = @"红包";
        hb.delegate = self;
        hb.cycle = [_cpData[@"planId"] intValue];
        hb.type = 0;
        hb.amount = [_gmjeLabel.text doubleValue];
        [self.navigationController pushViewController:hb animated:true];
    }
    
}
- (IBAction)jxqTouched:(id)sender {
    [self hideKeyboard:nil];
     self.hborjxq = @"加息券";
    if ([_gmjeLabel.text intValue] == 0) {
        [self showHint:@"请先输入投资金额" yOffset:0];
    }else if([_gmjeLabel.text intValue] < [self.minMoney.text intValue]){
        [self showHint:@"投资金额不能小于起投金额" yOffset:0];
    }else if([_gmjeLabel.text intValue] >  [self.syktMoney.text intValue]){
        [self showHint:@"投资金额不能大于剩余可投金额" yOffset:0];
    }else if([_gmjeLabel.text intValue] > [self.maxMoney.text intValue]){
        [self showHint:@"投资金额不能大于限投金额！" yOffset:0];
    }else {
        ProjectHBTableViewController *hb = [self.storyboard instantiateViewControllerWithIdentifier:@"ProjectHBTableViewController"];
        hb.hborjxq = @"加息券";
        hb.delegate = self;
        hb.cycle = [_cpData[@"planId"] intValue];
        hb.type = 2;
        hb.amount = [_gmjeLabel.text doubleValue];
        [self.navigationController pushViewController:hb animated:true];
    }
    
}
- (void)viewWillAppear:(BOOL)animated {
     [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self loadData];
}

//选择红包回调
#pragma mark- projecthbdelegate
- (void)ChooseBack:(ProjectHBTableViewController *)controller didFinish:(NSString *)hbMoney andPocketI:(NSString *)pocketid{
    if ([self.hborjxq isEqualToString:@"红包"]) {
        self.hbMoney.text = hbMoney;
        pocketID = pocketid;
        self.hbMoney.tag =(NSInteger) pocketid;
        self.hbType.hidden = false;
    }else {
        self.jxq.text = [NSString stringWithFormat:@"%.1f%%", [hbMoney doubleValue]/10];
        jxqID = pocketid;
        self.jxq.tag = (NSInteger)pocketid;
    }
    
}
#pragma mark -textfield
//实时监控输入
-(void)textChange :(UITextField *)theTextField{
    int money = [theTextField.text intValue];
    if (money >= 100) {
//        self.hbMoney.text = @"选择";
//        self.hbMoney.tag = 0;
//        self.hbType.hidden = true;
//        self.jxq.text = @"选择";
        //判断是否只包含数字和点号
        if([FuncPublic isOnlyhasNumberAndpointWithString:theTextField.text]){
            //实时计算实际提取金额。
            // double money = [theTextField.text doubleValue];
//
//            if(![theTextField.text containsString:@"."]){
//                [self getAvailablePoceket:money];
//            }else {
//
//                NSString *value = self.gmjeLabel.text;
//                self.gmjeLabel.text = [value substringToIndex:value.length-1];
//                [self showHint:@"不能输入小数" yOffset: -Screen_Height / 3];
//            }
            [self getAvailablePoceket:money];
        }else {
            NSString *value = self.gmjeLabel.text;
            self.gmjeLabel.text = [value substringToIndex:value.length-1];
            [self showHint:@"只能输入数字" yOffset: -Screen_Height / 2];
        }
    }else {
        self.hbMoney.text = @"选择";
        self.hbMoney.tag = 0;
        self.hbType.hidden = true;
        self.jxq.text = @"选择";
    }
    
    
    
}
#pragma mark-uitextfield delegate 实现上移视图，防止键盘遮挡。
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    //假如多个输入，比如注册和登录，就可以根据不同的输入框来上移不同的位置，从而更加人性化
    //键盘高度216
    //滑动效果（动画）
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@ "ResizeForKeyboard"  context:nil];
    [UIView setAnimationDuration:animationDuration];
    //将视图的Y坐标向上移动，以使下面腾出地方用于软键盘的显示
    self.view.frame = CGRectMake(0.0f, -80.0f/*屏幕上移的高度，可以自己定*/, self.view.frame.size.width, self.view.frame.size.height);
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
