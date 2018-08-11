//
//  ProjectCell.m
//  lzt
//
//  Created by hwq on 2017/10/23.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "ProjectCell.h"
#import "ProjectModel.h"
@implementation ProjectCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.mainView.layer.cornerRadius = 5;
    self.mainView.layer.masksToBounds = true;
    self.leftImage.opaque = 0.5;
   // [self addTimer];
    
}

- (void)updateProjectCell :(ProjectModel *)model {
    
}
- (void)addTimer
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.008f target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}
- (void)timerAction
{
        _progressView.progress += 0.001;
        if (_progressView.progress >= _count) {
            [self removeTimer];
            NSLog(@"完成");
        }
}

- (void)removeTimer
{
    [_timer invalidate];
    _timer = nil;
}
@end
