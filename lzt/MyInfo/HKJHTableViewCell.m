//
//  HKJHTableViewCell.m
//  lzt
//
//  Created by hwq on 2017/11/21.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "HKJHTableViewCell.h"

@implementation HKJHTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.bgView.layer.cornerRadius = 5;
    self.bgView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
