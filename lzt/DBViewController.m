//
//  DBViewController.m
//  lzt
//
//  Created by hwq on 2017/12/11.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "DBViewController.h"
#define root @"https://www.futoulc.com/"
@interface DBViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavHeight;

@end

@implementation DBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (iPhoneX) {
        _NavHeight.constant += 20;
    }
    [self showHudInView:self.view hint:@"载入中"];
    NSString *url = [NSString stringWithFormat:@"%@mobile/guaranteeInfo/%d",root, _flagid];
   // [self.webview loadHTMLString:self.content baseURL:nil];
    [ self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
   
    [self hideHud];
}


- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
