//
//  CalculaterView.m
//  lzt
//
//  Created by hwq on 2017/11/17.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "CalculaterView.h"
#import "UIButton+CornerRadium.h"
@implementation CalculaterView
//初始化工作
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _calView.layer.cornerRadius = 10;
        _calView.layer.masksToBounds = true;
        [_calBtn setCornerRadium];
    }
    return self;
}
- (IBAction)calBtn:(id)sender {
    
}
- (IBAction)closeTouched:(id)sender {
    
}
- (IBAction)hidekeyboard:(id)sender {
    [_money resignFirstResponder];
}
- (IBAction)closeClicked:(id)sender {
    [UIView animateWithDuration:0.5 animations:^{
        [self removeFromSuperview];
    }];
}

@end
