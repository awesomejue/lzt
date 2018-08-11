//
//  AppDelegate.h
//  lzt
//
//  Created by 黄伟强 on 2017/10/16.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
//推送
#import <GTSDK/GeTuiSdk.h>     // GetuiSdk头文件应用

// iOS10 及以上需导入 UserNotifications.framework
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

/// 个推开发者网站中申请App时，注册的AppId、AppKey、AppSecret
//#define kGtAppId           @"be3PKgNcj57jIxEVAHO5u8" //测试
//#define kGtAppKey          @"IUckWguxsD9V1eBa5qIecA"
//#define kGtAppSecret       @"xc0RbhaSnI99CVfXSJrih1"

#define kGtAppId           @"F55jxYdSa387Kd1IubtIW7" //生产
#define kGtAppKey          @"EuoOakUWFM9BDeRPV2xDB2"
#define kGtAppSecret       @"byDoDms6hJADpQKhH6YeZA"

@interface AppDelegate : UIResponder <UIApplicationDelegate,GeTuiSdkDelegate, UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) int lastPayloadIndex;
@end

