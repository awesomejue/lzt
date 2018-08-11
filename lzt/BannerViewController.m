//
//  BannerViewController.m
//  lzt
//
//  Created by hwq on 2017/11/23.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "BannerViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "MyTabbarController.h"
#import "NavigationController.h"

#define WebViewHeight 64
@import WebKit;
@interface BannerViewController ()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ImageHeight;
@property (weak, nonatomic) IBOutlet UIImageView *actionButton;
@property (weak, nonatomic) IBOutlet UILabel *headTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavHeight;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation BannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (iPhoneX) {
        _NavHeight.constant += 20;
    } self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    //[self apearNav];
    [self hideBackButtonText];
    [self createUI];
   // [self choose];
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}
- (void)createUI {
    if (iPhoneX) {
       
        _webView.delegate = self;
        _webView.scrollView.bounces = false; //禁止上下回弹效果
      
        [self showHudInView:self.view hint:@"加载中"];
        self.headTitle.text = _data[@"title"];
        
        JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        context[@"gotoInvestFragment"] = ^() {
            
            NavigationController *nav =   (NavigationController *) [UIApplication sharedApplication].keyWindow.rootViewController ;
            MyTabbarController *tab =  nav.viewControllers[0];
            tab.selectedIndex = 1;
            [self.navigationController popViewControllerAnimated:false];
            
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
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_data[@"url"]]]];
        
        //[self hideHud];
    }else {
        _webView.delegate = self;
        _webView.scrollView.bounces = false; //禁止上下回弹效果
        [self.view addSubview:_webView];
        [self showHudInView:self.view hint:@"加载中"];
        self.headTitle.text = _data[@"title"];
        JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        context[@"gotoInvestFragment"] = ^() {
            
            NavigationController *nav =   (NavigationController *) [UIApplication sharedApplication].keyWindow.rootViewController ;
            MyTabbarController *tab =  nav.viewControllers[0];
            tab.selectedIndex = 1;
            [self.navigationController popViewControllerAnimated:false];
            
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
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_data[@"url"]]]];
        
       // [self hideHud];
    }
   
   
}


- (void)call:(id)sender {
    //打电话
    UIWebView *webView = [[UIWebView alloc] init];
    NSString *string = [NSString stringWithFormat:@"tel://%@",@"400-661-1571"];
    NSURL *url = [NSURL URLWithString:string];
    
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    [self.view addSubview:webView];
}
- (void)hideBackButtonText{
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:nil];
}
- (void)tz:(id)sender {
    
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self hideHud];
}
@end
