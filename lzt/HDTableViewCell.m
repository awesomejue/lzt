//
//  HDTableViewCell.m
//  lzt
//
//  Created by hwq on 2018/1/10.
//  Copyright © 2018年 hwq. All rights reserved.
//

#import "HDTableViewCell.h"

@implementation HDTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.bg.layer.cornerRadius = 5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
