//
//  testViewController.m
//  lzt
//
//  Created by hwq on 2018/1/4.
//  Copyright © 2018年 hwq. All rights reserved.
//

#import "testViewController.h"
#import <WebKit/WebKit.h>

@interface testViewController ()

@end

@implementation testViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
  
    NSString * url = [NSString stringWithFormat:@"%@mobile/notices/%d",[FuncPublic SharedFuncPublic].root, _id];
   // WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    
    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";

    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
    [wkUController addUserScript:wkUScript];
    
    WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
    wkWebConfig.userContentController = wkUController;
    // 创建设置对象
    WKPreferences *preference = [[WKPreferences alloc]init];
    // 设置字体大小(最小的字体大小)
    preference.minimumFontSize = 40;
    
    // 设置偏好设置对象
    wkWebConfig.preferences = preference;
    
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:wkWebConfig];
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    [self.view addSubview:webView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
