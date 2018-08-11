//
//  NewsCell.h
//  lzt
//
//  Created by hwq on 2017/10/23.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *newsimage;
@property (weak, nonatomic) IBOutlet UILabel *newstitle;
@property (weak, nonatomic) IBOutlet UILabel *newscontent;
@property (weak, nonatomic) IBOutlet UILabel *newsTime;

@end
