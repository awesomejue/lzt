//
//  choosebankViewController.h
//  lzt
//
//  Created by hwq on 2017/12/2.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import <UIKit/UIKit.h>
@class choosebankViewController;
//方便传递数据
@protocol ChooseBackDelegate <NSObject>

-(void)ChooseBack:(choosebankViewController *)controller didFinish:(NSString *)backName andBackCode:(NSString *)code;
@end

@interface choosebankViewController : UIViewController

@property(nonatomic, weak) id<ChooseBackDelegate> delegate;

@end
