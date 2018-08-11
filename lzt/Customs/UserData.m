//
//  UserData.m
//  lbs
//
//  Created by Roc on 15/8/19.
//  Copyright (c) 2015年 lebaos. All rights reserved.
//

#import "UserData.h"


@implementation UserData

@synthesize  id;//用户id
@synthesize createDate;//用户信息创建时间
@synthesize updataDate;//用户信息更新时间
@synthesize userName;//用户名

//保存用户信息字典集合。
+(void)setUserData:(NSDictionary *)dic{
    [FuncPublic SaveDefaultInfo:dic Key:mUserInfo];
}
+(UserData *)getUserData{
    NSDictionary *dic = [FuncPublic GetDefaultInfo:mUserInfo];
    UserData *data = nil;
    if (dic != nil) {
        data = [[UserData alloc] init];
        data.id = [FuncPublic objectTostr:dic[@"id"]];
        
    }
    return data;
}

+(BOOL)isLogin{
    NSString *s = [FuncPublic GetDefaultInfo:userIsLogin];
    //只有值为@"YES"时才有判断登陆
    if ([s isEqualToString:@"YES"]) {
        return YES;
    }else {
        return NO;
    }
    //mUserInfo自定义的常量
    //    NSDictionary *dic = [FuncPublic GetDefaultInfo:mUserInfo];
    //    if (dic == nil) {
    //        return NO;
    //    }else{
    //        return YES;
    //    }
}
+(void)clearUser{
    [FuncPublic SaveDefaultInfo:nil Key:mUserInfo];
}
@end
