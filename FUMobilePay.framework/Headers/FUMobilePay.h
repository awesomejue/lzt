//
//  FUMobilePay.h
//  FUMobilePay
//
//  Created by Crazz Mong on 12/18/14.
//  Copyright (c) 2014 Crazz Mong. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for FUMobilePay.
FOUNDATION_EXPORT double FUMobilePayVersionNumber;

//! Project version string for FUMobilePay.
FOUNDATION_EXPORT const unsigned char FUMobilePayVersionString[];

/**
 *版本更新状态
 * 0 -不需要更新 1-有新版本 2-强制更新
 */
typedef NS_ENUM(NSInteger, VersionStatus) {
    kVersionIsNew = 0,
    kVersionOptionalUpdate = 1,
    kVersionNeedUpdate = 2,
    kVersionError
};


@protocol FYPayDelegate <NSObject>
/***
 *支付成功后回调
 */
@required
-(void) payCallBack:(BOOL) success responseParams:(NSDictionary*) responseParams;

/***
 *微信支付成功后回调
 */
@required
-(void) fuWeiXinPayCallBackWithResponseParams:(NSDictionary*) responseParams;

///**
// * 监测到新版本回调
// */
//@optional
//-(void) checkNewVersionCode:(VersionStatus) code version:(NSString*)version updateMsg:(NSString*) updateMsg;
//
///**
// *下载完成sdk
// */
//@optional
//-(void) downloadSDKCallBack:(BOOL) success error:(NSString*) error;

@end

extern const NSString* KParamCardNo;
extern const NSString* KParamIdNo;
extern const NSString* KParamAccName;
extern const NSString* KParamMobileNoInBank;
extern const NSString* KParamMchntKey;

extern const NSString* KParamMchntCd;
extern const NSString* KParamMchntNm;
extern const NSString* KParamMobileNo;             //支付者的富友账户手机号/账户号
extern const NSString* KParamProductNm;
extern const NSString* KParamOrderId;              //富友支付订单号
extern const NSString* KParamOrderAmt;
extern const NSString* KParamOrderTm;
extern const NSString* KParamUserNo;

@interface FUMobilePay : NSObject
+(id) shareInstance;

/**
 * 支付接口
 * params须传入KParamMobileNo，KParamOrderNo，必填
 * 代理接收支付回调，商户key 必填
 */
-(void) payOrder:(NSDictionary*) params delete:(id<FYPayDelegate>)delete mchntKey:(NSString*) mchntKey;

-(void) mobilePay:(NSDictionary*)params delegate:(id<FYPayDelegate>)delegate ;
/**
 *随心富，金账户等服务器url页面专用接口
 *记住需要通过js传入需要的参数，商户名，订单号，手机号
 *url本身要调用bankCardPay来间接调用支付接口
 */
-(void) payOrderStartUrl:(NSString *)url delete:(UIViewController *)controller;



/**
 *微信支付接口
 *需传入
 */
-(void) weChatPay:(NSDictionary*)params delegate:(id<FYPayDelegate>)delegate ;

/*
 *向微信注册APPID
 *
 */
-(void) fuRegisterAppId:(NSString*)appId ;

/*! @brief 处理微信通过URL启动App时传递的数据
 *
 * 需要在 application:openURL:sourceApplication:annotation:或者application:handleOpenURL中调用。
 * @param url 微信启动第三方应用时传递过来的URL
 * @param delegate  WXApiDelegate对象，用来接收微信触发的消息。
 * @return 成功返回YES，失败返回NO。
 */
-(BOOL) fuHandleOpenURL:(NSURL *) url;
@end
