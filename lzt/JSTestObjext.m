//
//  JSTestObjext.m
//  lzt
//
//  Created by hwq on 2018/1/12.
//  Copyright © 2018年 hwq. All rights reserved.
//

#import "JSTestObjext.h"

@implementation JSTestObjext

- (void)gotoInvestFragment{
    NSLog(@"CallOCFunction");
}

- (void)CallOCFunctionFirstParameter:(NSString *)parameter {
    NSLog(@"CallOCFunctionFirstParameter:%@", parameter);
}
- (void)CallOCFunctionFirstParameter:(NSString *)parameter1 SecondParameter:(NSString *)parameter2 {
    NSLog(@"CallOCFunctionFirstParameter:%@ SecondParameter:%@", parameter1, parameter2);
}
@end
