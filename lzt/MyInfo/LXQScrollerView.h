//
//  LXQScrollerView.h
//  memuDemo
//
//  Created by Jerry on 2017/7/5.
//  Copyright © 2017年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXQScrollerView : UIView
//保存父类控制器
@property (nonatomic, strong) UIViewController *con;
@property (nonatomic, assign) NSString *hborjxq;
- (instancetype)initWithFrame:(CGRect)frame
           titleArray:(NSArray *)array;



@end
