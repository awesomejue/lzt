//
//  CountDownView.m
//  lzt
//
//  Created by hwq on 2018/1/17.
//  Copyright © 2018年 hwq. All rights reserved.
//

#import "CountDownView.h"

@implementation CountDownView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIButton *b = [[UIButton alloc]initWithFrame:frame];
        [b setTitle:@"跳过3" forState:UIControlStateNormal];
        [b setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [b setBackgroundColor:[UIColor grayColor]];
        b.layer.cornerRadius = frame.size.width / 2;
        
        self.btn = b;
        [self addSubview:b];
    }
    return self;
}
@end
