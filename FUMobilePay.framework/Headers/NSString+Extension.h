//
//  NSString+Extension.h
//  SuiXinFu
//
//  Created by MengHX on 12/6/12.
//  Copyright (c) 2012 www.fuiou.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extension)
-(NSString *)MD5String;
-(NSString *)trimWhitespace;
-(NSString *)urlEncoding;
-(NSString *)toHexString;
+(NSString*)getFileMD5WithPath:(NSString*)path;
@end
