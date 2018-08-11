//
//  Rank.h
//  lzt
//
//  Created by hwq on 2018/1/10.
//  Copyright © 2018年 hwq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RankScrollView.h"
@interface Rank : UIView

@property (nonatomic, strong) UIViewController *con;

@property (weak, nonatomic) IBOutlet UIImageView *close;

@property (weak, nonatomic) IBOutlet RankScrollerView *rankScrollView;

@end
