//
//  QRTZ.h
//  lzt
//
//  Created by hwq on 2017/12/1.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRTZ : UIView

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passwordHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *yblabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnTOP;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *avaiMoney;
@property (weak, nonatomic) IBOutlet UITextField *jymm;
@property (weak, nonatomic) IBOutlet UILabel *pocket;
@property (weak, nonatomic) IBOutlet UILabel *totalMoney;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UILabel *jxq;


@end
