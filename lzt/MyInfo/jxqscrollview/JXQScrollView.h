//
//  JXQScrollView.h
//  lzt
//
//  Created by hwq on 2017/12/1.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JXQScrollView : UIView
//保存父类控制器
@property (nonatomic, strong) UIViewController *con;
@property (nonatomic, assign) NSString *hborjxq;
- (instancetype)initWithFrame:(CGRect)frame
                   titleArray:(NSArray *)array;
@end
