//
//  TGJLScrollView.h
//  lzt
//
//  Created by hwq on 2018/3/8.
//  Copyright © 2018年 hwq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TGJLScrollView : UIView


//保存父类控制器
@property (nonatomic, strong) UIViewController *con;

- (instancetype)initWithFrame:(CGRect)frame
                   titleArray:(NSArray *)array;

@end
