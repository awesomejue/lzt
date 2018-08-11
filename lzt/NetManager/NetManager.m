//
//  NetManager.m
//  
//

//

#import "NetManager.h"

@implementation NetManager
//post
//下载数据请求的封装方法
+(void)requestWithUrlString:(NSString *)urlString andDic:(NSDictionary *)dic finished:(AFSuccessedBlock)finishedBlock failed:(AFFailedBlock)failedBlock{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 15.0f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    [manager POST:urlString parameters:dic progress:nil success:finishedBlock failure:failedBlock];
   
}
//get不带参数
//下载数据请求的封装方法
+(void)GetRequestWithUrlString:(NSString *)urlString  finished:(AFSuccessedBlock)finishedBlock failed:(AFFailedBlock)failedBlock{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 15.0f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    [manager GET:urlString parameters:nil progress:nil success:finishedBlock failure:failedBlock];
    
}
//get带参数
//下载数据请求的封装方法
+(void)GetRequestWithUrlString:(NSString *)urlString andDic:(NSDictionary *)dic finished:(AFSuccessedBlock)finishedBlock failed:(AFFailedBlock)failedBlock{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 15.0f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    [manager GET:urlString parameters:dic progress:nil success:finishedBlock failure:failedBlock];
    
}
//

+(void)uploadImageWithImage:(UIImage *)image WithUrlString:(NSString *_Nullable)urlString constructBody:(AFconstructingBodyBlock)constructBlock finished:(AFSuccessedBlock)finishedBlock failed:(AFFailedBlock)failedBlock {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //接收类型不一致请替换一致text/html或别的
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                         @"text/html",
                                                         @"image/jpeg",
                                                         @"image/png",
                                                         @"application/octet-stream",
                                                         @"text/json",
                                                         @"text/plain",
                                                         nil ];
   // [manager.requestSerializer  setValue:@"http://www.guild.com" forHTTPHeaderField:@"Origin"];
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 15.0f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    [manager POST:urlString parameters:nil constructingBodyWithBlock:constructBlock progress:nil success:finishedBlock failure:failedBlock];
}

+ (void)NetworkStatus:(AFNetworkStatusBlock)statusBlock {
    //1.创建网络监测者
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    /*枚举里面四个状态  分别对应 未知 无网络 数据 WiFi
     typedef NS_ENUM(NSInteger, AFNetworkReachabilityStatus) {
     AFNetworkReachabilityStatusUnknown          = -1,      未知
     AFNetworkReachabilityStatusNotReachable     = 0,       无网络
     AFNetworkReachabilityStatusReachableViaWWAN = 1,       蜂窝数据网络
     AFNetworkReachabilityStatusReachableViaWiFi = 2,       WiFi
     };
     */
    [manager setReachabilityStatusChangeBlock:statusBlock];
    [manager startMonitoring];
}
@end
