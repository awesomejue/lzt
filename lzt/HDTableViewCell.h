//
//  HDTableViewCell.h
//  lzt
//
//  Created by hwq on 2018/1/10.
//  Copyright © 2018年 hwq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *bg;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UIImageView *overImage;
@property (weak, nonatomic) IBOutlet UIView *overbg;
@property (weak, nonatomic) IBOutlet UILabel *name;

@end
