// 用于设置按钮的圆角
//  UIButton+CornerRadium.m
//  lzt
//
//  Created by hwq on 2017/11/17.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "UIButton+CornerRadium.h"

@implementation UIButton (CornerRadium)

- (void)setCornerRadium {
    self.layer.cornerRadius = 5;
}
@end
