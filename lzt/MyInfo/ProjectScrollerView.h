//
//  LXQScrollerView.h
//  memuDemo
//
//  Created by Jerry on 2017/7/5.
//  Copyright © 2017年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProjectScrollerView : UIView
//保存父类控制器
@property (nonatomic, strong) UIViewController *con;
- (instancetype)initWithFrame:(CGRect)frame
           titleArray:(NSArray *)array;



@end
