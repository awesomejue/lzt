//
//  HomePageViewController.m
//  lzt
//
//  Created by 黄伟强 on 2017/10/17.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "HomePageViewController.h"
#import <AdSupport/AdSupport.h>
#import "AdView.h"
#import "ZXViewController.h"
#import "FggViewController.h"
#import "CPXQViewController.h"
#import "XBTextLoopView.h"
#import "NewsCell.h"
#import "NewsTableViewController.h"
#import "LeadPageView.h"
#import "NewsDetailViewController.h"
#import "HWCircleView.h"
#import "htmlViewController.h"

#import "BannerViewController.h"
#import "NetManager.h"
#import "UIImageView+WebCache.h"
#import "HDViewController.h"
#import "HKTip.h"
#import "NavigationController.h"
#import "MyTabbarController.h"
#import "HWWaveView.h"
#import "CountDownView.h"

@interface HomePageViewController () <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIAlertViewDelegate>
{
    NSMutableArray *XBTextLoopDatas; //滚动公告数据
    NSMutableArray *NewsDatas; //新闻列表数据
    NSMutableArray *HotDatas;//热销排行榜
    NSDictionary *GoodDatas; //推荐项目数据
    NSMutableArray *AdData;//banner数据
    //热销排行已投资比例
    double hotFirstCount;
    double hotSecondCount;
    double goodCount;//推荐项目已投资比例
    double increment; //控制圆圈进度常量
   // int goodRate;//年化率
    
    HKTip *hktip;
    NSString *XTString;
}

@property (nonatomic, strong) NSTimer *Centertimer;
@property (nonatomic, strong) NSTimer *Hot1timer;
@property (nonatomic, strong) NSTimer *Hot2timer;
@property (weak, nonatomic) IBOutlet UIView *moreNews;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *adView;
@property (weak, nonatomic) IBOutlet UIView *textLoopView;
@property (weak, nonatomic) IBOutlet UITableView *newsTableView;
@property (weak, nonatomic) IBOutlet UIView *hotTZView1;
@property (weak, nonatomic) IBOutlet UIView *hotTZView2;
@property (weak, nonatomic) IBOutlet UIButton *ljqgBtn;

@property (weak, nonatomic) IBOutlet UILabel *hotFirstName;
@property (weak, nonatomic) IBOutlet UILabel *hotdate;
@property (weak, nonatomic) IBOutlet UILabel *hotFirstRate;
@property (weak, nonatomic) IBOutlet UILabel *hotSecondName;
@property (weak, nonatomic) IBOutlet UILabel *hotSecondRate;
@property (weak, nonatomic) IBOutlet UILabel *hotSecondDate;
@property (weak, nonatomic) IBOutlet HWCircleView *hotFirstCircle;
@property (weak, nonatomic) IBOutlet HWCircleView *hotSecondCircle;
//@property (weak, nonatomic) IBOutlet CenterCircleView *centerCircle;
@property (weak, nonatomic) IBOutlet UILabel *goodProjName; //推荐项目名
@property (weak, nonatomic) IBOutlet UILabel *minMoney;//起投金额
@property (weak, nonatomic) IBOutlet UILabel *limitTime;//投资期限
@property (weak, nonatomic) IBOutlet HWWaveView *centerCircle;

@property (weak, nonatomic) IBOutlet UILabel *goodRate;
@property (weak, nonatomic) IBOutlet UILabel *yqnhsyLabel;


@property (nonatomic, strong) UIView *whiteView;
@end

@implementation HomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _whiteView = [[UIView alloc]initWithFrame:self.view.frame];
    _whiteView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_whiteView];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removewWhiteView) name:@"removewWhiteView" object:nil];
    
    
    if (@available(iOS 11.0, *)) {
        // self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        _scrollView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
    }
    //self.scrollView.mj_header.ignoredScrollViewContentInsetTop = 20;
    //判断网络状态
    [NetManager NetworkStatus:^(AFNetworkReachabilityStatus status) {
        //这里是监测到网络改变的block  可以写成switch方便
        //在里面可以随便写事件
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
               // [self showHint:@"未知网络，请检查网络连接。" yOffset:0];
               
                    [self showHint:@"网络连接失败，请检查网络状态。" yOffset:0];

                break;
            case AFNetworkReachabilityStatusNotReachable:
              //  [self showHint:@"没有网络，请检查网络连接。" yOffset:0];
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                //[WToast showWithText: @"蜂窝数据网"];
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                // WKNSLog(@"WiFi网络");
                
                break;
            default:
                break;
        }
    }];
    if (![FuncPublic GetDefaultInfo:mFirstLaunch]) {
        NewsDatas = [[NSMutableArray alloc]init];
       // [[NSNotificationCenter defaultCenter] postNotificationName:@"tabBarHidden" object:nil];
        [self initHKTip];
        //[self addLeadPage];
        [self toutiao];
      // [self showHudInView:self.view hint:@"载入中"];
        //[[FuncPublic SharedFuncPublic]StartActivityAnimation:self];
        [self tableHeaderDidTriggerRefresh];
        [self createAdScrollView];
        [self createXBTextLoopView];//创建文字循环视图
        [self createGoodProject];
        [self createHotTZView];
        [self createNewsTableView];
        [self loadNewsData];
        [self hideBackButtonText];
        [self checkVersion];
        
    }else {
        NewsDatas = [[NSMutableArray alloc]init];
        [self initHKTip];
        [self tableHeaderDidTriggerRefresh];
        [self createAdScrollView];
        [self createXBTextLoopView];//创建文字循环视图
        [self createGoodProject];
        [self createHotTZView];
        [self createNewsTableView];
        [self loadNewsData];
        [self hideBackButtonText];
        [self checkVersion];
    }
    
}

- (void)remove {
    hktip.frame = CGRectMake(0, -Screen_Height, Screen_Width, Screen_Height);
}
- (void)initHKTip{
    //载入xib方法。
    hktip = [[[NSBundle mainBundle] loadNibNamed:@"HKTipView" owner:self options:nil] lastObject];
    hktip.bg.layer.cornerRadius = 5;
    hktip.bg.layer.masksToBounds = true;
    //hktip.center = self.view.center;
    hktip.frame = CGRectMake(0, -Screen_Height, Screen_Width, Screen_Height);
    // [rankView.calBtn setCornerRadium];
    
    [hktip.btn addTarget:self action:@selector(checkXT) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(remove)];
    [hktip.close addGestureRecognizer:tap];
    //    NavigationController *nav =   (NavigationController *) [UIApplication sharedApplication].keyWindow.rootViewController ;
    //    MyTabbarController *tab =  nav.viewControllers[0];
    //UIWindow *w = [UIApplication sharedApplication].keyWindow;
    [self.view addSubview:hktip];
    [self.view bringSubviewToFront:hktip];
    
}
- (void)checkXT {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"HTML" bundle:nil];
    htmlViewController *detail = [s instantiateViewControllerWithIdentifier:@"htmlViewController"];
   // detail.nid = [NewsDatas[indexPath.row][@"id"] intValue];
    detail.name = @"查看续投";
    detail.hkurl = XTString;
    [self.navigationController pushViewController:detail animated:true];
}

- (void)checkVersion {
    //每天进行一次更新判断
    if(![self judgeNeedVersionUpdate]){
        [self hktip];
        
    }else{
        NSString *url = @"http://itunes.apple.com/lookup?id=1361945824";//app id
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager POST:url parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //appstore版本
            NSDictionary *resultDic = (NSDictionary *)responseObject;
            if ([resultDic[@"results"] count] > 0) {
                NSString* version =[[[resultDic objectForKey:@"results"] objectAtIndex:0] valueForKey:@"version"];
                //本地应用版本号
                NSDictionary *infoDic=[[NSBundle mainBundle] infoDictionary];
                NSString* currentVersion = [infoDic valueForKey:@"CFBundleShortVersionString"] ;
                if(![version isEqualToString: currentVersion]){
                    
                    [FuncPublic SaveDefaultInfo:@"1" Key:isCheckVersion];
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"有新的版本可以更新" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
                        NSString *str = @"https://itunes.apple.com/us/app/来浙投理财/id1361945824?l=zh&ls=1&mt=8";
                        NSURL *safariURL = [NSURL URLWithString:[str stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]]];
                        [[UIApplication sharedApplication] openURL:safariURL];
                        
                    }];
                    [ok setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
                    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
                    [cancel setValue:[UIColor lightGrayColor] forKey:@"_titleTextColor"];
                    [alert addAction:cancel];
                    [alert addAction:ok];
                    [self presentViewController:alert animated:true completion:nil];
                }else{
                    //NSLog(@"无需版本更新");
                    [self hktip];
                }
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@", error);
            
        }];
    }
}
//每天进行一次版本判断
- (BOOL)judgeNeedVersionUpdate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    //获取年-月-日
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    NSString *currentDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentDate"];
    if ([currentDate isEqualToString:dateString]) {
        return NO;
    }
    [[NSUserDefaults standardUserDefaults] setObject:dateString forKey:@"currentDate"];
    return YES;
}
- (void)hktip {
    
    NSString *url;
    if ([[FuncPublic GetDefaultInfo:userIsLogin] boolValue]) {
        NSDictionary *user = [FuncPublic GetDefaultInfo:mUserInfo];
    
        url = [NSString stringWithFormat:@"%@%@%@%@?token=%@",[FuncPublic SharedFuncPublic].rootserver, @"user/",user[@"userId"],@"/repays/today",user[@"token"]  ];
        //NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
        //[param setValue:user[@"token"] forKey:@"token"];
        
        [NetManager GetRequestWithUrlString:url  finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self showHudInView:self.view hint:@"载入中"];
            NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
            int b = [result[@"resultCode"] intValue];
            if (b == 1) {
                [self showHint:result[@"resultMsg"] yOffset:0];
            }else if(b == 2){//token失效
                [self showHint:result[@"resultMsg"] yOffset:0];
                [FuncPublic SaveDefaultInfo:@"0" Key:userIsLogin];
                [FuncPublic SaveDefaultInfo:@"" Key:mSaveAccount];
                [FuncPublic SaveDefaultInfo:@"" Key:mUserInfo];

                
            }else{
                NSDictionary *dic = result[@"resultData"];
                if ([dic[@"show"] boolValue]) {
                    XTString = dic[@"url"];
                    [self apearHKTip];
                }
            }
            [self hideHud];
        } failed:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@", error);
           // [self apearHKTip];
            if(error.code == -1009){
                [self showHint:@"网络连接失败，请检查网络状态。" yOffset:0];
            }else if(error.code == -1004){
                [self showHint:@"服务器开了个小差。" yOffset:0];
            }else if(error.code == -1001){
                [self showHint:@"请求超时，请检查网络状态。" yOffset:0];
            }
            [self hideHud];
        }];
    }else{
        
    }
    
}

- (void)createAdScrollView {
   // [self showHudInView:self.view hint:@"载入中"];
    AdData = [[NSMutableArray alloc]init];
  //   self.automaticallyAdjustsScrollViewInsets = NO;//保证scrollview顶部不会预留
   // NSArray *imageURL = @[@"app-邀请.png",@"app约标.png",@"app-续投.png",@"app-安全保障.png"];
    //载入公告数据
    
    NSString *url =[NSString stringWithFormat:@"%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"banner/list"];
    url = [NSString stringWithFormat:@"%@?type=%@&from=%@&version=%@", url,@"index_mobile", @"iOS", InnerVersion];
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
            
            
        }else {
            AdData = result[@"resultData"];
            NSMutableArray *imageURL = [[NSMutableArray alloc]init];
            for (NSDictionary *d in AdData) {
                [imageURL addObject:d[@"picture"]];
            }
            AdView *aView = [AdView adScrollViewWithFrame: CGRectMake(self.adView.frame.origin.x
                                                                    ,self.adView.frame.origin.y, self.adView.frame.size.width, self.adView.frame.size.height) imageLinkURL:imageURL placeHoderImageName:@"news.jpg" pageControlShowStyle:UIPageControlShowStyleCenter];
            //图片被点击后回调的方法
            __weak HomePageViewController *weakself = self;
            aView.callBack = ^(NSInteger index,NSString * imageURL)
            {
                NSString *url = AdData[index][@"url"];
                if (url.length == 0 || [url isEqualToString:@"#"]) {
                    
                }else {
                    
                    //NSLog(@"被点中图片的索引:%ld---地址:%@",index,imageURL);
                    BannerViewController *banner = [self.storyboard instantiateViewControllerWithIdentifier:@"BannerViewController"];
                   // BannerViewController *banner = [[BannerViewController alloc]init];
                    banner.data = AdData[(index)];
                    
                    [weakself.navigationController pushViewController:banner animated:YES];
                }
            };
            [self.adView addSubview:aView];
            
           // [self createXBTextLoopView];//创建文字循环视图
            
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
- (void)apearHKTip{
    [UIView animateWithDuration:0.5 animations:^{
        hktip.frame = CGRectMake(0, 0, Screen_Width, Screen_Height);
    }];
}
- (void)createXBTextLoopView {
    XBTextLoopDatas = [[NSMutableArray alloc]init];
    //载入公告数据
    NSString *url =[NSString stringWithFormat:@"%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"notice/list?"];
    url = [NSString stringWithFormat:@"%@page=1&limit=3&from=%@&version=%@", url, @"iOS", InnerVersion];
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
            
            
        }else {
            XBTextLoopDatas = result[@"resultData"];
            NSMutableArray *temp = [[NSMutableArray alloc]init];
            for (int i =0 ; i < XBTextLoopDatas.count; i++) {
                [temp addObject:XBTextLoopDatas[i][@"title"]];
            }
            XBTextLoopView *loopView = [XBTextLoopView textLoopViewWith:temp loopInterval:3.0 initWithFrame:CGRectMake(Screen_Width * 0.12, 0, Screen_Width * 0.65, Screen_Height * 0.05) selectBlock:^(NSString *selectString, NSInteger index) {
                //NSLog(@"%@===index%ld", selectString, index);
            }];
            [self.textLoopView addSubview:loopView];
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
//载入优质项目
- (void)createGoodProject {
    increment = 0.05;
    GoodDatas = [[NSDictionary alloc]init];
    //载入新手标
    NSString *url =[NSString stringWithFormat:@"%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"plans"];
    //url = [NSString stringWithFormat:@"%@?page=%d&limit=%d&from=%@&version=%@", url,page, row, @"iOS", InnerVersion];
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setValue:@"1" forKey:@"page"];
    [param setValue:@"1" forKey:@"limit"];
    [param setValue:@"iOS" forKey:@"from"];
    [param setValue:InnerVersion forKey:@"version"];
    [param setValue:@"1" forKey:@"type"];
    
    [NetManager GetRequestWithUrlString:url andDic:param finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //[self showHudInView:self.view hint:@"载入中"];
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        int b = [result[@"resultCode"] intValue];
        if (b == 1) {
            [self showHint:result[@"resultMsg"] yOffset:0];
        }else if(b == 2){//token失效
            [self showHint:result[@"resultMsg"] yOffset:0];
            [FuncPublic SaveDefaultInfo:@"0" Key:userIsLogin];
            [FuncPublic SaveDefaultInfo:@"" Key:mSaveAccount];
            [FuncPublic SaveDefaultInfo:@"" Key:mUserInfo];
            
            
        }else {
            NSArray *arr = result[@"resultData"];
            if (arr.count > 0) {
                GoodDatas =arr[0];
                self.goodProjName.text = GoodDatas[@"name"];
                self.limitTime.text = [NSString stringWithFormat:@"%@%@", GoodDatas[@"staging"],[FuncPublic getDate: GoodDatas[@"stagingUnit"]]];
                self.minMoney.text = [NSString stringWithFormat:@"%d元", ([GoodDatas[@"minAmount"] intValue]/100)];
                double value1 = [GoodDatas[@"nowSum"] doubleValue];
                double value2 = [GoodDatas[@"amount"] doubleValue];
                int rate = [GoodDatas[@"rate"] intValue]+ [GoodDatas[@"rasingRate"] intValue] ;
                _goodRate.text = [NSString stringWithFormat:@"%.1f%%",(double)rate/10.0];
                goodCount = value1 / value2;
                //goodCount = 0.23;
                if (goodCount >= 0.6) {
                    _yqnhsyLabel.textColor = [UIColor whiteColor];
                    _goodRate.textColor = [UIColor whiteColor];
                }
                if (goodCount >= 0.5 && goodCount < 0.6) {
                    _yqnhsyLabel.textColor = [UIColor whiteColor];
                }
                if(goodCount < 0.5){
                    _yqnhsyLabel.textColor = [UIColor redColor];
                    _goodRate.textColor = [UIColor redColor];
                }
                _centerCircle.progress = goodCount;
                //判断标类型
                if ([GoodDatas[@"state"] intValue] == 0) {
                    [_ljqgBtn setTitle:@"立即投资" forState: UIControlStateNormal];
                    [_ljqgBtn setBackgroundColor:[UIColor colorWithRed:225.0/155 green:0.0/255 blue:0.0/255 alpha:1]];
                   // _ljqgBtn.enabled = true;
                }else if([GoodDatas[@"state"] intValue] == 1) {
                    [_ljqgBtn setTitle:@"还款中" forState: UIControlStateNormal];
                    [_ljqgBtn setBackgroundColor:[UIColor colorWithRed:231.0/155 green:231.0/255 blue:231.0/255 alpha:1]];
                   // _ljqgBtn.enabled = false;
                }else if([GoodDatas[@"state"] intValue] == 2) {
                    [_ljqgBtn setTitle:@"已还款" forState: UIControlStateNormal];
                    [_ljqgBtn setBackgroundColor:[UIColor colorWithRed:231.0/155 green:231.0/255 blue:231.0/255 alpha:1]];
                    //_ljqgBtn.enabled = false;
                }else if([GoodDatas[@"state"] intValue] == 3) {
                    [_ljqgBtn setTitle:@"预售" forState: UIControlStateNormal];
                   
                }
                //[self addCenterTimer];
            }else {
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
- (void) createHotTZView {
    HotDatas = [[NSMutableArray alloc]init];
    self.ljqgBtn.layer.cornerRadius = 22;
    self.hotTZView1.layer.masksToBounds = true;
    self.hotTZView2.layer.masksToBounds = true;
    self.hotTZView1.layer.cornerRadius = 5;
    self.hotTZView2.layer.cornerRadius = 5;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hot1tap:)];
    [self.hotTZView1 addGestureRecognizer:tap];
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hot2tap:)];
    [self.hotTZView2 addGestureRecognizer:tap1];
    
    [self loadHotData];
}
- (void)hot1tap:(id)sender {
    if (HotDatas.count > 0) {
        UIStoryboard *s = [UIStoryboard storyboardWithName:@"CPXQ" bundle:nil];
        CPXQViewController *cpxq = [s instantiateViewControllerWithIdentifier:@"CPXQViewController"];
        cpxq.cpId = [HotDatas[0][@"id"] intValue];
        [self.navigationController pushViewController:cpxq animated:true];
    }
}
- (void)hot2tap:(id)sender {
    if (HotDatas.count > 1) {
        UIStoryboard *s = [UIStoryboard storyboardWithName:@"CPXQ" bundle:nil];
        CPXQViewController *cpxq = [s instantiateViewControllerWithIdentifier:@"CPXQViewController"];
        cpxq.cpId = [HotDatas[1][@"id"] intValue];
        [self.navigationController pushViewController:cpxq animated:true];
    }
}
- (void)createNewsTableView {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(more:)];
    [_moreNews addGestureRecognizer:tap];
    self.newsTableView.delegate = self;
    self.newsTableView.dataSource = self;
    self.newsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.newsTableView registerNib:[UINib nibWithNibName:@"NewsCell" bundle:nil] forCellReuseIdentifier:@"newscell"];
    //self.newsTableView.rowHeight = UITableViewAutomaticDimension;
    //self.newsTableView.estimatedRowHeight = 50;
    self.newsTableView.rowHeight = 110;
    self.newsTableView.estimatedRowHeight = UITableViewAutomaticDimension;
}
- (void)loadHotData {
    //载入热销排行榜数据
    NSString *url =[NSString stringWithFormat:@"%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"plan/notnew"];
    url = [NSString stringWithFormat:@"%@?page=1&limit=5&from=%@&version=%@", url, @"iOS", InnerVersion];
    [NetManager GetRequestWithUrlString:url finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        // [self showHudInView:self.view hint:@"载入中"];
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        int b = [result[@"resultCode"] intValue];
        if (b == 1) {
            [self showHint:result[@"resultMsg"] yOffset:0];
        }else if(b == 2){//token失效
            [self showHint:result[@"resultMsg"] yOffset:0];
            [FuncPublic SaveDefaultInfo:@"0" Key:userIsLogin];
            [FuncPublic SaveDefaultInfo:@"" Key:mSaveAccount];
            [FuncPublic SaveDefaultInfo:@"" Key:mUserInfo];
            
            
        }else {
            
            HotDatas = result[@"resultData"];
            if (HotDatas.count == 1) {
                self.hotFirstName.text = HotDatas[0][@"name"];
                double rate = [HotDatas[0][@"rate"] doubleValue]+ [HotDatas[0][@"rasingRate"] doubleValue] ;
                self.hotFirstRate.text =[NSString stringWithFormat:@"%.1f%%", rate/10.0];
                self.hotdate.text =[NSString stringWithFormat:@"%@%@", HotDatas[0][@"staging"] ,[FuncPublic getDate: HotDatas[0][@"stagingUnit"]]];
                hotFirstCount = [HotDatas[0][@"nowSum"] doubleValue] /  [HotDatas[0][@"amount"] doubleValue];
                _hotFirstCircle.progress = hotFirstCount;
               // [self addHot1Timer];
            }else if(HotDatas.count > 1){
                self.hotFirstName.text = HotDatas[0][@"name"];
                double rate = [HotDatas[0][@"rate"] doubleValue]+ [HotDatas[0][@"rasingRate"] doubleValue] ;
                self.hotFirstRate.text =[NSString stringWithFormat:@"%.1f%%", rate/10.0];
                self.hotdate.text =[NSString stringWithFormat:@"%@%@", HotDatas[0][@"staging"] ,[FuncPublic getDate: HotDatas[0][@"stagingUnit"]]];
                hotFirstCount = [HotDatas[0][@"nowSum"] doubleValue] /  [HotDatas[0][@"amount"] doubleValue];
                self.hotFirstCircle.progress = hotFirstCount;
               // [self addHot1Timer];
                
                self.hotSecondName.text = HotDatas[1][@"name"];
                rate = [HotDatas[1][@"rate"] doubleValue]+ [HotDatas[1][@"rasingRate"] doubleValue] ;
                self.hotSecondRate.text =[NSString stringWithFormat:@"%.1f%%", rate/10];
                self.hotSecondDate.text = [NSString stringWithFormat:@"%@%@", HotDatas[1][@"staging"] ,[FuncPublic getDate: HotDatas[1][@"stagingUnit"]]];
                double value1 = [HotDatas[1][@"nowSum"] doubleValue];
                double value2 = [HotDatas[1][@"amount"] doubleValue];
                hotSecondCount = value1 / value2;
                self.hotSecondCircle.progress = hotSecondCount;
                 //[self addHot2Timer];
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
- (void)loadNewsData {
    //载入新闻数据
    //[self showHudInView:self.view hint:@"载入中"];
    NSString *url =[NSString stringWithFormat:@"%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"news/list?"];
    url = [NSString stringWithFormat:@"%@page=1&limit=2&from=%@&version=%@", url, @"iOS", InnerVersion];
    [NetManager GetRequestWithUrlString:url finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         //[self showHudInView:self.view hint:@"载入中"];
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        int b = [result[@"resultCode"] intValue];
        if (b == 1) {
            [self showHint:result[@"resultMsg"] yOffset:0];
        }else if(b == 2){//token失效
            [self showHint:result[@"resultMsg"] yOffset:0];
            [FuncPublic SaveDefaultInfo:@"0" Key:userIsLogin];
            [FuncPublic SaveDefaultInfo:@"" Key:mSaveAccount];
            [FuncPublic SaveDefaultInfo:@"" Key:mUserInfo];
            
            
        }else {
            NewsDatas = result[@"resultData"];
            if (NewsDatas.count > 0) {
                [self.newsTableView reloadData];
            }else {
                
            }
            
        }
       // [self hideHud];
    } failed:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        if(error.code == -1009){
            [self showHint:@"网络连接失败，请检查网络状态。" yOffset:0];
        }else if(error.code == -1004){
            [self showHint:@"服务器开了个小差。" yOffset:0];
        }else if(error.code == -1001){
            [self showHint:@"请求超时，请检查网络状态。" yOffset:0];
        }
       //int i = error.code;
        [self hideHud];
    }];
}
- (void)hideBackButtonText{
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:nil];
}

//添加引导页
- (void)addLeadPage{
    [FuncPublic SaveDefaultInfo:@"NO" Key:mFirstLaunch];
    LeadPageView * leadPage = [[LeadPageView alloc]initWithFrame:self.view.bounds];
    [self.tabBarController.view addSubview:leadPage];
    [self.tabBarController.view bringSubviewToFront:leadPage];
    
//    CountDownView *cv = [[CountDownView alloc]initWithFrame:CGRectMake(Screen_Width *0.9, 50, 100, 100)];
//    UIWindow *wd = [UIApplication sharedApplication].keyWindow;
//    [wd addSubview:cv];
//    [wd bringSubviewToFront:cv];
    
}
- (void)toutiao {
    
    NSString *url = [NSString stringWithFormat:@"%@%@", [FuncPublic SharedFuncPublic].rootserver, @"channel/toutiao/activate"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    NSString *adid = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    [param setValue:adid forKey:@"idfa"];
     [param setValue:@"" forKey:@"mac"];
    
    [NetManager requestWithUrlString:url andDic:param finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
       // NSDictionary *result =  [NSJSONSerialization JSONObjectWithData:(NSData *)responseObject  options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *result = [self dictionaryWithJsonData:responseObject];
        //NSMutableDictionary *result = [[NSMutableDictionary alloc]init];
       // [result setDictionary:(NSDictionary *)responseObject];
        if (result[@"resultCode"]) {
            
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
- (NSDictionary *)dictionaryWithJsonData:(NSData *)jsonData {
    if (jsonData == nil) {
        return nil;
    }
   NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:(NSData *)jsonData  options:NSJSONReadingMutableContainers error:nil];
    return dic;
    
    
    
}
//下拉刷新
- (void)tableHeaderDidTriggerRefresh {
    
#ifdef __IPHONE_11_0
    if ([self.scrollView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
        if (@available(iOS 11.0, *)) {
            self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
        }
    }else {
        self.automaticallyAdjustsScrollViewInsets = false;
    }
#endif
    self.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //清零
        goodCount = 0;
        _centerCircle.progress = 0;
        _goodRate.text = @"0.0%";
        //_yqnhsyLabel.textColor = [UIColor redColor];
        //_goodRate.textColor = [UIColor redColor];
        
        [self createAdScrollView];
        [self createXBTextLoopView];
        [self createGoodProject];
        [self loadHotData];
        [self loadNewsData];
        NSLog(@"刷新");
        [self.scrollView.mj_header endRefreshing];
    }];
}
- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    
    
   // self.navigationController.navigationBar.hidden = YES;
    //[self hideNavigationBar];
     //[[NSNotificationCenter defaultCenter] postNotificationName:@"tabBarAppear" object:nil];
}
- (void)removewWhiteView {
    [_whiteView removeFromSuperview];
}
- (void)viewWillDisappear:(BOOL)animated {
   //  [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (IBAction)hlxs:(id)sender {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"HTML" bundle:nil];
    htmlViewController *html = [s instantiateViewControllerWithIdentifier:@"htmlViewController"];
    html.name = @"豪礼相送";
    [self.navigationController pushViewController:html animated:true];
    
}
- (IBAction)zyfk:(id)sender {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"HTML" bundle:nil];
    htmlViewController *html = [s instantiateViewControllerWithIdentifier:@"htmlViewController"];
    html.name = @"安全保障";
    [self.navigationController pushViewController:html animated:true];
}
- (IBAction)hdzx:(id)sender {
    HDViewController *hd = [self.storyboard instantiateViewControllerWithIdentifier:@"HDViewController"];
    [self.navigationController pushViewController:hd animated:true];
}


- (IBAction)ryez:(id)sender {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"HTML" bundle:nil];
    htmlViewController *html = [s instantiateViewControllerWithIdentifier:@"htmlViewController"];
    html.name = @"约投定制";
    [self.navigationController pushViewController:html animated:true];
}
- (IBAction)xtyl:(id)sender {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"HTML" bundle:nil];
    htmlViewController *html = [s instantiateViewControllerWithIdentifier:@"htmlViewController"];
    html.name = @"续投有礼";
    [self.navigationController pushViewController:html animated:true];
}
- (IBAction)icp:(id)sender {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"HTML" bundle:nil];
    htmlViewController *html = [s instantiateViewControllerWithIdentifier:@"htmlViewController"];
    html.name = @"ICP认证";
    [self.navigationController pushViewController:html animated:true];
}
- (IBAction)tzyl:(id)sender {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"HTML" bundle:nil];
    htmlViewController *html = [s instantiateViewControllerWithIdentifier:@"htmlViewController"];
    html.name = @"投资有礼";
    [self.navigationController pushViewController:html animated:true];
}

- (IBAction)yqyl:(id)sender {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"HTML" bundle:nil];
    htmlViewController *html = [s instantiateViewControllerWithIdentifier:@"htmlViewController"];
    html.name = @"邀请有礼";
    [self.navigationController pushViewController:html animated:true];
}
- (IBAction)xszn:(id)sender {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"HTML" bundle:nil];
    htmlViewController *html = [s instantiateViewControllerWithIdentifier:@"htmlViewController"];
    html.name = @"新手指南";
    [self.navigationController pushViewController:html animated:true];
}
- (IBAction)tzlc:(id)sender {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"HTML" bundle:nil];
    htmlViewController *html = [s instantiateViewControllerWithIdentifier:@"htmlViewController"];
    html.name = @"投资有礼";
    [self.navigationController pushViewController:html animated:true];
}

- (void)more:(id)sender {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"Foundation" bundle:nil];
    ZXViewController *news = [s instantiateViewControllerWithIdentifier:@"ZXViewController"];
    [self.navigationController pushViewController:news animated:true];
    //NewsTableViewController *news = [self.storyboard instantiateViewControllerWithIdentifier:@"NewsTableViewController"];
   // [self.navigationController pushViewController:news animated:true];
}
- (IBAction)ljqgClicked:(id)sender {
    
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"CPXQ" bundle:nil];
    CPXQViewController *cpxq = [s instantiateViewControllerWithIdentifier:@"CPXQViewController"];
    cpxq.cpId = [GoodDatas[@"id"] intValue];
    cpxq.xktype = [GoodDatas[@"type"] intValue];
    cpxq.cpState = [GoodDatas[@"state"] intValue];
    [self.navigationController pushViewController:cpxq animated:true];
    
}
- (IBAction)ggTouched:(id)sender {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"Foundation" bundle:nil];
    FggViewController *ptgg = [s instantiateViewControllerWithIdentifier:@"FggViewController"];
    [self.navigationController pushViewController:ptgg animated:true];
}
- (void)addCenterTimer
{
    _Centertimer = [NSTimer scheduledTimerWithTimeInterval:0.008f target:self selector:@selector(CneterTimerAction) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_Centertimer forMode:NSRunLoopCommonModes];
}

- (void)addHot1Timer
{
    _Hot1timer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(Hot1TimerAction) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_Hot1timer forMode:NSRunLoopCommonModes];
}

- (void)addHot2Timer
{
    _Hot2timer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(Hot2TimerAction) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_Hot2timer forMode:NSRunLoopCommonModes];
}
- (void)CneterTimerAction
{
    if(goodCount == 0){
         [self removeCenterTimer];
    }else {
        _centerCircle.progress += 0.001;
        double i = _centerCircle.progress;
        //    if (increment > 0.01) {
        //        increment -= 0.01;
        //    }
        NSLog(@"progress === %f", _centerCircle.progress);
        if (_centerCircle.progress >= goodCount) {
            
            [self removeCenterTimer];
        }
    }
}
- (void)Hot1TimerAction {
    _hotFirstCircle.progress = hotFirstCount;
    [self removeHot1Timer];
//    if (_hotFirstCircle.progress >= hotFirstCount) {
//        [self removeHot1Timer];
//        NSLog(@"完成");
//    }
   
}
- (void)Hot2TimerAction {
    _hotSecondCircle.progress += hotSecondCount;
//    if (_hotSecondCircle.progress >= hotSecondCount) {
//        [self removeHot2Timer];
//        NSLog(@"完成");
//    }
}
- (void)removeCenterTimer
{
    [_Centertimer invalidate];
    _Centertimer = nil;
}
- (void)removeHot1Timer
{
    [_Hot1timer invalidate];
    _Hot1timer = nil;
}
- (void)removeHot2Timer
{
    [_Hot2timer invalidate];
    _Hot2timer = nil;
}
- (void)jumpHtml:(NSNotification *)notification{
    NSDictionary * infoDic = [notification object];
    // 这样就得到了我们在发送通知时候传入的字典了

    UIStoryboard *s = [UIStoryboard storyboardWithName:@"HTML" bundle:nil];
    htmlViewController *detail = [s instantiateViewControllerWithIdentifier:@"htmlViewController"];
   // detail.nid = [NewsDatas[indexPath.row][@"id"] intValue];
    detail.name = @"test";
    detail.hkurl = infoDic[@"url"];
    [self.navigationController pushViewController:detail animated:true];
}
#pragma mark- uitableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return NewsDatas.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newscell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *image =[NSString stringWithFormat:@"%@%@",@"", NewsDatas[indexPath.row][@"coverImage"]];
    image = [image stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [cell.newsimage sd_setImageWithURL:[NSURL URLWithString:image] placeholderImage:[UIImage imageNamed:@""]];
    
    cell.newstitle.text = NewsDatas[indexPath.row][@"title"];
    
    //NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[NewsDatas[indexPath.row][@"content"] dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];

   // cell.newscontent.attributedText = attrStr;
    cell.newscontent.text = NewsDatas[indexPath.row][@"subTitle"];
    NSString *createTime = [FuncPublic getTime: NewsDatas[indexPath.row][@"updatedTime"]];
    cell.newsTime.text = [createTime substringToIndex:10];
    return cell;
}
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 120;
//}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"HTML" bundle:nil];
    htmlViewController *detail = [s instantiateViewControllerWithIdentifier:@"htmlViewController"];
    detail.nid = [NewsDatas[indexPath.row][@"id"] intValue];
    detail.name = @"来浙投资讯";
    [self.navigationController pushViewController:detail animated:true];
//    UIStoryboard *s = [UIStoryboard storyboardWithName:@"HomePage" bundle:nil];
//    NewsDetailViewController *detail = [s instantiateViewControllerWithIdentifier:@"NewsDetailViewController"];
//    detail.noticeId = [NewsDatas[indexPath.row][@"id"] intValue];
//    detail.typeName = @"来浙投资讯";
//    [self.navigationController pushViewController:detail animated:true];
}

#pragma mark - UINavigationControllerDelegate
// 将要显示控制器
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 判断要显示的控制器是否是自己
    BOOL isShowHomePage = [viewController isKindOfClass:[self class]];
    
    [self.navigationController setNavigationBarHidden:isShowHomePage animated:YES];
}
#pragma mark- uivalertview
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSString *str = @"https://itunes.apple.com/us/app/来浙投理财/id1361945824?l=zh&ls=1&mt=8";
        NSURL *safariURL = [NSURL URLWithString:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [[UIApplication sharedApplication] openURL:safariURL];
    }
}
@end
