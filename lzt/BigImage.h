//
//  BigImage.h
//  ChatDemo-UI3.0
// 实现图片的点击放大和缩小。
//  Created by 黄伟强 on 2017/9/26.
//  Copyright © 2017年 黄伟强. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BigImage : NSObject

+(void)showImage:(UIImageView *)avatarImageView;
+(void)hideImage:(UITapGestureRecognizer*)tap;

@end
