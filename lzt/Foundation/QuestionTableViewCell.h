//
//  QuestionTableViewCell.h
//  lzt
//
//  Created by hwq on 2017/11/21.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestionTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *content;
@property (weak, nonatomic) IBOutlet UIImageView *questionImageView;

@end
