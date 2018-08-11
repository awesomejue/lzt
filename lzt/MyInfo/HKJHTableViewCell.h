//
//  HKJHTableViewCell.h
//  lzt
//
//  Created by hwq on 2017/11/21.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HKJHTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *name;

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *repayedCorpus;//回款本金
@property (weak, nonatomic) IBOutlet UILabel *interest;//回款利息
@property (weak, nonatomic) IBOutlet UILabel *repayDay;//计划还款日期
@property (weak, nonatomic) IBOutlet UILabel *acturlTime;//实际还款日期
@property (weak, nonatomic) IBOutlet UILabel *period;//期数

@property (weak, nonatomic) IBOutlet UIView *firstView;

@end
