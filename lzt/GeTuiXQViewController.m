//
//  GeTuiXQViewController.m
//  lzt
//
//  Created by hwq on 2018/2/1.
//  Copyright © 2018年 hwq. All rights reserved.
//

#import "GeTuiXQViewController.h"

@interface GeTuiXQViewController ()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *headTitle;
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavHeight;

@end

@implementation GeTuiXQViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (iPhoneX) {
        _navHeight.constant = 84;
    }
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    //[FuncPublic SharedFuncPublic].root = @"sdfsdf";
    NSString *url;
    //查看回款
    _headTitle.text = _dic[@"title"];
    // url = [NSString stringWithFormat:@"%@%@",[FuncPublic SharedFuncPublic].root, self.hkurl];
    url = _dic[@"url"];

    [self showHudInView:self.view hint:@"加载中"];
    self.webview.delegate = self;
    [ self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self hideHud];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self hideHud];
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
