//
//  HKJHScrollerView.h
//  lzt
//
//  Created by hwq on 2017/11/21.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HKJHScrollerView : UIView

//保存父类控制器
@property (nonatomic, strong) UIViewController *con;
@property (nonatomic, assign) NSString *hborjxq;
- (instancetype)initWithFrame:(CGRect)frame
                   titleArray:(NSArray *)array;

@property (nonatomic, assign) double repayedCorpus;//已收本金
@property (nonatomic, assign) double repayedInterest;//已收利息

@end
