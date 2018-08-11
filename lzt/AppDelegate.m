//
//  AppDelegate.m
//  lzt
//
//  Created by 黄伟强 on 2017/10/16.
//  Copyright © 2017年 hwq. All rights reserved.
//
//#import <UMCommon/UMCommon.h>           // 公共组件是所有友盟产品的基础组件，必选
#import <UMSocialCore/UMSocialCore.h>    // 分享组件
#import "UMMobClick/MobClick.h" //统计
#import "AppDelegate.h"
#import "LoginRegisterViewController.h"
#import "LoginViewController.h"
#import "NavigationController.h"
#import "LeadPageView.h"
#import "MyTabbarController.h"
#import "Reachability.h"
#import "CountDownView.h"
#import "UIImageView+WebCache.h"
#import "htmlViewController.h"
#import "GeTuiXQViewController.h"


// iOS10 及以上需导入 UserNotifications.framework
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

/// 使用个推回调时，需要添加"GeTuiSdkDelegate"
/// iOS 10 及以上环境，需要添加 UNUserNotificationCenterDelegate 协议，才能使用 UserNotifications.framework 的回调


#define USHARE_DEMO_APPKEY @"5a1cd3caf43e4834ea000031"//友盟分享



@interface AppDelegate ()<UITabBarControllerDelegate>

@property (nonatomic, strong) Reachability *hostReachability;
@property (nonatomic, strong) Reachability *routerReachability;
@property (nonatomic, strong) Reachability *internetReachability;
@property (nonatomic, strong) Reachability *wifiReachability;

@property (nonatomic, strong) MyTabbarController *tabbarVC;

@property (nonatomic, strong) UIButton *countDown;
@property (nonatomic, strong) UIImageView *countDownView;
@property (nonatomic, strong) UIView *backgroundViewUp;
@property (nonatomic, strong) UIImageView *backgroundViewDown;
@property (nonatomic, assign) NSString * picture;
@property (nonatomic, assign) NSString *launchurl;
@property (nonatomic, strong) NSDictionary *result;
@property (nonatomic, assign) BOOL addFlag; //判断倒计时是否已经结束，则不在添加网络图片


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //self.tabBarController.tabBar.hidden = YES;
   
    // [ GTSdk ]：是否允许APP后台运行
    //    [GeTuiSdk runBackgroundEnable:YES];
    
    // [ GTSdk ]：是否运行电子围栏Lbs功能和是否SDK主动请求用户定位
    [GeTuiSdk lbsLocationEnable:YES andUserVerify:YES];
    
    // [ GTSdk ]：自定义渠道
    [GeTuiSdk setChannelId:@"GT-Channel"];
    
//    [GeTuiSdk setBadge:badge]; //同步本地角标值到服务器
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badge]; //APP 显示角标需开发者调用系统方法进行设置
    
    
    // [ GTSdk ]：使用APPID/APPKEY/APPSECRENT启动个推
    [GeTuiSdk startSdkWithAppId:kGtAppId appKey:kGtAppKey appSecret:kGtAppSecret delegate:self];
    
    // 注册APNs - custom method - 开发者自定义的方法
    [self registerRemoteNotification];
    
    // 启动图片延时: 2秒
    //[NSThread sleepForTimeInterval:3];

    self.window =[[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyWindow];
    
   
    
    

    
    [self addTabBar];
   
    _addFlag = true;
    _backgroundViewUp = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
    _backgroundViewUp.backgroundColor = [UIColor whiteColor];
    //_backgroundViewUp.image = [UIImage imageNamed:@"laizhetou"];
    [self.window addSubview:_backgroundViewUp];
    
    _backgroundViewDown = [[UIImageView alloc]initWithFrame:CGRectMake(0, Screen_Height - 135, Screen_Width, 135)];
    _backgroundViewDown.image = [UIImage imageNamed:@"laizhetou"];
    [self.window addSubview:_backgroundViewDown];
    [self.window bringSubviewToFront:_backgroundViewDown];
    
    _countDown = [[UIButton alloc]initWithFrame:CGRectMake(Screen_Width *0.8, 50, 60, 60)];
    [_countDown setTitle:@"跳过3" forState:UIControlStateNormal];
    [_countDown setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_countDown setBackgroundColor:UIColorFromRGB(0xa2a2a2)];
    _countDown.alpha = 0.5;
    _countDown.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:12.0];
    [_countDown addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchUpInside];
    _countDown.layer.cornerRadius = 30;
    [self.window addSubview:_countDown];
    
    __block NSInteger time = 3; //倒计时时间
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    
    dispatch_source_set_event_handler(_timer, ^{
        
        if(time <= 0){ //倒计时结束，关闭
            _addFlag = false;
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                [_countDown removeFromSuperview];
                [_backgroundViewDown removeFromSuperview];
                [_backgroundViewUp removeFromSuperview];
                [_countDownView removeFromSuperview];
                
                [[NSNotificationCenter defaultCenter]postNotificationName:@"removewWhiteView" object:nil];
                
                if (![FuncPublic GetDefaultInfo:mFirstLaunch]) {
                    [self addLeadPage];
                }
                //设置按钮的样式
                //                [b setText:@"" ];
                //                //[self.yzmLabel setTitleColor:[UIColor whiteColor] ];
                //                b.userInteractionEnabled = YES;
            });
            
        }else{
            
            int seconds = time % 4;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //设置按钮显示读秒效果
                [_countDown setTitle:[NSString stringWithFormat:@"跳过%.0d", seconds] forState: UIControlStateNormal];
                //[self.codeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                // self.yzmLabel.userInteractionEnabled = NO;
            });
            time--;
        }
    });
    dispatch_resume(_timer);
    
    
    [self loadLaunchImage];
    
//    _countDownView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
//   // _countDownView.userInteractionEnabled = YES;
//
//    _countDownView.image = [UIImage imageNamed:@"1242"];
//   // NSString *image =  [_picture stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
//
//   // [_countDownView sd_setImageWithURL:[NSURL URLWithString:image]];
//    [self.window addSubview:_countDownView];
//
//    _countDown = [[UIButton alloc]initWithFrame:CGRectMake(Screen_Width *0.8, 50, 60, 60)];
//    [_countDown setTitle:@"跳过3" forState:UIControlStateNormal];
//    [_countDown setTitleColor:UIColorFromRGB(0x886b6b) forState:UIControlStateNormal];
//    [_countDown setBackgroundColor:UIColorFromRGB(0x802121)];
//    [_countDown addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchUpInside];
//    _countDown.layer.cornerRadius = 30;
//    [self.window addSubview:_countDown];
//    [self.window bringSubviewToFront:_countDown];
//
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(jump)];
//    [_countDownView addGestureRecognizer:tap];
//
//    __block NSInteger time = 3; //倒计时时间
//
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
//
//    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
//
//    dispatch_source_set_event_handler(_timer, ^{
//
//        if(time <= 0){ //倒计时结束，关闭
//
//            dispatch_source_cancel(_timer);
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [_countDown removeFromSuperview];
//                //[_backgroundView removeFromSuperview];
//                [_countDownView removeFromSuperview];
//                //设置按钮的样式
//                //                [b setText:@"" ];
//                //                //[self.yzmLabel setTitleColor:[UIColor whiteColor] ];
//                //                b.userInteractionEnabled = YES;
//            });
//
//        }else{
//
//            int seconds = time % 4;
//            dispatch_async(dispatch_get_main_queue(), ^{
//
//                //设置按钮显示读秒效果
//                [_countDown setTitle:[NSString stringWithFormat:@"跳过%.0d", seconds] forState: UIControlStateNormal];
//                //[self.codeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//                // self.yzmLabel.userInteractionEnabled = NO;
//            });
//            time--;
//        }
//    });
//    dispatch_resume(_timer);
    
    // 启动图片延时: 2秒
    //[NSThread sleepForTimeInterval:10];
    
    //设置状态栏颜色为白色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    //[self addLeadPage];
    //友盟配置
    [UMSocialGlobal shareInstance].isClearCacheWhenGetUserInfo = NO;
    
    /* 设置友盟appkey */
    [[UMSocialManager defaultManager] setUmSocialAppkey:USHARE_DEMO_APPKEY];
    // U-Share 平台设置
    [self configUSharePlatforms];
    [self confitUShareSettings];
    
    //设置友盟统计
    [MobClick setLogEnabled:NO];
    UMConfigInstance.appKey = @"5a6044d5f43e4849f60000e1";
    UMConfigInstance.channelId = @"App Store";
    //UMConfigInstance.secret = @"secretstringaldfkals";
    //    UMConfigInstance.eSType = E_UM_GAME;
    [MobClick startWithConfigure:UMConfigInstance];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appReachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    //Change the host name here to change the server you want to monitor.
    //  NSString *remoteHostName = @"www.apple.com";
    NSString *remoteHostName = @"www.futoulc.com";
    
    self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
    [self.hostReachability startNotifier];
    // 检测默认路由是否可达
    self.routerReachability = [Reachability reachabilityForInternetConnection];
    [self.routerReachability startNotifier];
    return YES;
}
- (void)jump{
    [_countDown removeFromSuperview];
    [_countDownView removeFromSuperview];
    [_backgroundViewUp removeFromSuperview];
    [_backgroundViewDown removeFromSuperview];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"removewWhiteView" object:nil];
    if ([_result[@"url"] length] > 0) {
        [_backgroundViewUp removeFromSuperview];
        [_backgroundViewDown removeFromSuperview];
        [_countDownView removeFromSuperview];
        [_countDown removeFromSuperview];
        
        NSLog(@"%@", _result);
        //    [[NSNotificationCenter defaultCenter]
        //     postNotificationName:@"jumpHtml" object:@{@"url":_url}];
        UIStoryboard *s = [UIStoryboard storyboardWithName:@"HTML" bundle:nil];
        htmlViewController *detail = [s instantiateViewControllerWithIdentifier:@"htmlViewController"];
        // detail.nid = [NewsDatas[indexPath.row][@"id"] intValue];
        detail.name = _result[@"title"];
        detail.hkurl = _result[@"url"];
        [self.tabbarVC.navigationController pushViewController:detail animated:true];
    }
}

-(void) loadLaunchImage {
    
    //载入数据
    NSString *url =[NSString stringWithFormat:@"%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"openscreen/pic"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setValue:@"iOS" forKey:@"from"];
    if (iPhone5) {
        [param setValue:@"202" forKey:@"type"];
    }else if(iPhone6){
       [param setValue:@"203" forKey:@"type"];
    }else if(iPhone6Plus){
        [param setValue:@"204" forKey:@"type"];
    }else if(iPhoneX){
        [param setValue:@"205" forKey:@"type"];
    }else{
       [param setValue:@"202" forKey:@"type"];
    }
    [NetManager GetRequestWithUrlString:url andDic:param finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        if ([result[@"resultCode"] boolValue]) {
//            _backgroundViewDown = [[UIImageView alloc]initWithFrame:CGRectMake(0, Screen_Height - 135, Screen_Width, 135)];
//            _backgroundViewDown.image = [UIImage imageNamed:@"laizhetou"];
//            [self.window addSubview:_backgroundViewDown];
//            [self.window bringSubviewToFront:_backgroundViewDown];
           // [self showHint:result[@"resultMsg"] yOffset:0];
        }else {
            NSDictionary *dic = result[@"resultData"];
            _picture = dic[@"picture"];
            _launchurl = [NSString stringWithFormat:@"%@", dic[@"url"]];
            _result = result[@"resultData"];
            
            if (_addFlag) {
                //_countDownView.image = [UIImage imageNamed:@"1242"];
                _countDownView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
                _countDownView.userInteractionEnabled = YES;
                
                //_countDownView.image = [UIImage imageNamed:@"1242"];
                NSString *image =  [_picture stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                
                [_countDownView sd_setImageWithURL:[NSURL URLWithString:image]];
                [self.window addSubview:_countDownView];
                
                [self.window bringSubviewToFront:_backgroundViewDown];
                [self.window bringSubviewToFront:_countDown];
                
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(jump)];
                [_countDownView addGestureRecognizer:tap];
            }
            
        }
        
    } failed:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        if(error.code == -1009){
            //[self showHint:@"网络连接失败，请检查网络状态。" yOffset:0];
        }else if(error.code == -1004){
           // [self showHint:@"服务器开了个小差。" yOffset:0];
        }else if(error.code == -1001){
           // [self showHint:@"请求超时，请检查网络状态。" yOffset:0];
        }
        //[self.tableView.mj_header endRefreshing];
    }];
}
//添加引导页
- (void)addLeadPage{
    [FuncPublic SaveDefaultInfo:@"NO" Key:mFirstLaunch];
    LeadPageView * leadPage = [[LeadPageView alloc]initWithFrame:self.window.bounds];
    [self.tabbarVC.view addSubview:leadPage];
    [self.tabbarVC.view bringSubviewToFront:leadPage];
    
    //    CountDownView *cv = [[CountDownView alloc]initWithFrame:CGRectMake(Screen_Width *0.9, 50, 100, 100)];
    //    UIWindow *wd = [UIApplication sharedApplication].keyWindow;
    //    [wd addSubview:cv];
    //    [wd bringSubviewToFront:cv];
    
}
- (void)remove{
    [_countDown removeFromSuperview];
    [_countDownView removeFromSuperview];
    [_backgroundViewUp removeFromSuperview];
    [_backgroundViewDown removeFromSuperview];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"removewWhiteView" object:nil];
    
}

//添加tabbar,主视图控制器
- (void)addTabBar{
    //初始化服务器地址
    [FuncPublic SharedFuncPublic].rootserver = @"https://www.futoulc.com/api/";
    [FuncPublic SharedFuncPublic].root = @"https://www.futoulc.com/";

    _tabbarVC = [[MyTabbarController alloc]init];
    _tabbarVC.delegate = self;
    NavigationController *nav = [[NavigationController alloc]initWithRootViewController:_tabbarVC];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    self.window.rootViewController = nav;//设置根控制器
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{

    bool sign = [[FuncPublic GetDefaultInfo:userIsLogin] boolValue];
    //取出登陆状态(NSUserDefaults即可)
    //NSInteger selectedIndex = 0;

        if ([viewController.tabBarItem.title isEqualToString:@"我的"])
        {
            //selectedIndex = 3;
              if (!sign) {  //未登录
                  UIStoryboard *s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
                  LoginRegisterViewController *loginVC = [s instantiateViewControllerWithIdentifier:@"LoginRegisterViewController"];
                  //loginVC.isChildViewController = false;
                 
                  NavigationController *loginNav = [[NavigationController alloc] initWithRootViewController:loginVC];   //使登陆界面的Navigationbar可以显示出来
                
                [tabBarController presentViewController:loginNav animated:false completion:nil]; //跳转界面
                                     
                  

                  //在登陆界面判断登陆成功之后发送通知,将所选的TabbarItem传回,使用通知传值
                  //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(logSelect:) name:@"logSelect" object:nil];     //接收
                  return NO;
              }else {
                  return YES;
              }
    }else{
        return YES;
    }
}

- (void)logSelect:(NSNotification *)text{
    //NSInteger index = [text.userInfo[@"select"] integerValue];
    //_tabbarVC.selectedIndex = [text.userInfo[@"select"] integerValue];
    [UIView animateWithDuration:0.1 animations:^{
        
       _tabbarVC.selectedIndex = 3;
    }];
    
}
#pragma mark- U - share
- (void)confitUShareSettings
{
    /*
     * 打开图片水印
     */
    //[UMSocialGlobal shareInstance].isUsingWaterMark = YES;
    
    /*
     * 关闭强制验证https，可允许http图片分享，但需要在info.plist设置安全域名
     <key>NSAppTransportSecurity</key>
     <dict>
     <key>NSAllowsArbitraryLoads</key>
     <true/>
     </dict>
     */
    //[UMSocialGlobal shareInstance].isUsingHttpsWhenShareContent = NO;
    
}

- (void)configUSharePlatforms
{
    /* 设置微信的appKey和appSecret */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:@"wx0aa11ba316424dc8" appSecret:@"ddf6bcc58f389953deb4c2886d5a2bde" redirectURL:@"https://www.futoulc.com/mobile/invitFriend"];
    /*
     * 移除相应平台的分享，如微信收藏
     */
    //[[UMSocialManager defaultManager] removePlatformProviderWithPlatformTypes:@[@(UMSocialPlatformType_WechatFavorite)]];
    
    /* 设置分享到QQ互联的appID
     * U-Share SDK为了兼容大部分平台命名，统一用appKey和appSecret进行参数设置，而QQ平台仅需将appID作为U-Share的appKey参数传进即可。
     */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:@"1106492489"/*设置QQ平台的appID*/  appSecret:nil redirectURL:@"https://www.futoulc.com/mobile/invitFriend"];
    
}
// 支持所有iOS系统 ,分享的系统回调函数
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //6.3的新的API调用，是为了兼容国外平台(例如:新版facebookSDK,VK等)的调用[如果用6.2的api调用会没有回调],对国内平台没有影响
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    return result;
}
#pragma mark- 个推
#pragma mark - background fetch  唤醒
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // [ GTSdk ]：Background Fetch 恢复SDK 运行
    [GeTuiSdk resume];
    
    completionHandler(UIBackgroundFetchResultNewData);
}


/** 远程通知注册成功委托 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"\n>>>[DeviceToken Success]:%@\n\n", token);
    
    // 向个推服务器注册deviceToken
    [GeTuiSdk registerDeviceToken:token];
}
/** 远程通知注册失败委托 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //[_viewController logMsg:[NSString stringWithFormat:@"didFailToRegisterForRemoteNotificationsWithError:%@", [error localizedDescription]]];
    NSLog(@"注册失败");
}
//在iOS 10 以前，为处理 APNs 通知点击事件，统计有效用户点击数，需在AppDelegate.m里的didReceiveRemoteNotification回调方法中调用个推SDK统计接口
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    [GeTuiSdk resetBadge]; //重置角标计数
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0]; // APP 清空角标
    
    // 将收到的APNs信息传给个推统计
    [GeTuiSdk handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
    
    int i = [UIApplication sharedApplication].applicationIconBadgeNumber;
    NSLog(@"tesef");
    
    
}
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
//  iOS 10: App在前台获取到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    
    NSLog(@"willPresentNotification：%@", notification.request.content.userInfo);
    
    // 根据APP需要，判断是否要提示用户Badge、Sound、Alert
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}

//  iOS 10: 点击通知进入App时触发
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    
    NSLog(@"didReceiveNotification：%@", response.notification.request.content.userInfo);
    
    [GeTuiSdk resetBadge]; //重置角标计数
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0]; // APP 清空角标
    
    // [ GTSdk ]：将收到的APNs信息传给个推统计
    [GeTuiSdk handleRemoteNotification:response.notification.request.content.userInfo];
    
    completionHandler();
}
#endif


/** 注册 APNs *///推送调用
- (void)registerRemoteNotification {
    /*
     警告：Xcode8 需要手动开启"TARGETS -> Capabilities -> Push Notifications"
     */
    
    /*
     警告：该方法需要开发者自定义，以下代码根据 APP 支持的 iOS 系统不同，代码可以对应修改。
     以下为演示代码，注意根据实际需要修改，注意测试支持的 iOS 系统都能获取到 DeviceToken
     */
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0 // Xcode 8编译会调用
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionCarPlay) completionHandler:^(BOOL granted, NSError *_Nullable error) {
            if (!error) {
                NSLog(@"request authorization succeeded!");
            }
        }];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
#else // Xcode 7编译会调用
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
#endif
    } else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
        UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert |
                                                                       UIRemoteNotificationTypeSound |
                                                                       UIRemoteNotificationTypeBadge);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
    }
}
#pragma mark - GeTuiSdkDelegate
- (NSString *)formateTime:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSString *dateTime = [formatter stringFromDate:date];
    return dateTime;
}
/** SDK启动成功返回cid */
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {
    // [ GTSdk ]：个推SDK已注册，返回clientId
    NSLog(@">>[GTSdk RegisterClient]:%@", clientId);
}
- (void)GeTuiSdkDidAliasAction:(NSString *)action result:(BOOL)isSuccess sequenceNum:(NSString *)aSn error:(NSError *)aError{
    if ([kGtResponseBindType isEqualToString:action]) {
        NSLog(@"绑定结果 ：%@ !, sn : %@", isSuccess ? @"成功" : @"失败", aSn);
        if (!isSuccess) {
            NSLog(@"绑定失败原因: %@", aError);
        }
    } else if ([kGtResponseUnBindType isEqualToString:action]) {
        NSLog(@"解绑结果 ：%@ !, sn : %@", isSuccess ? @"成功" : @"失败", aSn);
        if (!isSuccess) {
            NSLog(@"解绑失败原因: %@", aError);
        }
    }
}
/** SDK收到透传消息回调 */
- (void)GeTuiSdkDidReceivePayloadData:(NSData *)payloadData andTaskId:(NSString *)taskId andMsgId:(NSString *)msgId andOffLine:(BOOL)offLine fromGtAppId:(NSString *)appId {
    
    // [ GTSdk ]：汇报个推自定义事件(反馈透传消息)
    [GeTuiSdk sendFeedbackMessage:90001 andTaskId:taskId andMsgId:msgId];
    
    // 数据转换
    NSString *payloadMsg = nil;
    if (payloadData) {
        payloadMsg = [[NSString alloc] initWithBytes:payloadData.bytes length:payloadData.length encoding:NSUTF8StringEncoding];
    }
    NSDictionary *data = [FuncPublic dictionaryWithJsonData:payloadData];
    //解析透传消息
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:data[@"title"] message:data[@"content"] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NavigationController *nav =   (NavigationController *) [UIApplication sharedApplication].keyWindow.rootViewController ;
        MyTabbarController *tab =  nav.viewControllers[0];
        //tab.selectedIndex = 0;
        if ([data[@"type"] isEqualToString:@"h5page"]) {
            
            
            UIStoryboard *s = [UIStoryboard storyboardWithName:@"HTML" bundle:nil];
            GeTuiXQViewController *detail = [s instantiateViewControllerWithIdentifier:@"GeTuiXQViewController"];
            // detail.nid = [NewsDatas[indexPath.row][@"id"] intValue];
            NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
            [param setValue:data[@"title"] forKey:@"title"];
            [param setValue:data[@"url"] forKey:@"url"];
            
//            detail.name = data[@"title"];
//
//            NSString *url = data[@"url"];
            //detail.hkurl = url;
            detail.dic = param;
            [tab.viewControllers[0].navigationController pushViewController:detail animated:true];
        }else if ([data[@"type"] isEqualToString:@"home"]){
            tab.selectedIndex = 0;
        }else if ([data[@"type"] isEqualToString:@"investment"]){
            tab.selectedIndex = 1;
        }else if ([data[@"type"] isEqualToString:@"discover"]){
            tab.selectedIndex = 2;
        }else if ([data[@"type"] isEqualToString:@"me"]){
            //tab.selectedIndex = 3;
            bool sign = [[FuncPublic GetDefaultInfo:userIsLogin] boolValue];
            //取出登陆状态(NSUserDefaults即可)
            //NSInteger selectedIndex = 0;
        
                //selectedIndex = 3;
                if (!sign) {  //未登录
                    UIStoryboard *s = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
                    LoginRegisterViewController *loginVC = [s instantiateViewControllerWithIdentifier:@"LoginRegisterViewController"];
                    //loginVC.isChildViewController = false;
                    
                    NavigationController *loginNav = [[NavigationController alloc] initWithRootViewController:loginVC];   //使登陆界面的Navigationbar可以显示出来
                    
                    [tab presentViewController:loginNav animated:false completion:nil]; //跳转界面
                }else {
                    tab.selectedIndex = 3;
                }
        }
        
        //解绑。
        
        
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:cancel];
    [alert addAction:ok];
    [self.tabbarVC presentViewController:alert animated:true completion:nil];
    // 页面显示日志
    NSString *record = [NSString stringWithFormat:@"%d, %@, %@%@", ++_lastPayloadIndex, [self formateTime:[NSDate date]], payloadMsg, offLine ? @"<离线消息>" : @""];
   // [_viewController logMsg:record];
    
    // 控制台打印日志
    NSString *msg = [NSString stringWithFormat:@"%@ : %@%@", [self formateTime:[NSDate date]], payloadMsg, offLine ? @"<离线消息>" : @""];
    NSLog(@">>[GTSdk ReceivePayload]:%@, taskId: %@, msgId :%@", msg, taskId, msgId);
}

/** SDK收到sendMessage消息回调 */
- (void)GeTuiSdkDidSendMessage:(NSString *)messageId result:(int)result {
    // 页面显示：上行消息结果反馈
    NSString *record = [NSString stringWithFormat:@"Received sendmessage:%@ result:%d", messageId, result];
   // [_viewController logMsg:record];
     NSLog(@"\n>>[GTSdk DidSendMessage]:%@\n\n", record);
}

/** SDK遇到错误回调 */
- (void)GeTuiSdkDidOccurError:(NSError *)error {
    // 页面显示：个推错误报告，集成步骤发生的任何错误都在这里通知，如果集成后，无法正常收到消息，查看这里的通知。
    //[_viewController logMsg:[NSString stringWithFormat:@">>>[GexinSdk error]:%@", [error localizedDescription]]];
    NSLog(@"%@", [NSString stringWithFormat:@">>>[GexinSdk error]:%@", [error localizedDescription]]);
}

/** SDK运行状态通知 */
- (void)GeTuiSDkDidNotifySdkState:(SdkStatus)aStatus {
    // 页面显示更新通知SDK运行状态
   // [_viewController updateStatusView:self];
     NSLog(@"\n>>[GTSdk SdkState]:%u\n\n", aStatus);
}

/** SDK设置推送模式回调  */
- (void)GeTuiSdkDidSetPushMode:(BOOL)isModeOff error:(NSError *)error {
    if (error) {
        NSLog(@"\n>>[GTSdk SetModeOff Error]:%@\n\n", [error localizedDescription]);
        return;
    }
    
    NSLog(@"\n>>[GTSdk SetModeOff]:%@\n\n", isModeOff ? @"开启" : @"关闭");
//    // 页面显示错误信息
//    if (error) {
//        [_viewController logMsg:[NSString stringWithFormat:@">>>[SetModeOff error]: %@", [error localizedDescription]]];
//        return;
//    }
//
//    [_viewController logMsg:[NSString stringWithFormat:@">>>[GexinSdkSetModeOff]: %@", isModeOff ? @"开启" : @"关闭"]];
//
//    // 页面更新按钮事件
//    UIViewController *vc = _naviController.topViewController;
//    if ([vc isKindOfClass:[ViewController class]]) {
//        ViewController *nextController = (ViewController *) vc;
//        [nextController updateModeOffButton:isModeOff];
//    }
}
#pragma mark -
/// 当网络状态发生变化时调用
- (void)appReachabilityChanged:(NSNotification *)notification{
    Reachability *reach = [notification object];
    if([reach isKindOfClass:[Reachability class]]){
        
        // 两种检测:路由与服务器是否可达  三种状态:手机流量联网、WiFi联网、没有联网
        if (reach == self.routerReachability) {
            NetworkStatus status = [reach currentReachabilityStatus];
            if (status == NotReachable) {
              //  [self.window.rootViewController showHint:@"服务器开了个小差" yOffset:0];

            } else if (status == ReachableViaWiFi) {
                NSLog(@"routerReachability ReachableViaWiFi");
            } else if (status == ReachableViaWWAN) {
                NSLog(@"routerReachability ReachableViaWWAN");
            }
        }
        if (reach == self.hostReachability) {
            //NSLog(@"hostReachability");
            NetworkStatus status = [reach currentReachabilityStatus];
            if (status == NotReachable) {
                [self.window.rootViewController showHint:@"服务器开了个小差" yOffset:0];

                
            } else if (status == ReachableViaWiFi) {
                NSLog(@"hostReachability ReachableViaWiFi");
            } else if (status == ReachableViaWWAN) {
                NSLog(@"hostReachability ReachableViaWWAN");
            }
        }
        
    }
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];

}
@end
