//
//  ParentsViewController.h
//  lzt
//
//  Created by 黄伟强 on 2017/10/17.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParentsViewController : UIViewController

/**
 *下拉刷新
 */
- (void)tableHeaderDidTriggerRefresh;
/**
 *停止刷新
 */
- (void)endTableHeaderRefesh;
/**
 *隐藏导航啦
 */
- (void)hideNavigationBar;
/**
 *显示导航栏
 */
- (void)apearNavigationBar ;
/**
 *设置标题
 */
- (void)setNaviTitle : (NSString *)title;
//隐藏导航栏返回按钮文字
- (void)hideBackButtonText;
@end
