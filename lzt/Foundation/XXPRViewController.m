//
//  XXPRViewController.m
//  lzt
//
//  Created by hwq on 2017/11/21.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "XXPRViewController.h"

#define ChooseColor  [UIColor redColor]
#define NotChooseColor  [UIColor colorWithRed:252.0/255 green:184.0/255 blue:186.0/255 alpha:1]

@interface XXPRViewController ()
{
   
    
}
@property (strong, nonatomic)  NSMutableArray *headings;
@property (strong, nonatomic)  NSMutableArray *contents;

@property (weak, nonatomic) IBOutlet UIImageView *firstImage;
@property (weak, nonatomic) IBOutlet UILabel *firstline;
@property (weak, nonatomic) IBOutlet UIImageView *secondImage;
@property (weak, nonatomic) IBOutlet UILabel *secondLine;
@property (weak, nonatomic) IBOutlet UIImageView *thirdImage;
@property (weak, nonatomic) IBOutlet UILabel *thirdLine;
@property (weak, nonatomic) IBOutlet UILabel *heading;
@property (weak, nonatomic) IBOutlet UITextView *content;
@property (weak, nonatomic) IBOutlet UIImageView *bottm;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavHeight;

@end

@implementation XXPRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    [self setTitle:@"信息披露"];
    if (iPhoneX) {
        _NavHeight.constant += 20;
    }
    [self initData];
   
}

//tag =1:标示选中，0:标示没选中
- (IBAction)firstTouched:(id)sender {
    _secondImage.tag = 0;
    _thirdImage.tag = 0;
    _firstline.backgroundColor = ChooseColor;
    _firstImage.image = [UIImage imageNamed:@"人才发展2"];
    _heading.text = _headings[0];
    _content.text = _contents[0];
    
    _secondLine.backgroundColor = NotChooseColor;
    _secondImage.image = [UIImage imageNamed:@"赞"];

    _thirdLine.backgroundColor = NotChooseColor;
    _thirdImage.image = [UIImage imageNamed:@"安全帽"];
    
}
- (void)initData {
    _headings = [[NSMutableArray alloc]initWithObjects:@"肩负实名 砥砺前行",@"科技金融 专注建企",@"愿景可待 未来已来", nil];
    _contents = [[NSMutableArray alloc]initWithObjects:@"大出借人多一个安全可信赖的稳健型投资理财渠道。",@"公司拥有严格的风险管理体系，来保障出借人的每一份钱，对获得成功申请借款的企业从缴纳工程保证金——政府接收单位开具的据/票——到监管票/据——投标未成功保证金退回——平台还款整个流程全程跟踪，来确保项目不错配等系列成熟风控流程。“来浙投”致力于成为中国金融信息服务领域里最具专业性、稳健型、最值得信赖的互联网金融服务公司", nil];
    _heading.text = _headings[0];
    _content.text = _contents[0];
}
- (IBAction)secondTouched:(id)sender {
    _firstImage.tag = 0;
    _thirdImage.tag = 0;
    _secondLine.backgroundColor = ChooseColor;
    _secondImage.image = [UIImage imageNamed:@"赞2"];
    _heading.text = _headings[1];
    _content.text = _contents[1];
    
    _firstline.backgroundColor = NotChooseColor;
    _firstImage.image = [UIImage imageNamed:@"人才发展"];
    
    _thirdLine.backgroundColor = NotChooseColor;
    _thirdImage.image = [UIImage imageNamed:@"安全帽"];
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (void)viewWillAppear:(BOOL)animated {
    // [[NSNotificationCenter defaultCenter] postNotificationName:@"tabBarHidden" object:nil];
}

- (IBAction)thirdTouched:(id)sender {
    _secondImage.tag = 0;
    _firstImage.tag = 0;
    _thirdLine.backgroundColor = ChooseColor;
    _thirdImage.image = [UIImage imageNamed:@"安全帽2"];
    _heading.text = _headings[2];
    _content.text = _contents[2];
    
    _secondLine.backgroundColor = NotChooseColor;
    _secondImage.image = [UIImage imageNamed:@"赞"];
    
    _firstline.backgroundColor = NotChooseColor;
    _firstImage.image = [UIImage imageNamed:@"人才发展"];
}

@end
