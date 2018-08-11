//
//  ProjectHBTableViewController.h
//  lzt
//
//  Created by hwq on 2017/11/29.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ProjectHBTableViewController;
//方便传递数据
@protocol ChooseHBDelegate <NSObject>

-(void)ChooseBack:(ProjectHBTableViewController *)controller didFinish:(NSString *)hbMoney andPocketI:(NSString *)pocketid;



@end
@interface ProjectHBTableViewController : UIViewController

@property(nonatomic, weak) id<ChooseHBDelegate> delegate;

@property(nonatomic, assign)int cycle;//周期
@property(nonatomic, assign)double amount;//购买金额
@property(nonatomic, assign)int type;//红包还是加息券

@property(nonatomic, assign)NSString *hborjxq;

@end
