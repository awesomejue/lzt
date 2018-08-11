//
//  RuleRegisterViewController.m
//  lzt
//
//  Created by hwq on 2017/11/20.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "RuleRegisterViewController.h"

@interface RuleRegisterViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavHeight;

@end

@implementation RuleRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"用户协议"];
    if (iPhoneX) {
        _NavHeight.constant += 20;
    }
    [self loadDocument:@"rule" inView:_webview];
    
}

-(void)loadDocument:(NSString *)documentName inView:(UIWebView *)webView
{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:documentName ofType:@"pdf"];
    
    NSURL *url = [NSURL fileURLWithPath:path];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [webView loadRequest:request];
    
}
- (void)hideNavigationBar {
     [self.navigationController setNavigationBarHidden:YES animated:YES];
   // self.navigationController.navigationBar.hidden = YES;
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}
- (void)appearNavigationBar {
     [self.navigationController setNavigationBarHidden:NO animated:YES];
   // self.navigationController.navigationBar.hidden = false;
}
- (void)viewWillAppear:(BOOL)animated {
    //[self appearNavigationBar];
}
- (void)viewWillDisappear:(BOOL)animated {
   // [self hideNavigationBar];
}
@end
