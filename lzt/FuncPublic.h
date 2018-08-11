//
//  FuncPublic.h


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import <QuartzCore/QuartzCore.h>

@interface FuncPublic : NSObject
{
    UIActivityIndicatorView* spin;          //用于创建进度滚动条
    UIImageView*            LoadImage;
    UIView  *mView ;
}
@property(nonatomic,strong)UIActivityIndicatorView* spin;
@property(nonatomic,retain)UIImageView*  LoadImage;
@property(nonatomic,retain)UIView *  mView ;
@property(nonatomic, strong)NSString *rootserver;
@property(nonatomic, strong)NSString *root;
+(FuncPublic*)SharedFuncPublic;

#pragma mark 打开及关闭风火轮
-(void)StartActivityAnimation:(UIViewController*)target;
-(void)StopActivityAnimation;
#pragma mark 打开及关闭风火轮   end------------
//自己添加的公共方法。用于post请求载入数据


#pragma mark- defaultinfo
//保存default信息 srt:需保存的文字 *key:关键字
+(void)SaveDefaultInfo:(id)str Key:(NSString*)_key;
//获得保存default信息
+(id)GetDefaultInfo:(NSString*)_key;
//保存临时文件到temp目录
+(void)SaveTemp:(id)dic FileName:(NSString *)file;
+(NSDictionary *)GetTemp:(NSString *)file;
//判断是否为空
+(BOOL)isEmpty:(id)str;
//对象转string
+(NSString *)objectTostr:(id)obj;
//检查网络情况
//+ (void)AFNetworkStatus;
//获取拼音首字母
+ (NSString *)returnFirstWordWithString:(NSString *)str;
//下载附件

//
//正则表达式判断输入字符串是否为全数字用于手机号判断。
+ (BOOL) deptNumInputShouldNumber:(NSString *)str;
/**
 *校验登录密码只能为6～16位字母和数字组合
 */
+ (BOOL)isRightLoginPassword:(NSString *)str;
/**
 *校验交易密码只能为6数字组合
 */
+ (BOOL)isRightJYPassword:(NSString *)str;
/***
 *判读只存在数字和小数点
 */
+(BOOL)isOnlyhasNumberAndpointWithString:(NSString *)string;
/**
 *字符串解析为json对象返回.
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
/***
 *NSData解析为json对象返回.
 */
+ (NSDictionary *)dictionaryWithJsonData:(NSData *)jsonData;
/***
 *解析时间,这是时间格式为一个字符串没有分隔符，所以解析为一个有分隔符的字符串.
 */
+ (NSString *)getTime:(NSString *)createTime;
/***
 *得到一个中间有*字符的手机号码格式字符串
 */
+(NSString *)getTelephone:(NSString *)telephone;
/**
 *得到month、day对应的中文
 */
+(NSString *)getDate:(NSString *)date;
/***
 *得到数字千分位分隔
 */
+(NSString *)countNumAndChangeformat:(NSString *)num;
/***
 *给图片url序列化，避免中文地址无法加载
 *
 */
+(NSString *)imageEncode:(NSString *)image;
// 获取设备型号然后手动转化为对应名称
+ (NSString *)getDeviceName;
+ (NSString *)getSystemVersion;
@end
