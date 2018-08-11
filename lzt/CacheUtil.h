//
//  CacheUtil.h
//  lzt
//
//  Created by hwq on 2017/11/20.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^cleanCacheBlock)();

@interface CacheUtil : NSObject

+(long long)fileSizeAtPath:(NSString *)filePath;
+(float)folderSizeAtPath;
+(void)cleanCache:(cleanCacheBlock)block;
// 获取Caches目录路径
+ (NSString *)getCachesPath;
@end
