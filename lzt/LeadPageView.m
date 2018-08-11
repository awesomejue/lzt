//
//  LeadPageView.m
//  
//
//  Created by 金鼎 on 14-11-28.
//  Copyright (c) 2014年 金鼎. All rights reserved.
//

#import "LeadPageView.h"

@implementation LeadPageView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        //自身设置
        self.showsHorizontalScrollIndicator = NO;
        //创建引导页图片数组
        NSArray * imageNamesArr = @[@"引导页1@3x",@"引导页2@3x",@"引导页3@3x"];
        //NSArray * imageNamesArr = @[@"1242"];
        CGFloat _width = self.frame.size.width;
        CGFloat _height = self.frame.size.height;
        self.pagingEnabled = YES;
        [self setContentSize:CGSizeMake(imageNamesArr.count*_width, 0)];
        [self setContentOffset:CGPointMake(0, 0)];
        //创建图片
        for (int i = 0; i<imageNamesArr.count; i++) {
            UIImage * image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageNamesArr[i] ofType:@"png"]];
            UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(_width*i, 0, _width, _height)];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.image = image;
            [self addSubview:imageView];
            
            if (i == imageNamesArr.count-1) {
                UIPanGestureRecognizer *swipe = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(btnClick:)];
               // swipe.direction = UISwipeGestureRecognizerDirectionLeft;
                [imageView addGestureRecognizer:swipe];
              //  UIImage * btnImage = [UIImage imageNamed:@"icon"];
//                UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                btn.frame = CGRectMake(Screen_Width, Screen_Height, Screen_Width, Screen_Height );
//                btn.backgroundColor = [UIColor redColor];
//                [btn setTitleColor:Main_Color forState:UIControlStateNormal];
//                //[btn setBackgroundImage:btnImage forState:UIControlStateNormal];
//                [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
                imageView.userInteractionEnabled = YES;
               // [imageView addSubview:btn];
            }
        }
    }
    return self;
}
//点击事件
- (void)btnClick:(id )sender{
    [UIView animateWithDuration:0.5 animations:^{
       // [self removeFromSuperview];
        self.frame = CGRectMake(-Screen_Width, 0, Screen_Width, Screen_Height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"tabBarAppear" object:nil];
}
@end
