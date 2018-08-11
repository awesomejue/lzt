//
//  HWProgressView.m
//  AnimationTest
//
//  Created by hwq on 2017/11/16.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "HWProgressView.h"

#define KProgressBorderWidth 1.0f
#define KProgressPadding 1.0f //左间距
#define ImageHeight 10 //图片高度
#define KProgressColor [UIColor colorWithRed:253.0/255 green:111.0/255 blue:127.0/255 alpha:1]

@interface HWProgressView ()

@property (nonatomic, strong) UIView *tView;
@property (nonatomic, strong) UIImageView *image;



@end

@implementation HWProgressView
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        UIView *bgView = [[UIView alloc]initWithFrame:self.bounds];
       
        //边框
        UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(KProgressPadding, ImageHeight, Screen_Width * 0.46, bgView.frame.size.height-ImageHeight)];
        borderView.layer.cornerRadius = self.bounds.size.height * 0.14;
        borderView.layer.masksToBounds = YES;
        //borderView.backgroundColor = [UIColor colorWithRed:239.0 /255 green:239.0 /255 blue:239.0 /255 alpha:1];
        borderView.backgroundColor = [UIColor whiteColor];
        //borderView.layer.borderColor = [KProgressColor CGColor];
        //borderView.layer.borderWidth = KProgressBorderWidth;
        [bgView addSubview:borderView];
        //进度
        UIView *tView = [[UIView alloc] init];
    //    if (_isGray) {
        //    tView.backgroundColor = [UIColor lightGrayColor];
       // }else {
            tView.backgroundColor = KProgressColor;
      //  }
        tView.layer.cornerRadius = self.bounds.size.height  * 0.19;
        tView.layer.masksToBounds = YES;
        [bgView addSubview:tView];
        self.tView = tView;
        
        [self addSubview:bgView];
        _progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.frame = CGRectMake(0, ImageHeight+2, Screen_Width * 0.46, 10);
        _progressView.frame = borderView.frame;
        _progressView.transform = CGAffineTransformMakeScale(1.0f, 3.0f);
        _progressView.layer.cornerRadius = 5;
        _progressView.layer.masksToBounds = YES;
        _progressView.trackImage = [UIImage imageNamed:@"backg.png"];
        _progressView.progressImage = [UIImage imageNamed:@"rect.png"];
        _progressView.backgroundColor = [UIColor clearColor];
        [self addSubview:_progressView];
        
        UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(5, ImageHeight, ImageHeight+5, ImageHeight+5)];
        image.contentMode = UIViewContentModeScaleAspectFill;
        image.image = [UIImage imageNamed:@"project.png"];
        [self addSubview:image];
        [self bringSubviewToFront:image];
        self.image = image;
        
    }
    
    return self;
}
//- (instancetype)initWithFrame:(CGRect)frame
//{
//    if (self = [super initWithFrame:frame]) {
//        UIView *bgView = [[UIView alloc]initWithFrame:self.bounds];
//        UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ImageHeight, ImageHeight)];
//        image.image = [UIImage imageNamed:@"Identification.png"];
//        [bgView addSubview:image];
//        //边框
//        UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(KProgressPadding, ImageHeight, self.bounds.size.width-ImageHeight-KProgressPadding, self.bounds.size.height-ImageHeight)];
//        borderView.layer.cornerRadius = self.bounds.size.height * 0.2;
//        borderView.layer.masksToBounds = YES;
//        borderView.backgroundColor = [UIColor lightGrayColor];
//        //borderView.layer.borderColor = [KProgressColor CGColor];
//        //borderView.layer.borderWidth = KProgressBorderWidth;
//        [bgView addSubview:borderView];
//
//        //进度
//        UIView *tView = [[UIView alloc] init];
//        tView.backgroundColor = KProgressColor;
//        tView.layer.cornerRadius = self.bounds.size.height  * 0.2;
//        tView.layer.masksToBounds = YES;
//        [bgView addSubview:tView];
//        self.tView = tView;
//        self.image = image;
//        [self addSubview:bgView];
//    }
//
//    return self;
//}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    
   // CGFloat margin = KProgressBorderWidth + KProgressPadding;

//    CGFloat maxWidth = self.bounds.size.width - ImageHeight;
//    CGFloat heigth = self.bounds.size.height - ImageHeight;
//    if (progress == 1) {
//        _tView.frame = CGRectMake(KProgressPadding, ImageHeight-5, self.bounds.size.width-ImageHeight, heigth);
//
//        _image.frame = CGRectMake(self.bounds.size.width-ImageHeight+5, 2, ImageHeight-8, ImageHeight-8);
//    }else {
//
//        _tView.frame = CGRectMake(KProgressPadding, ImageHeight-5, maxWidth * progress, heigth);
//        //_progressView.progress = progress;
//        //_progressView.progressTintColor = KProgressColor;
//        _image.frame = CGRectMake(maxWidth * progress+5, 2, ImageHeight-8, ImageHeight-8);
//    }
   // CGFloat margin = 0;
  //  CGFloat maxWidth = self.bounds.size.width - margin * 2;
 //   CGFloat heigth = self.bounds.size.height - ImageHeight;
    
   // _tView.frame = CGRectMake(KProgressPadding, ImageHeight, maxWidth * progress, heigth);
    
    _progressView.progress = progress;
    _progressView.progressTintColor = KProgressColor;
    if (progress == 0) {
        _image.frame = CGRectMake(_progressView.frame.size.width * progress+KProgressPadding, ImageHeight-6, ImageHeight+5 ,ImageHeight+5);
        
    }else if(progress == 1){
        _image.frame = CGRectMake(_progressView.frame.size.width * progress-10, ImageHeight-6, ImageHeight+5, ImageHeight+5);
    }else if(progress > 0.9 &&progress < 1){
        _image.frame = CGRectMake(_progressView.frame.size.width * progress-12, ImageHeight-6, ImageHeight+5, ImageHeight+5);
    }else {
        _image.frame = CGRectMake(_progressView.frame.size.width * progress-3, ImageHeight-6, ImageHeight+5, ImageHeight+5);
        
    }
   
}



@end
