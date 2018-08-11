//
//  Rank.m
//  lzt
//
//  Created by hwq on 2018/1/10.
//  Copyright © 2018年 hwq. All rights reserved.
//

#import "Rank.h"
#import "RankScrollView.h"
@implementation Rank

//初始化工作
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
//        RankScrollerView *rank = [[RankScrollerView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width * 0.8, Screen_Height * 0.6) titleArray:@[@"日", @"月", @"总"]];
//       // [self.rankScrollView addSubview: rank];
//       // rank.backgroundColor = [UIColor redColor];
//        rank.con = self.con;
//        self.rankScrollView = rank;
        
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        RankScrollerView *rank = [[RankScrollerView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) titleArray:@[@"日", @"月", @"总"]];
        [self.rankScrollView addSubview: rank];
    }
    return self;
}

@end
