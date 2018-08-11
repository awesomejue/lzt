//
//  CalculaterView.h
//  lzt
//
//  Created by hwq on 2017/11/17.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalculaterView : UIView
@property (weak, nonatomic) IBOutlet UIButton *calBtn;
@property (weak, nonatomic) IBOutlet UIView *calView;
@property (weak, nonatomic) IBOutlet UITextField *money;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *yqMoney;
@property (weak, nonatomic) IBOutlet UILabel *typeDate;

@end
