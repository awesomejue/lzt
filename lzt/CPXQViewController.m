//
//  CPXQViewController.m
//  lzt
//
//  Created by hwq on 2017/11/17.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "CPXQViewController.h"
#import "SZJYMMViewController.h"
#import "CalculaterView.h"
#import "htmlViewController.h"
#import "UIButton+CornerRadium.h"
#import "DBViewController.h"
#import "HUPhotoBrowser.h"
#import "TZViewController.h"
#import "NavigationController.h"
#import "NetManager.h"
#import "XGZLViewController.h"
#import "LoginViewController.h"
#import "SMRZViewController.h"
#import "XQViewController.h"
#import "TZJLViewController.h"
#import "LoginRegisterViewController.h"

@interface CPXQViewController ()
{
    CalculaterView *cal;
    NSDictionary *data; //保存数据
}
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *ljgmBtn;
@property (weak, nonatomic) IBOutlet UIView *parentVIEW;
@property (weak, nonatomic) IBOutlet UILabel *rate;
@property (weak, nonatomic) IBOutlet UILabel *type;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *allmoney;
@property (weak, nonatomic) IBOutlet UILabel *minMoney;
@property (weak, nonatomic) IBOutlet UILabel *cpxqLeftMoney;
@property (weak, nonatomic) IBOutlet UILabel *jxtime;
@property (weak, nonatomic) IBOutlet UILabel *hktime;
@property (weak, nonatomic) IBOutlet UILabel *hkType;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *tzjlCount;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *DBHeight;
@property (weak, nonatomic) IBOutlet UILabel *dblabel;
@property (weak, nonatomic) IBOutlet UIImageView *dbimageview;

@property (nonatomic, assign) BOOL hasCardId;//是否实名
@property (nonatomic, assign) BOOL hasTradePassword;//是否设置交易密码

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *xkHeight;
@property (weak, nonatomic) IBOutlet UILabel *jxfs;
@property (weak, nonatomic) IBOutlet UILabel *xkgzlabel;
@property (weak, nonatomic) IBOutlet UILabel *xkgzlable2;

@property (weak, nonatomic) IBOutlet UILabel *hkfs;
@property(nonatomic, strong)NSMutableArray *projectDes;
@property(nonatomic, strong)NSMutableArray *anotherProjextDes;

@end

@implementation CPXQViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    [self setTitle:@"产品详情"];
    _projectDes = [[NSMutableArray alloc]init];
    _anotherProjextDes = [[NSMutableArray alloc]init];
    [_projectDes addObjectsFromArray: @[@"即投计息",@"项目到期后按约当天到达账户",@"一次性还本付息"]];
    [_anotherProjextDes addObjectsFromArray: @[@"即投计息",@"项目到期后按约当天到达账户",@"一次性还本付息"]];
    
   // [self createUI];
    [self showHudInView:self.view hint:@"载入中"];
    if (iPhoneX) {
        _NavHeight.constant += 20;
    }
    
    [self hideHud];
    [self tableHeaderDidTriggerRefresh];
    [self hideBackButtonText];
}
- (void)createUI {
    //设置阴影
    _bgView.layer.shadowColor = [UIColor colorWithRed:242.0 / 255 green:231/ 255 blue:231/ 255 alpha:1].CGColor;//设置阴影的颜色
    _bgView.layer.shadowOpacity = 0.1;//设置阴影的透明度
    _bgView.layer.shadowOffset = CGSizeMake(0, 5);//设置阴影的偏移量
    [_ljgmBtn setCornerRadium];//设置圆角
    //产融宝隐藏第三方担保
    if ([data[@"type"] intValue] == 2) {
        _DBHeight.constant = 0;
        _dblabel.text = @"";
        _dbimageview.image = [UIImage imageNamed:@""];
    }
    
    //添加数据
    _name.text = data[@"name"];
    double rate = [data[@"rate"] doubleValue]+ [data[@"rasingRate"] doubleValue] ;
    _rate.text =[NSString stringWithFormat:@"%.1f", rate/10];
    _time.text =[NSString stringWithFormat:@"%@%@", data[@"staging"], [FuncPublic getDate:data[@"stagingUnit"]]];
    int count = [data[@"amount"] doubleValue] - [data[@"nowSum"] doubleValue] ;
    _cpxqLeftMoney.text = [NSString stringWithFormat:@"%d元", count / 100];
    _minMoney.text = [NSString stringWithFormat:@"%.0f", [data[@"minAmount"] doubleValue] /100];
    //_jxtime.text = [FuncPublic getTime:data[@"purchaseTime"]];
    _allmoney.text = [NSString stringWithFormat:@"%.0f", [data[@"amount"] doubleValue] /100];
    //还款时间
    //NSDateFormatter *inputFormatter= [[NSDateFormatter alloc] init];
    //[inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    //[inputFormatter setDateFormat:@"yyyyMMddHHmmss"];
   // NSDate *inputDate = [inputFormatter dateFromString:data[@"purchaseTime"]];
   // NSDate *endDate = [inputDate dateByAddingTimeInterval:24 * 60 * 60  * [data[@"staging"] intValue]];
    //[inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //NSString *end = [inputFormatter stringFromDate:endDate];
    //_hktime.text = end;
   // _hkType.text = data[@"repayInfo"];
    //标类型:写死不利于以后扩展
    switch ([data[@"type"] intValue]) {
        case 0:
           // _type.text = @"投标宝";
            _type.text = data[@"typeName"];
            break;
        case 1:
           // _type.text = @"新客专享";
            _type.text = data[@"typeName"];
            break;
        case 2:
           // _type.text = @"产融宝";
            _type.text = data[@"typeName"];
            break;
        default:
            break;
    }
    //判断标类型
    if ([data[@"state"] intValue] == 0) {
        [_ljgmBtn setTitle:@"立即购买" forState: UIControlStateNormal];
    }else if([data[@"state"] intValue] == 1) {
         [_ljgmBtn setTitle:@"还款中" forState: UIControlStateNormal];
        [_ljgmBtn setBackgroundColor:[UIColor colorWithRed:231.0/155 green:231.0/255 blue:231.0/255 alpha:1]];
        _ljgmBtn.enabled = false;
    }else if([data[@"state"] intValue] == 2) {
        [_ljgmBtn setTitle:@"已还款" forState: UIControlStateNormal];
        [_ljgmBtn setBackgroundColor:[UIColor colorWithRed:231.0/155 green:231.0/255 blue:231.0/255 alpha:1]];
        _ljgmBtn.enabled = false;
    }else if([data[@"state"] intValue] == 3) {
        [_ljgmBtn setTitle:@"预售" forState: UIControlStateNormal];
       // [_ljgmBtn setBackgroundColor:[UIColor colorWithRed:231.0/155 green:231.0/255 blue:231.0/255 alpha:1]];
        //_ljgmBtn.enabled = false;
    }
    
}

- (void)hideBackButtonText{
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:nil];
}
- (IBAction)hlxsTouched:(id)sender {
    
    
}
- (IBAction)zyfkTouched:(id)sender {
}
- (IBAction)ytdzTouched:(id)sender {
}

- (void)loadData {
    //载入数据
    NSString *url =[NSString stringWithFormat:@"%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"plan/"];
    url = [NSString stringWithFormat:@"%@%d?from=%@&version=%@", url,_cpId, @"iOS", InnerVersion];
    [NetManager GetRequestWithUrlString:url  finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        if ([result[@"resultCode"] boolValue]) {
            [self showHint:result[@"resultMsg"] yOffset:0];
        }else {
            data = result[@"resultData"];
            [self createUI];
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
- (IBAction)dbTouched:(id)sender {
    DBViewController *db = [self.storyboard instantiateViewControllerWithIdentifier:@"DBViewController"];
    db.content = data[@"guaranteeInfo"];
    db.flagid = [data[@"planId"] intValue];
    [self.navigationController pushViewController:db animated:true];
}
- (void)loadTZJL {
    //载入数据
    NSString *url =[NSString stringWithFormat:@"%@%@%d%@", [FuncPublic SharedFuncPublic].rootserver ,@"plan/",self.cpId,@"/investments"];
    url = [NSString stringWithFormat:@"%@?from=%@&version=%@&page=1&limit=1", url, @"iOS", InnerVersion];
    [NetManager GetRequestWithUrlString:url finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        if ([result[@"resultCode"] boolValue]) {
            [self showHint:result[@"resultMsg"] yOffset:0];
        }else {
            NSArray *arr = result[@"resultData"];
            if (arr.count == 0) {
                self.tzjlCount.text = [NSString stringWithFormat:@"0个"];
            }else {
                //NSDictionary *data = arr[0];
                self.tzjlCount.text = [NSString stringWithFormat:@"%@个", result[@"sumCount"]];
            }
            
            //data = result[@"resultData"];
            //[self createUI];
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
- (IBAction)cpsmTouched:(id)sender {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"HTML" bundle:nil];
    htmlViewController *detail = [s instantiateViewControllerWithIdentifier:@"htmlViewController"];
   // detail.nid = [_dataSource[indexPath.row][@"id"] intValue];
    //标类型:写死不利于以后扩展
    switch ([data[@"type"] intValue]) {
        case 0:
            //_type.text = @"投标宝";
            detail.nid = [data[@"planId"] intValue];
            detail.type = 0;
            break;
        case 1:
           // _type.text = @"新客专享";
            detail.nid = [data[@"planId"] intValue];
            detail.type = 1;
            break;
        case 2:
           // _type.text = @"产融宝";
            detail.nid = [data[@"planId"] intValue];
            detail.type = 2;
            break;
        default:
            break;
    }
    detail.name = @"产品说明";
    [self.navigationController pushViewController:detail animated:true];
}


- (void)loadUserInfo{
   
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
            _hasCardId = [dic[@"hasCardId"] boolValue];
            _hasTradePassword = [dic[@"hasTradePassword"] intValue];
            
            NSMutableDictionary *user = [[NSMutableDictionary alloc]init];
            NSDictionary *u = [FuncPublic GetDefaultInfo:mUserInfo];
            [user setDictionary:u];
            [user setValue:[NSString stringWithFormat:@"%d", [dic[@"hasCardId"] intValue]] forKey:@"hasCardId"];
            [user setValue:[NSString stringWithFormat:@"%d", [dic[@"hasTradePassword"] intValue]]  forKey:@"hasTradePassword"];
            [FuncPublic SaveDefaultInfo:user Key:mUserInfo];
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
- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    if (self.xktype != 1) {
        _xkgzlabel.text = @"";
        _xkgzlable2.text = @"";
        _xkHeight.constant = 0;
    }
    //判断标类型
    if (self.cpState == 0) {
        [_ljgmBtn setTitle:@"立即购买" forState: UIControlStateNormal];
    }else if(self.cpState == 1) {
        [_ljgmBtn setTitle:@"还款中" forState: UIControlStateNormal];
        [_ljgmBtn setBackgroundColor:[UIColor colorWithRed:231.0/155 green:231.0/255 blue:231.0/255 alpha:1]];
        _ljgmBtn.enabled = false;
    }else if(self.cpState == 2) {
        [_ljgmBtn setTitle:@"已还款" forState: UIControlStateNormal];
        [_ljgmBtn setBackgroundColor:[UIColor colorWithRed:231.0/155 green:231.0/255 blue:231.0/255 alpha:1]];
        _ljgmBtn.enabled = false;
    }else if(self.cpState == 3) {
        [_ljgmBtn setTitle:@"预售" forState: UIControlStateNormal];
        // [_ljgmBtn setBackgroundColor:[UIColor colorWithRed:231.0/155 green:231.0/255 blue:231.0/255 alpha:1]];
        //_ljgmBtn.enabled = false;
    }
    
    //注册通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(Tip:) name:@"fromRegister" object:nil];
    //   [self showHudInView:self.view hint:@"载入中"];
    [self loadData];
    //    if ([[FuncPublic GetDefaultInfo:userIsLogin] boolValue]) {
    //        [self loadUserInfo];
    //    }
}
- (void)viewWillDisappear:(BOOL)animated {
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
  //  [[NSNotificationCenter defaultCenter] postNotificationName:@"tabBarAppear" object:nil];
}
- (IBAction)tzjlTouched:(id)sender {
    TZJLViewController *tzjl = [self.storyboard instantiateViewControllerWithIdentifier:@"TZJLViewController"];
    tzjl.cpId = self.cpId;
    [self.navigationController pushViewController:tzjl animated:true];
}

- (IBAction)xmxqTouched:(id)sender {
    XQViewController *xq = [self.storyboard instantiateViewControllerWithIdentifier:@"XQViewController"];
   // NSMutableArray *array = [[NSMutableArray alloc]init];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:@"借款人信息" forKey:@"name"];
    [dic setValue:data[@"userInfo"] forKey:@"userInfo"];
    //[array addObject:dic];
    //NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:@"产品说明" forKey:@"name"];
    [dic setValue:data[@"description"] forKey:@"description"];

    [dic setValue:@"借款详情" forKey:@"name"];
    [dic setValue:data[@"used"] forKey:@"used"];
    
    [dic setValue:@"还款措施" forKey:@"name"];
    [dic setValue:data[@"repayInfo"] forKey:@"repayInfo"];
   
    [dic setValue:@"安全保障" forKey:@"name"];
    [dic setValue:data[@"risk"] forKey:@"risk"];
   
    xq.dataSource = dic;
    //[xq.dataSource addObjectsFromArray:array];
    [self.navigationController pushViewController:xq animated:true];
}
- (IBAction)calculaterTouched:(id)sender {
    
    [self animiationAddSubView];
    
}
//动画效果添加子视图
- (void) animiationAddSubView {
    //载入xib方法。
    cal = [[[NSBundle mainBundle] loadNibNamed:@"Calculater" owner:self options:nil] lastObject];
    cal.calView.layer.cornerRadius = 5;
    cal.calView.layer.masksToBounds = true;
    [cal.calBtn setCornerRadium];
    [cal.calBtn addTarget:self action:@selector(calyqMoney) forControlEvents:UIControlEventTouchUpInside];
    cal.frame = CGRectMake(0,  0, Screen_Width , Screen_Height);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(remove)];
    [cal addGestureRecognizer:tap];
    cal.date.text = [NSString stringWithFormat:@"%@", data[@"staging"]];
    cal.typeDate.text =  [FuncPublic getDate:data[@"stagingUnit"]];
    [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self.view addSubview:cal];
        [self.view bringSubviewToFront:cal];
    }completion:^(BOOL finished){
        NSLog(@"动画结束");
    }];
    
//    [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
//                [self.view addSubview:cal];
//                [self.view bringSubviewToFront:cal];
//            }completion:^(BOOL finished){
//                NSLog(@"动画结束");
//            }];
}
- (void)remove {
    [cal removeFromSuperview];
}

- (void) hidekeyboard:(id)sender {
    [cal.money resignFirstResponder];
}

- (void)calyqMoney {
    //按照计算
    NSString *str = cal.typeDate.text;
    int date = [cal.date.text intValue];
    if ([str isEqualToString:@"天"]) {
        double money = [cal.money.text doubleValue];
        double rate = ([data[@"rate"] doubleValue]+ [data[@"rasingRate"] doubleValue])/1000;
        double result = money * (rate /360)*date;
        cal.yqMoney.text = [NSString stringWithFormat:@"%.2f", result ];
    }else if ([str isEqualToString:@"个月"]) {
        double money = [cal.money.text doubleValue];
        double rate = ([data[@"rate"] doubleValue]+ [data[@"rasingRate"] doubleValue])/1000;
        
        double result = money * (rate /12)*date;
        cal.yqMoney.text = [NSString stringWithFormat:@"%.2f", (double)result];
    }
    
}

- (IBAction)xgzlTouched:(id)sender {
    
    XGZLViewController *xgzl = [self.storyboard instantiateViewControllerWithIdentifier:@"XGZLViewController"];
    xgzl.dataSource = data[@"images"];
    [self.navigationController pushViewController:xgzl animated:true];

}

- (void) Tip:(NSNotification *)notification{
    //NSDictionary * infoDic = [notification object];
    // 这样就得到了我们在发送通知时候传入的字典了
    // if (![infoDic[@"smrz"] boolValue]) {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请前往实名认证" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIStoryboard *s = [UIStoryboard storyboardWithName:@"SMRZ" bundle:nil];
        SMRZViewController *smrz = [s instantiateViewControllerWithIdentifier:@"SMRZViewController"];
        [self.navigationController pushViewController:smrz animated:true];
    }];
    
    [ok setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"先逛逛" style:UIAlertActionStyleDefault handler:nil];
    [cancel setValue:[UIColor lightGrayColor] forKey:@"_titleTextColor"];
    [alert addAction:cancel];
    [alert addAction:ok];
    [self presentViewController:alert animated:true completion:nil];
    // }
}
- (IBAction)ljtzClicked:(id)sender {
    
    //用户没有登陆
    if (![[FuncPublic GetDefaultInfo:userIsLogin] boolValue]) {
        [self showHint:@"请先登录" yOffset:0];
        UIStoryboard *s =[UIStoryboard storyboardWithName:@"Login" bundle:nil];
        LoginRegisterViewController *login = [s instantiateViewControllerWithIdentifier:@"LoginRegisterViewController"];
        login.isCPXQ = 1;
        //login.isChildViewController = false;
        // login.isAppDelegate =false; //这种时候需要直接dimiss控制器，不需要跳转到首页
        NavigationController *nav = [[NavigationController alloc]initWithRootViewController:login];
        [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [self presentViewController:nav animated:false completion:nil];
        }completion:^(BOOL finished){
            NSLog(@"动画结束");
        }];
        //        UIStoryboard *s =[UIStoryboard storyboardWithName:@"Login" bundle:nil];
        //        LoginViewController *login = [s instantiateViewControllerWithIdentifier:@"LoginViewController"];
        //        login.isChildViewController = false;
        //        // login.isAppDelegate =false; //这种时候需要直接dimiss控制器，不需要跳转到首页
        //        NavigationController *nav = [[NavigationController alloc]initWithRootViewController:login];
        //        [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        //            [self presentViewController:nav animated:false completion:nil];
        //        }completion:^(BOOL finished){
        //            NSLog(@"动画结束");
        //        }];
        
    }else {
        [self showHudInView:self.view hint:@"加载中"];
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
                _hasCardId = [dic[@"hasCardId"] boolValue];
                _hasTradePassword = [dic[@"hasTradePassword"] boolValue];
                NSMutableDictionary *user = [[NSMutableDictionary alloc]init];
                NSDictionary *u = [FuncPublic GetDefaultInfo:mUserInfo];
                [user setDictionary:u];
                [user setValue:[NSString stringWithFormat:@"%d", [dic[@"hasCardId"] intValue]] forKey:@"hasCardId"];
                [user setValue:[NSString stringWithFormat:@"%d", [dic[@"hasTradePassword"] intValue]]  forKey:@"hasTradePassword"];
                [FuncPublic SaveDefaultInfo:user Key:mUserInfo];
                if (!_hasCardId) {//没有实名
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"您还没有实名认证，去认证" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
                        UIStoryboard * s = [UIStoryboard storyboardWithName:@"SMRZ" bundle:nil];
                        SMRZViewController  *SMRZ = [s instantiateViewControllerWithIdentifier:@"SMRZViewController"];
                        [self.navigationController pushViewController:SMRZ animated:true];
                    }];
                    [ok setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
                    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"先逛逛" style:UIAlertActionStyleDefault handler:nil];
                    [cancel setValue:[UIColor lightGrayColor] forKey:@"_titleTextColor"];
                    [alert addAction:cancel];
                    [alert addAction:ok];
                    [self presentViewController:alert animated:true completion:nil];
                }else {
                    if (!_hasTradePassword) {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"您还未设置交易密码，去设置" preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            
                            //   [self showHint:@"您还未设置交易密码，请先设置交易密码" yOffset:0];
                            UIStoryboard *s = [UIStoryboard storyboardWithName:@"MMGL" bundle:nil];
                            SZJYMMViewController *cz = [s instantiateViewControllerWithIdentifier:@"SZJYMMViewController"];
                            cz.name = @"交易密码设置";
                            //cz.isSMRZ = true;
                            [self.navigationController pushViewController:cz animated:true];
                        }];
                        [ok setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
                        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"先逛逛" style:UIAlertActionStyleDefault handler:nil];
                        [cancel setValue:[UIColor lightGrayColor] forKey:@"_titleTextColor"];
                        [alert addAction:cancel];
                        [alert addAction:ok];
                        [self presentViewController:alert animated:true completion:nil];
                    }else {
                        UIStoryboard *s = [UIStoryboard storyboardWithName:@"TZ" bundle:nil];
                        TZViewController *tz = [s instantiateViewControllerWithIdentifier:@"TZViewController"];
                        tz.cpData = data;
                        tz.cpId = self.cpId;
                        [self.navigationController pushViewController:tz animated:true];
                    }
                    
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
}
//下拉刷新
- (void)tableHeaderDidTriggerRefresh {
     self.navigationController.navigationBar.translucent = false;
#ifdef __IPHONE_11_0
    if ([self.scrollView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
        if (@available(iOS 11.0, *)) {
            self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
        }
    }
#endif
    self.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadData];
        [self.scrollView.mj_header endRefreshing];
    }];
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
