//
//  HWProgressView.h
//  AnimationTest
//
//  Created by hwq on 2017/11/16.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HWProgressView : UIView
@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, assign) BOOL isGray;

@property (nonatomic, strong) UIProgressView *progressView;
@end
