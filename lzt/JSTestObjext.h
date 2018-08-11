//
//  JSTestObjext.h
//  lzt
//
//  Created by hwq on 2018/1/12.
//  Copyright © 2018年 hwq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol JSTestObjextProtocol <JSExport>

- (void)gotoInvestFragment;
-(void)CallOCFunctionFirstParameter:(NSString *)parameter;
- (void)CallOCFunctionFirstParameter:(NSString *)parameter1 SecondParameter:(NSString *)parameter2;
@end

@interface JSTestObjext : NSObject<JSTestObjextProtocol>


@end
