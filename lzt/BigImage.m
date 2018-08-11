//
//  BigImage.m
//  ChatDemo-UI3.0
//
//  Created by 黄伟强 on 2017/9/26.
//  Copyright © 2017年 黄伟强. All rights reserved.
//

#import "BigImage.h"

@implementation BigImage

static CGRect oldframe;

+(void)showImage:(UIImageView *)avatarImageView
{
    
    UIImage *image = avatarImageView.image;
    if (!image) {
        
    }else {
        
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake( 0,  0,  [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    // 变换坐标系统
    oldframe = [avatarImageView convertRect:avatarImageView.bounds toView:window];
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.alpha = 0;
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:oldframe];
    imageView.image = image;
    imageView.tag = 1;
    [backgroundView addSubview:imageView];
    [window addSubview:backgroundView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [backgroundView addGestureRecognizer: tap];
    
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame=CGRectMake(0,([UIScreen mainScreen].bounds.size.height-image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width)/2, [UIScreen mainScreen].bounds.size.width, image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width);
        backgroundView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    }
    
}

+(void)hideImage:(UITapGestureRecognizer*)tap
{
    UIView *backgroundView = tap.view;//获取tap手势所在的视图
    // 查找指定tag 的子视图
    UIImageView *imageView = (UIImageView*)[tap.view viewWithTag:1];
    //动画
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame = oldframe;
        backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [backgroundView removeFromSuperview];
    }];
    
    
}

@end
