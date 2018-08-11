//
//  ProjectCell.h
//  lzt
//
//  Created by hwq on 2017/10/23.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HWProgressView.h"

@interface ProjectCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *leftType;
@property (weak, nonatomic) IBOutlet UIImageView *leftBgImage;
@property (weak, nonatomic) IBOutlet UIImageView *leftImage;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *rate;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *allMoney;
@property (weak, nonatomic) IBOutlet UILabel *percent;

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UILabel *timetype;

@property (weak, nonatomic) IBOutlet HWProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIImageView *rightState;

@property (weak, nonatomic) IBOutlet UIImageView *mjorstImage;
@property (weak, nonatomic) IBOutlet UILabel *percentSign;
@property (weak, nonatomic) IBOutlet UILabel *allmoneySign;


@property(nonatomic, assign) double count;//投资比例

@property (nonatomic, strong) NSTimer *timer;

- (void)addTime;

@end
