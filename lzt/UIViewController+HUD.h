/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import <UIKit/UIKit.h>

@interface UIViewController (HUD)
/*网络加载调用*/
- (void)showHudInView:(UIView *)view hint:(NSString *)hint;
/*隐藏hud*/
- (void)hideHud;
/*弹出提示带文字图片*/
- (void)showHint:(NSString *)hint;
/*弹出提示只有文字没有图片，向下偏移量*/
- (void)showHint:(NSString *)hint yOffset:(float)yOffset;

@end
