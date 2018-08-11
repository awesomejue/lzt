//
//  NSData+base64.h
//  SuiXinFu
//
//  Created by MengHX on 4/7/13.
//  Copyright (c) 2013 www.fuiou.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Base64)

void *CDVNewBase64Decode(
                         const char* inputBuffer,
                         size_t    length,
                         size_t    * outputLength);

char *CDVNewBase64Encode(
                         const void* inputBuffer,
                         size_t    length,
                         bool      separateLines,
                         size_t    * outputLength);


+ (NSData*)dataFromBase64String:(NSString*)aString;
+ (NSData *)dataWithBase64EncodedString:(NSString *)string;
- (NSString *)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth;
- (NSString *)base64EncodedString;
+(NSData *)dataFromHexString:(NSString *)string;
-(NSString*)hexString;
@end
