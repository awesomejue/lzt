//
//  HBTableViewCell.h
//  lzt
//
//  Created by hwq on 2017/11/18.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HBTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *ygqIimageView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroudimageview;
@property (weak, nonatomic) IBOutlet UILabel *money;
@property (weak, nonatomic) IBOutlet UILabel *moneySign;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UILabel *label4;
@property (weak, nonatomic) IBOutlet UILabel *persentLabel;


@end
