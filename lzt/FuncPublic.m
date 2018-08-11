//
//  FuncPublic.m
//  MaiTian
//
//  Created by 谌 安 on 13-3-1.
//  Copyright (c) 2013年 MaiTian. All rights reserved.
//

#import "FuncPublic.h"
#import "Constants.h"

#import "WToast.h"
#import <sys/utsname.h>


FuncPublic * _funcPublic    =   nil;
@implementation FuncPublic
@synthesize spin;
@synthesize LoadImage;
@synthesize mView;
//初始化函数
+(FuncPublic*)SharedFuncPublic
{
    if( _funcPublic == nil )
    {
        _funcPublic =   [[FuncPublic alloc] init];
    }
    return _funcPublic;
}
#pragma mark 打开及关闭进度滚动条
-(void)StartActivityAnimation:(UIViewController*)target
{
    //废弃原来对象
    if( self.spin != nil )
    {
        [self.spin removeFromSuperview];
        self.spin   =   nil;
    }
    //创建指定风格的活动指示器视图。
    spin=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spin.color=[UIColor darkGrayColor];
    spin.center=CGPointMake(DEVW/2, DEVH/2);//位置
    [target.view addSubview:spin];
    //移动指定视图到最前端显示。
    [target.view bringSubviewToFront:self.spin];
    [self.spin startAnimating];//开始滚动效果
    
}
//停止滚动效果
-(void)StopActivityAnimation{
    [self.spin stopAnimating];
}

#pragma mark - 获取和保存用户信息到临时目录
/*
 *获得保存default信息
 *key:关键字
 */
+(id)GetDefaultInfo:(NSString*)_key
{
    //NSUserDefaults:轻量化的本地存储，用于存储数据量小的数据，如用户配置信息
    //standardUserDefaults：返回一个单例
    //objectForKey：根据关键字返回一个对象
    id temp = [[NSUserDefaults standardUserDefaults] objectForKey:_key];
    if(  temp == nil )
    {
        return nil;
    }
    return temp;
}

/*
 *保存default信息
 *srt:需保存的文字
 *key:关键字
 */
+(void)SaveDefaultInfo:(id)str Key:(NSString*)_key
{
    NSUserDefaults *standardUserDefault = [NSUserDefaults standardUserDefaults];
    str = [FuncPublic replaceIsNULL:str];//对对象分类整理
    [standardUserDefault setValue:str forKey:_key];
    //[standardUserDefault setObject:str forKey:_key];
    [standardUserDefault synchronize];//同步到磁盘。
}
/**

 */
+ (void)SaveTemp:(id)dic FileName:(NSString *)file {
    // 获取tmp目录
    NSString *tmpPath = NSTemporaryDirectory();
    NSString *filePath = [tmpPath stringByAppendingPathComponent:file];
    // 数组写入文件执行的方法
    [dic writeToFile:filePath atomically:YES];
}
+ (NSDictionary *)GetTemp:(NSString *)file {
    // 从文件中读取数据数组的方法
    // 获取tmp目录
    NSString *tmpPath = NSTemporaryDirectory();
    NSString *filePath = [tmpPath stringByAppendingPathComponent:file];
    NSDictionary *result = [NSDictionary dictionaryWithContentsOfFile:filePath];
    return result;
}
/*
 *针对字典类型整理。
 */
+(id)replaceIsNULL:(id)obj{
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dic =  [NSMutableDictionary dictionary];
        NSEnumerator *enumerator = [obj keyEnumerator];//关键字集合
        id key;
        //遍历
        while ((key = [enumerator nextObject])) {
            //判断关键字对应的值是否为空。
            if ([FuncPublic isEmpty:obj[key]]) {
                [dic setObject:@"" forKey:key];
            }else{
                [dic setObject:obj[key] forKey:key];//添加关键字和值。
            }
        }
        return dic;
    }else{
        return obj;
    }
}
//判断类是否为空
+(BOOL)isEmpty:(id)string{
    if (string == nil) {
        return YES;
    }
    if (string == NULL) {
        return YES;
    }
    
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    //如果字符串只有空格和换行符也视为空类
    if ([string isKindOfClass:[NSString class]] && [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
        return YES;
    } else {
        return NO;
    }
    
}
+ (NSString *)returnFirstWordWithString:(NSString *)str
{
    NSMutableString * mutStr = [NSMutableString stringWithString:str];
    
    //将mutStr中的汉字转化为带音标的拼音（如果是汉字就转换，如果不是则保持原样）
    CFStringTransform((__bridge CFMutableStringRef)mutStr, NULL, kCFStringTransformMandarinLatin, NO);
    //将带有音标的拼音转换成不带音标的拼音（这一步是从上一步的基础上来的，所以这两句话一句也不能少）
    CFStringTransform((__bridge CFMutableStringRef)mutStr, NULL, kCFStringTransformStripCombiningMarks, NO);
    if (mutStr.length >0) {
        //全部转换为大写    取出首字母并返回
        NSString * res = [[mutStr uppercaseString] substringToIndex:1];
        return res;
    }
    else
        return @"";
    
}
#pragma mark - 其它类型数据转换成字符串方法
//对象转string
+(NSString *)objectTostr:(id)obj{
    NSString *str = (NSString *)obj;
    str = str==nil?@"":str;
    str = (NSNull *)str == [NSNull null]?@"":str;
    if ([str isKindOfClass:[NSString class]]) {
        str = [str isEqualToString:@"null"]?@"":str;
    }
    str = [NSString stringWithFormat:@"%@",str];
    return str;
}
//+ (void)AFNetworkStatus{
//
//    //1.创建网络监测者
//    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
//
//    /*枚举里面四个状态  分别对应 未知 无网络 数据 WiFi
//     typedef NS_ENUM(NSInteger, AFNetworkReachabilityStatus) {
//     AFNetworkReachabilityStatusUnknown          = -1,      未知
//     AFNetworkReachabilityStatusNotReachable     = 0,       无网络
//     AFNetworkReachabilityStatusReachableViaWWAN = 1,       蜂窝数据网络
//     AFNetworkReachabilityStatusReachableViaWiFi = 2,       WiFi
//     };
//     */
//
//    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//        //这里是监测到网络改变的block  可以写成switch方便
//        //在里面可以随便写事件
//        switch (status) {
//            case AFNetworkReachabilityStatusUnknown:
//                [WToast showWithText: @"未知网络状态"];
//                break;
//            case AFNetworkReachabilityStatusNotReachable:
//                 [WToast showWithText: @"没有网络，请检查网络连接。"];
//                break;
//
//            case AFNetworkReachabilityStatusReachableViaWWAN:
//                 //[WToast showWithText: @"蜂窝数据网"];
//                break;
//
//            case AFNetworkReachabilityStatusReachableViaWiFi:
//               // WKNSLog(@"WiFi网络");
//
//                break;
//
//            default:
//                break;
//        }
//
//    }] ;
//}
//+ (void)downloadFJ:(NSString *) sURL viewController:(id)viewController{
//    //    //远程地址
//    //    NSURL *URL = [NSURL URLWithString:urlFJ];
//    //    //默认配置
//    //    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    //
//    //    //AFN3.0+基于封住URLSession的句柄
//    //    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
//    //
//    //    //请求
//    //    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
//    //
//    //    //下载Task操作
//    //    _downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
//    //
//    //        // @property int64_t totalUnitCount;     需要下载文件的总大小
//    //        // @property int64_t completedUnitCount; 当前已经下载的大小
//    //
//    //        // 给Progress添加监听 KVO
//    //        NSLog(@"%f",1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
//    //        // 回到主队列刷新UI
//    //        dispatch_async(dispatch_get_main_queue(), ^{
//    //            // 设置进度条的百分比
//    //
//    //            self.progressView.progress = 1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
//    //        });
//    //
//    //    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
//    //
//    //        //- block的返回值, 要求返回一个URL, 返回的这个URL就是文件的位置的路径
//    //
//    //        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//    //        NSString *path = [cachesPath stringByAppendingPathComponent:response.suggestedFilename];
//    //        return [NSURL fileURLWithPath:path];
//    //
//    //    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
//    //        //设置下载完成操作
//    //        // filePath就是你下载文件的位置，你可以解压，也可以直接拿来使用
//    //
//    //        NSString *imgFilePath = [filePath path];// 将NSURL转成NSString
//    //        [WToast showWithText:@"下载完成"];
//    //
//    //    }];
//
//    [[FuncPublic SharedFuncPublic]StartActivityAnimation:viewController];
//    //1.创建管理者对象
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    //2.确定请求的URL地址
//    NSURL *url = [NSURL URLWithString:sURL];
//
//    //3.创建请求对象
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//
//    //下载任务
//    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
//        //打印下载进度
//        // 给Progress添加监听 KVO
//        NSLog(@"%f",1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
//        // 回到主队列刷新UI
//        dispatch_async(dispatch_get_main_queue(), ^{
//            // 设置进度条的百分比
//
//            //  self.progressView.progress = 1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
//        });
//
//
//    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
//        //下载地址
//        NSLog(@"默认下载地址:%@",targetPath);
//
//        //- block的返回值, 要求返回一个URL, 返回的这个URL就是文件的位置的路径
//
//        NSFileManager *fileManager = [[NSFileManager alloc]init];
//        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//        // cachesPath = [cachesPath stringByAppendingPathComponent:@"download"];
//        NSString *path;
//        if (![[NSFileManager defaultManager] fileExistsAtPath:cachesPath]) {
//            [fileManager createDirectoryAtPath:cachesPath withIntermediateDirectories:YES attributes:nil error:nil];
//            path = [cachesPath stringByAppendingPathComponent:response.suggestedFilename];
//        }else {
//            path = [cachesPath stringByAppendingPathComponent:response.suggestedFilename];
//        }
//        return [NSURL fileURLWithPath:path];
//
//
//
//    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
//
//        //设置下载完成操作
//        // filePath就是你下载文件的位置，你可以解压，也可以直接拿来使用
//        [[FuncPublic SharedFuncPublic]StopActivityAnimation];
//        NSString *imgFilePath = [filePath path];// 将NSURL转成NSString
//        [WToast showWithText:@"下载完成"];
//        [self openDocxWithPath:imgFilePath viewController:viewController];
//
//
//    }];
//
//    //开始启动任务
//    [task resume];
//}
/**
 打开文件
 
 @param filePath 文件路径
 */
+(void)openDocxWithPath:(NSString *)filePath viewController:(id)viewController {
    UIDocumentInteractionController *doc= [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filePath]];
    doc.delegate = viewController;
    [doc presentPreviewAnimated:YES];
}
/***
 *字符串解析为json对象返回.
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
/***
 *NSData解析为json对象返回.
 */
+ (NSDictionary *)dictionaryWithJsonData:(NSData *)jsonData {
    if (jsonData == nil) {
        return nil;
    }
    //NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *temp = (NSDictionary *)jsonData;
    if ([temp isKindOfClass:[NSDictionary class]]) {
        return temp;
    }else {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&err];
        if(err) {
            NSLog(@"json解析失败：%@",err);
            return nil;
        }
        return dic;
    }
    
   
    
}
//获取时间标准格式
+ (NSString *)getTime:(NSString *)createTime {
//    NSString *year = [createTime substringToIndex:4];
//    NSString *month = [createTime substringWithRange:NSMakeRange(4, 2)];
//    NSString *day = [createTime substringWithRange:NSMakeRange(6, 2)];
//    NSString *hour = [createTime substringWithRange:NSMakeRange(8, 2)];
//    NSString *minute = [createTime substringWithRange:NSMakeRange(10, 2)];
//    NSString *second = [createTime substringWithRange:NSMakeRange(12, 2)];
//    NSString *time = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@", year,month,day,hour,minute,second];
    NSDateFormatter *inputFormatter= [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [inputFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *inputDate = [inputFormatter dateFromString:createTime];
    [inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *str = [inputFormatter stringFromDate:inputDate];
    return str;
}

+ (BOOL)isRightLoginPassword:(NSString *)str{
    NSString *regex = @"[a-zA-Z0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:str]) {
        return YES;
    }
    return NO;
}
/**
 *校验交易密码只能为6数字组合
 */
+ (BOOL)isRightJYPassword:(NSString *)str{
    NSString *regex = @"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:str]) {
        
        return YES;
    }
    return NO;
}
//正则表达式判断输入字符串是否为全数字用于手机号判断。
+ (BOOL) deptNumInputShouldNumber:(NSString *)str
{
    //NSString *regex = @"[0-9]*";
    NSString *regex = @"0123456789.-";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:str]) {
        return YES;
    }
    return NO;
}
//判断是否只有数字和小数点
+(BOOL)isOnlyhasNumberAndpointWithString:(NSString *)string{
    NSString * NUMBERS =  @"0123456789.";
    NSCharacterSet *cs=[[NSCharacterSet characterSetWithCharactersInString:NUMBERS] invertedSet];
    
    NSString *filter=[[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    return [string isEqualToString:filter];
    
}
+(NSString *)getTelephone:(NSString *)telephone {
    NSString *str = [NSString stringWithFormat:@"%@****%@", [telephone substringToIndex:3],[telephone substringWithRange:NSMakeRange(7, 4)]];
    return str;
}
+(NSString *)getDate:(NSString *)date {
    if ([date isEqualToString:@"month"]) {
        return @"个月";
    }else if([date isEqualToString:@"day"]){
        return @"天";
    }else {
        return nil;
    }
}
//得到数字千分位逗号分隔
+(NSString *)countNumAndChangeformat:(NSString *)num
{
    int count = 0;
    long long int a = num.longLongValue;
    while (a != 0)
    {
        count++;
        a /= 10;
    }
    NSMutableString *string = [NSMutableString stringWithString:num];
    NSMutableString *newstring = [NSMutableString string];
    while (count > 3) {
        count -= 3;
        NSRange rang = NSMakeRange(string.length - 3, 3);
        NSString *str = [string substringWithRange:rang];
        [newstring insertString:str atIndex:0];
        [newstring insertString:@"," atIndex:0];
        [string deleteCharactersInRange:rang];
    }
    [newstring insertString:string atIndex:0];
    return newstring;
}
//
+(NSString *)imageEncode:(NSString *)image {
    //NSString *image =[NSString stringWithFormat:@"%@%@",ROOTSERVER, NewsDatas[indexPath.row][@"coverImage"]];
    image = [image stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    return image;
}
// 获取设备型号然后手动转化为对应名称
+ (NSString *)getDeviceName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    // 日行两款手机型号均为日本独占，可能使用索尼FeliCa支付方案而不是苹果支付
    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"国行、日版、港行iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,2"])    return @"港行、国行iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone9,3"])    return @"美版、台版iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,4"])    return @"美版、台版iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone10,1"])   return @"国行(A1863)、日行(A1906)iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,4"])   return @"美版(Global/A1905)iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,2"])   return @"国行(A1864)、日行(A1898)iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,5"])   return @"美版(Global/A1897)iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,3"])   return @"国行(A1865)、日行(A1902)iPhone X";
    if ([deviceString isEqualToString:@"iPhone10,6"])   return @"美版(Global/A1901)iPhone X";
    
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([deviceString isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([deviceString isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    if ([deviceString isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (LTE)";
    if ([deviceString isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9";
    if ([deviceString isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9";
    if ([deviceString isEqualToString:@"iPad6,11"])    return @"iPad 5 (WiFi)";
    if ([deviceString isEqualToString:@"iPad6,12"])    return @"iPad 5 (Cellular)";
    if ([deviceString isEqualToString:@"iPad7,1"])     return @"iPad Pro 12.9 inch 2nd gen (WiFi)";
    if ([deviceString isEqualToString:@"iPad7,2"])     return @"iPad Pro 12.9 inch 2nd gen (Cellular)";
    if ([deviceString isEqualToString:@"iPad7,3"])     return @"iPad Pro 10.5 inch (WiFi)";
    if ([deviceString isEqualToString:@"iPad7,4"])     return @"iPad Pro 10.5 inch (Cellular)";
    
    if ([deviceString isEqualToString:@"AppleTV2,1"])    return @"Apple TV 2";
    if ([deviceString isEqualToString:@"AppleTV3,1"])    return @"Apple TV 3";
    if ([deviceString isEqualToString:@"AppleTV3,2"])    return @"Apple TV 3";
    if ([deviceString isEqualToString:@"AppleTV5,3"])    return @"Apple TV 4";
    
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    
    return deviceString;
}
+(NSString *)getSystemVersion {
    NSString *version = [UIDevice currentDevice].systemVersion;
    return version;
}
@end

