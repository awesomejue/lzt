//
//  HWCircleView.m
//  AnimationTest
//
//  Created by hwq on 2017/11/16.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "HWCircleView.h"

#define KHWCircleLineWidth 2.0f
#define KHWCircleFont [UIFont systemFontOfSize:10.0f]
#define KHWCircleColor [UIColor colorWithRed:255/255.0 green:0/255.0 blue:0/255.0 alpha:1]

@interface HWCircleView ()

@property (nonatomic, weak) UILabel *cLabel;
@property (nonatomic, weak) UILabel *yqnhLabel;

@end

@implementation HWCircleView
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.backgroundColor = [UIColor clearColor];
        
        //百分比标签
        UILabel *cLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.bounds.size.width/2 - 15, self.bounds.size.height/3, 30, 20)];
        cLabel.font = [UIFont systemFontOfSize:10.0f];
        cLabel.textColor = KHWCircleColor;
        cLabel.textAlignment = NSTextAlignmentCenter;
        
//        UILabel *yqnhLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y+self.bounds.size.height * 0.5, self.bounds.size.width, 50)];
//        yqnhLabel.font = KHWCircleFont;
//        yqnhLabel.text = @"预期年化收益";
//        yqnhLabel.textColor = KHWCircleColor;
//        yqnhLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:cLabel];
       // [self addSubview:yqnhLabel];
        self.cLabel = cLabel;
      //  self.yqnhLabel = yqnhLabel;
    }
    
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        //百分比标签
        UILabel *cLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y+self.bounds.size.height * 0.3, self.bounds.size.width, 50)];
        cLabel.font = [UIFont systemFontOfSize:30.0f];
        cLabel.textColor = KHWCircleColor;
        cLabel.textAlignment = NSTextAlignmentCenter;
        
        UILabel *yqnhLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y+self.bounds.size.height * 0.5, self.bounds.size.width, 50)];
        yqnhLabel.font = KHWCircleFont;
        yqnhLabel.text = @"预期年化收益";
        yqnhLabel.textColor = KHWCircleColor;
        yqnhLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:cLabel];
        [self addSubview:yqnhLabel];
        self.cLabel = cLabel;
        self.yqnhLabel = yqnhLabel;
    }
    
    return self;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    
    _cLabel.text = [NSString stringWithFormat:@"%d%%", (int)floor(progress * 100)];
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    //路径
    UIBezierPath *path1 = [[UIBezierPath alloc] init];
    //线宽
    path1.lineWidth = KHWCircleLineWidth;
    //颜色
    [[UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:237.0/255] set];
    //拐角
    path1.lineCapStyle = kCGLineCapRound;
    path1.lineJoinStyle = kCGLineJoinRound;
    //半径
    CGFloat radius1 = (MIN(rect.size.width, rect.size.height) - KHWCircleLineWidth) * 0.5;
    //画弧（参数：中心、半径、起始角度(3点钟方向为0)、结束角度、是否顺时针）
    [path1 addArcWithCenter:(CGPoint){rect.size.width * 0.5, rect.size.height * 0.5} radius:radius1 startAngle:3 * M_PI / 2 endAngle:3 * M_PI / 2 + 2 * M_PI   clockwise:YES];
    //连线
    [path1 stroke];
    
    //路径
    UIBezierPath *path = [[UIBezierPath alloc] init];
    //线宽
    path.lineWidth = KHWCircleLineWidth;
    //颜色
    [KHWCircleColor set];
    //拐角
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    //半径
    CGFloat radius = (MIN(rect.size.width, rect.size.height) - KHWCircleLineWidth) * 0.5;
    //画弧（参数：中心、半径、起始角度(3点钟方向为0)、结束角度、是否顺时针）
    [path addArcWithCenter:(CGPoint){rect.size.width * 0.5, rect.size.height * 0.5} radius:radius startAngle:3 * M_PI / 2 endAngle:3 * M_PI / 2 + 2 * M_PI   * _progress clockwise:YES];
    //连线
    [path stroke];
}

@end  
