//
//  UserData.h
//  lbs
//
//  Created by Roc on 15/8/19.
//  Copyright (c) 2015年 lebaos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserData : NSObject
@property(nonatomic, assign) NSString* id;//用户id

@property(nonatomic, copy) NSString *createDate;//用户信息创建时间
@property(nonatomic, copy) NSString *updataDate;//用户信息更新时间
@property(nonatomic, copy) NSString *userName;//登录名
@property(nonatomic, copy) NSString *name;//姓名
@property(nonatomic, copy) NSString *token;//token

+(void)setUserData:(NSDictionary *)dic;
+(UserData *)getUserData;
+(BOOL)isLogin;
+(void)clearUser;
@end
