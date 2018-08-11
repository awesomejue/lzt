//
//  NetManager.h
//  网络请求guan li
//

//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface NetManager : NSObject
//调度afnetworking请求
/**
 *检测网络状态
 */
typedef void (^AFNetworkStatusBlock)(AFNetworkReachabilityStatus status);
//请求成功
typedef void(^AFSuccessedBlock)(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject);
//请求失败
typedef void(^AFFailedBlock)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error);

typedef void(^AFconstructingBodyBlock)(id<AFMultipartFormData> _Nonnull formData);
/**
 *post请求数据
 */
//对外暴露类方法,根据请求地址请求数据
+(void)requestWithUrlString:(NSString *_Nullable)urlString andDic:(NSDictionary *_Nullable)dic finished:(AFSuccessedBlock _Nullable )finishedBlock failed:(AFFailedBlock _Nullable )failedBlock;
/**
 *get请求数据不带参数
 */
//对外暴露类方法,根据请求地址请求数据
+(void)GetRequestWithUrlString:(NSString *_Nullable)urlString finished:(AFSuccessedBlock _Nullable )finishedBlock failed:(AFFailedBlock _Nullable )failedBlock;
/***
 *get请求带参数
 */
+(void)GetRequestWithUrlString:(NSString *)urlString andDic:(NSDictionary *)dic finished:(AFSuccessedBlock)finishedBlock failed:(AFFailedBlock)failedBlock;
/**
 *检测网络状态
 */
+(void)NetworkStatus:(AFNetworkStatusBlock _Nullable )statusBlock;
/**
 *上传图片
 */
+(void)uploadImageWithImage:(UIImage *_Nullable)image WithUrlString:(NSString *_Nullable)urlString constructBody:(AFconstructingBodyBlock _Nullable)constructBlock finished:(AFSuccessedBlock _Nullable )finishedBlock failed:(AFFailedBlock _Nullable )failedBlock;
@end
