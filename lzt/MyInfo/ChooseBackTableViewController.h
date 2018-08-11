//
//  ChooseBackTableViewController.h
//  lzt
//
//  Created by hwq on 2017/11/24.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ChooseBackTableViewController;
//方便传递数据
@protocol ChooseBackDelegate <NSObject>

-(void)ChooseBack:(ChooseBackTableViewController *)controller didFinish:(NSString *)backName andBackCode:(NSString *)code;
@end

@interface ChooseBackTableViewController : UITableViewController
@property(nonatomic, weak) id<ChooseBackDelegate> delegate;
@end
