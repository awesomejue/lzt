//
//  NewsDetailViewController.h
//  lzt
//
//  Created by hwq on 2017/11/18.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParentsViewController.h"
@interface NewsDetailViewController : ParentsViewController

@property(nonatomic, assign)int noticeId;
@property(nonatomic, assign)NSString* typeName;//公告详情还是新闻详情
@end
