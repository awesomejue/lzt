//
//  AboutViewController.m
//  lzt
//
//  Created by hwq on 2017/11/21.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@property (weak, nonatomic) IBOutlet UILabel *version;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavHeight;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"关于我们"];
    if (iPhoneX) {
        _NavHeight.constant += 20;
    }
    [self hideBackButtonText];
    //[self apearNav];
    [self createUI];
  
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}
- (void)createUI {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // 当前应用名称
    //    NSString *appCurName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    //    NSLog(@"当前应用名称：%@",appCurName);
    // 当前应用软件版本  比如：1.0.1
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    // NSLog(@"当前应用软件版本:%@",appCurVersion);
    self.version.text = [NSString stringWithFormat:@"v%@", appCurVersion];
}
- (IBAction)pfTouched:(id)sender {
    NSString *str = @"https://itunes.apple.com/us/app/来浙投理财/id1361945824?l=zh&ls=1&mt=8";
    NSURL *safariURL = [NSURL URLWithString:[str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    [[UIApplication sharedApplication] openURL:safariURL];
   // NSURL *safariURL = [NSURL URLWithString:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
   // [[UIApplication sharedApplication] openURL:safariURL];
}


- (void)viewWillAppear:(BOOL)animated {
   // [[NSNotificationCenter defaultCenter] postNotificationName:@"tabBarHidden" object:nil];
}

- (IBAction)score:(id)sender {
}
//显示导航栏
- (void) apearNav{
    [self.navigationController setNavigationBarHidden:false animated:NO];
    //  self.navigationController.navigationBar.hidden = false;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
@end
