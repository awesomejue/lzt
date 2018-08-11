//
//  HDDetailViewController.m
//  lzt
//
//  Created by hwq on 2018/1/11.
//  Copyright © 2018年 hwq. All rights reserved.
//

#import "HDDetailViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "MyTabbarController.h"
#import "NavigationController.h"

@interface HDDetailViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NaviHeight;
@property (weak, nonatomic) IBOutlet UILabel *headTitle;

@end

@implementation HDDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (iPhoneX) {
        _NaviHeight.constant += 20;
    } self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    //[self apearNav];
    //[self hideBackButtonText];
    [self createUI];
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
- (void)createUI {
    
    if (iPhoneX) {
        
        _webview.delegate = self;
        _webview.scrollView.bounces = false; //禁止上下回弹效果
        
        [self showHudInView:self.view hint:@"加载中"];
        self.headTitle.text = _name;
        
        [_webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
        JSContext *context = [self.webview valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        context[@"gotoInvestFragment"] = ^() {
            
            NavigationController *nav =   (NavigationController *) [UIApplication sharedApplication].keyWindow.rootViewController ;
            MyTabbarController *tab =  nav.viewControllers[0];
            tab.selectedIndex = 1;
            
            // [self.navigationController popViewControllerAnimated:false];
            
            //        NSLog(@"+++++++Begin Log+++++++");
            //        NSArray *args = [JSContext currentArguments];
            //
            //        for (JSValue *jsVal in args) {
            //            NSLog(@"%@", jsVal);
            //        }
            //
            //        JSValue *this = [JSContext currentThis];
            //        NSLog(@"this: %@",this);
            //        NSLog(@"-------End Log-------");
            
        };
        //[self hideHud];
    }else {
        _webview.delegate = self;
        _webview.scrollView.bounces = false; //禁止上下回弹效果
        [self.view addSubview:_webview];
        [self showHudInView:self.view hint:@"加载中"];
        self.headTitle.text = _name;
        [_webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
        JSContext *context = [self.webview valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        context[@"gotoInvestFragment"] = ^() {
            
            NavigationController *nav =   (NavigationController *) [UIApplication sharedApplication].keyWindow.rootViewController ;
            [self.navigationController popToRootViewControllerAnimated:true];
            MyTabbarController *tab =  nav.viewControllers[0];
            tab.selectedIndex = 1;
            
            // [self.navigationController pop]
            //            while (nav.viewControllers.count > 0) {
            //                [self.navigationController popViewControllerAnimated:false];
            //            }
            
            
            //        NSLog(@"+++++++Begin Log+++++++");
            //        NSArray *args = [JSContext currentArguments];
            //
            //        for (JSValue *jsVal in args) {
            //            NSLog(@"%@", jsVal);
            //        }
            //
            //        JSValue *this = [JSContext currentThis];
            //        NSLog(@"this: %@",this);
            //        NSLog(@"-------End Log-------");
            
        };
        // [self hideHud];
    }
}
@end
