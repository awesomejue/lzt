//
//  ZJMXCell.h
//  lzt
//
//  Created by hwq on 2017/11/20.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZJMXCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *state;
@property (weak, nonatomic) IBOutlet UILabel *money;
@property (weak, nonatomic) IBOutlet UILabel *avaiableMoney;
@property (weak, nonatomic) IBOutlet UILabel *time;

@end
