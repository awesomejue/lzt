//
//  Constants.h
//  WeChat
//
//  Created by Siegrain on 16/3/28.
//  Copyright © 2016年 siegrain. weChat. All rights reserved.
//

//按比例获取高度
#define WGiveHeight(HEIGHT)                                                    \
  HEIGHT * [UIScreen mainScreen].bounds.size.height / 568.0
//按比例获取宽度
#define WGiveWidth(WIDTH)                                                      \
  WIDTH * [UIScreen mainScreen].bounds.size.width / 320.0
// RGB色值
#define iPhone4s    ([[UIScreen mainScreen] bounds].size.height == 480)
#define iPhone5     ([[UIScreen mainScreen] bounds].size.height == 568)
#define iPhone6     ([[UIScreen mainScreen] bounds].size.height == 667)
#define iPhone6Plus ([[UIScreen mainScreen] bounds].size.height == 736)
#define iPhoneX     ([[UIScreen mainScreen] bounds].size.height == 812)
//  Constants.h
//  用于定义常量


//内部版本号
#define InnerVersion @"203"
//屏幕宽度
#define DEVW [[UIScreen mainScreen] bounds].size.width
//屏幕高度
#define DEVH [[UIScreen mainScreen] bounds].size.height


#define DATA(X)	[X dataUsingEncoding:NSUTF8StringEncoding]
#define DocumentsPath [NSHomeDirectory() stringByAppendingString:@"/Documents/"]

#define topHeight 44//导航栏高度
#define bvHeight 50//标签栏高度
#define PageSize 20
#define kPageSize @"10"

#define TextLength 140

#define kEmpty @"以上不能为空"
#define kMessage @"请求失败"
#define kDataNone @"暂无数据"
#define kNetwork @"请检查网络连接"
#define kTimedOut @"请求超时"

#define mSMRZ @"mSMRZ"
#define mUserInfo @"mUserInfo"
#define mFirstLaunch @"firstLaunuch"
#define mSaveAccount @"SaveAccount"//记住帐号和密码
#define userIsLogin @"userIsLogin"
#define mSavePassword @"SavePassword"
#define mRemind @"remind" //消息提醒方式：声音、震动还是都有
#define mHomeViewController @"mHomeViewController"
#define mNewsViewController @"mNewsViewController"
#define isCheckVersion @"checkVersion"

#define TagComm 50
#define Tag100 100
#define Tag300 300
#define Tag500 500
#define Tag700 700
#define Tag900 900

#define BodyColor [UIColor colorWithRed:47/255.0 green:175/255.0 blue:235/255.0 alpha:1]
//灰色值
#define mGrayColor [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1]

#define TitleColor [UIColor colorWithRed:180/255.0 green:0/255.0 blue:23/255.0 alpha:1]
#define dBlackColor [UIColor colorWithRed:49/255.0 green:49/255.0 blue:49/255.0 alpha:1]
#define mWhiteColor [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1]








#import <UIKit/UIKit.h>

@interface Constants : NSObject
+ (UIColor*)themeColor;
@end
