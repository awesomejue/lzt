//
//  firstSectionCell.m
//  lzt
//
//  Created by hwq on 2017/10/23.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "firstSectionCell.h"

@interface firstSectionCell()

@property (nonatomic, strong) UIImageView *MyimageView;

@end

@implementation firstSectionCell


- (void)awakeFromNib {
    [super awakeFromNib];
    [self configSelfView];
}

- (void)configSelfView{
   // self.imageView.image =  [UIImage imageNamed:@"fx-test.png"];
    self.MyimageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height * 0.25)];
    self.MyimageView.backgroundColor = [UIColor redColor];
    self.MyimageView.image = [UIImage imageNamed:@"fx-test.png"];
    [self.contentView addSubview:self.MyimageView];
}
    
    
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
