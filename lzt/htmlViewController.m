//
//  htmlViewController.m
//  lzt
//
//  Created by hwq on 2017/12/2.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "htmlViewController.h"
#import <UShareUI/UShareUI.h>
#import "NavigationController.h"
#import "MyTabbarController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "WebViewJavascriptBridge.h"
#import "JSTestObjext.h"

#define gg @"mobile/notices/"
#define hbgz @"mobile/redPacketRuleNewPage"
#define xszn @"mobile/noviceExpress"
#define txgz @"mobile/withdrawRuleNewPage"
#define yqhy @"mobile/invitFriend"
#define xwxq @"mobile/news/"
#define xthd @"mobile/continueVote"
#define xkfl @"mobile/newGuestWelfare"
#define tzyl @"mobile/investmentCourtesy"
#define xbhd @"mobile/onlineMarking"
#define hlxs @"mobile/newGuestWelfare"
#define zyfk @"mobile/safeEnsure"
#define ryez @"mobile/onlineMarking"
#define gsjj @"mobile/aboutNewPage"
#define gszz @"mobile/aptitude"
#define cpjs @"mobile/productIntruduction"
#define tdgl @"mobile/teamManagement"
#define hlxs @"mobile/newGuestWelfare"
#define zyfk @"mobile/safeEnsure"
#define ytdz @"mobile/onlineMarking"
#define cpsm @"mobile/planDescription"
#define icp @"mobile/notices/26"
#define zcxy @"mobile/registrationNewPage"

@interface htmlViewController ()<UIWebViewDelegate>
{
    NSString *shareTitle;
    NSString *shareDetail;
    NSString *shareUrl;
}
@property (weak, nonatomic) IBOutlet UILabel *headTitle;
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavHeight;

//声明`WebViewJavascriptBridge`对象为属性
@property WebViewJavascriptBridge* bridge;



@end

@implementation htmlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (iPhoneX) {
        _navHeight.constant = 84;
    }
   // [_webview.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    
    //NSString *s = [FuncPublic SharedFuncPublic].rootserver;
   // NSString *s2 = [FuncPublic SharedFuncPublic].root;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    //[FuncPublic SharedFuncPublic].root = @"sdfsdf";
    NSString *url;
    if ([_name isEqualToString: @"公告详情"]) {
        _webview.scalesPageToFit = YES;
        url = [NSString stringWithFormat:@"%@%@%d",[FuncPublic SharedFuncPublic].root, gg, _nid];
         _headTitle.text = _name;
    }else  if ([_name isEqualToString: @"红包规则"]) {
        url = [NSString stringWithFormat:@"%@%@",[FuncPublic SharedFuncPublic].root, hbgz];
        _headTitle.text = _name;
    }else  if ([_name isEqualToString: @"投资有礼"]) {
        url = [NSString stringWithFormat:@"%@%@",[FuncPublic SharedFuncPublic].root, tzyl];
        //url = @"http://192.168.1.18:3008/mobile/newGuestWelfare";
        _headTitle.text = _name;
    }else  if ([_name isEqualToString: @"注册协议"]) {
        url = [NSString stringWithFormat:@"%@%@",[FuncPublic SharedFuncPublic].root, zcxy];
        _headTitle.text = _name;
    }else  if ([_name isEqualToString: @"约投订制"]) {
        url = [NSString stringWithFormat:@"%@%@",[FuncPublic SharedFuncPublic].root, xbhd];
        _headTitle.text = _name;
    }else  if ([_name isEqualToString: @"新手指南"]) {
        url = [NSString stringWithFormat:@"%@%@",[FuncPublic SharedFuncPublic].root, xszn];
        _headTitle.text = _name;
    }else  if ([_name isEqualToString: @"来浙投资讯"]) {
        url = [NSString stringWithFormat:@"%@%@%d",[FuncPublic SharedFuncPublic].root, xwxq, _nid];
        _headTitle.text = _name;
    }else  if ([_name isEqualToString: @"提现规则"]) {
        url = [NSString stringWithFormat:@"%@%@",[FuncPublic SharedFuncPublic].root, txgz];
        _headTitle.text = _name;
    }else  if ([_name isEqualToString: @"加息券规则"]) {
        //url = [NSString stringWithFormat:@"%@%@",[FuncPublic SharedFuncPublic].root, txgz];
        _headTitle.text = _name;
    }else  if ([_name isEqualToString: @"邀请有礼"]) {
        _headTitle.text = _name;
        _shareBtn.hidden = false;
         url = [NSString stringWithFormat:@"%@%@",[FuncPublic SharedFuncPublic].root, yqhy];
    }else  if ([_name isEqualToString: @"公司简介"]) {
        _headTitle.text = _name;
        _shareBtn.hidden = YES;
        url = [NSString stringWithFormat:@"%@%@",[FuncPublic SharedFuncPublic].root, gsjj];
    }else  if ([_name isEqualToString: @"团队管理"]) {
        _headTitle.text = _name;
        _shareBtn.hidden = YES;
        url = [NSString stringWithFormat:@"%@%@",[FuncPublic SharedFuncPublic].root, tdgl];
    }else  if ([_name isEqualToString: @"产品介绍"]) {
        _headTitle.text = _name;
        _shareBtn.hidden = YES;
        url = [NSString stringWithFormat:@"%@%@",[FuncPublic SharedFuncPublic].root, cpjs];
    }else  if ([_name isEqualToString: @"平台资质"]) {
        _headTitle.text = _name;
        _shareBtn.hidden = YES;
        url = [NSString stringWithFormat:@"%@%@",[FuncPublic SharedFuncPublic].root, gszz];
    }else  if ([_name isEqualToString: @"安全保障"]) {
        _headTitle.text = _name;
        
        url = [NSString stringWithFormat:@"%@%@",[FuncPublic SharedFuncPublic].root, zyfk];
    }else  if ([_name isEqualToString: @"约投定制"]) {
        _headTitle.text = _name;
        
        url = [NSString stringWithFormat:@"%@%@",[FuncPublic SharedFuncPublic].root, ytdz];
    }else  if ([_name isEqualToString: @"豪礼相送"]) {
        _headTitle.text = _name;
        
        url = [NSString stringWithFormat:@"%@%@",[FuncPublic SharedFuncPublic].root, hlxs];
    }else  if ([_name isEqualToString: @"续投有礼"]) {
        _headTitle.text = _name;
        
        url = [NSString stringWithFormat:@"%@%@",[FuncPublic SharedFuncPublic].root, xthd];
    }else  if ([_name isEqualToString: @"产品说明"]) {
        _headTitle.text = _name;
        url = [NSString stringWithFormat:@"%@%@/%d?planId=%d", [FuncPublic SharedFuncPublic].root,cpsm,_type,_nid];
    }else  if ([_name isEqualToString: @"查看续投"]) {
        _headTitle.text = @"续投活动";
        url = self.hkurl;
        //url = [NSString stringWithFormat:@"%@%@", [FuncPublic SharedFuncPublic].root,_hkurl];
    }else {
        //查看回款
        _headTitle.text = _name;
        // url = [NSString stringWithFormat:@"%@%@",[FuncPublic SharedFuncPublic].root, self.hkurl];
        url = self.hkurl;
    }
    [self showHudInView:self.view hint:@"加载中"];
    
    //设置能够进行桥接
  //  [WebViewJavascriptBridge enableLogging];
    // 初始化*WebViewJavascriptBridge*实例,设置代理,进行桥接
   //_bridge = [WebViewJavascriptBridge bridgeForWebView:_webview];
  //  [_bridge setWebViewDelegate:self];
//    _bridge = [WebViewJavascriptBridge  bridgeForWebView:_webview webViewDelegate:self handler:^(id         data, WVJBResponseCallback responseCallback) {
//        NSLog(@"ObjC received message from JS: %@", data);
//        responseCallback(@"Response for message from ObjC");
//    }];
//    [self.bridge registerHandler:@"gotoInvestFragment" handler:^(id data, WVJBResponseCallback responseCallback) {
//        NSLog(@"ObjC Echo called with: %@", data);
//        responseCallback(data);
//    }];
//    [_bridge registerHandler:@"gotoInvestFragment" handler:^(id data, WVJBResponseCallback responseCallback) {
//        // data 后台传过来的参数,例如用户名、密码等
//
//        NSLog(@"testObjcCallback called: %@", data);
//
//        //具体的登录事件的实现,这里的login代表实现登录功能的一个OC函数。
//        [self gotoInvestFragment];
//
//        // responseCallback 给后台的回复
//
//        responseCallback(@"Response from testObjcCallback");
//    }];
    
//    JSContext *context = [_webview valueForKey:@"documentView.webView.mainFrame.javaScriptContext"];
//    JSTestObjext *test = [JSTestObjext new];
//    context[@"testobject"] = test;
    
    JSContext *context = [self.webview valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
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
    self.webview.delegate = self;
   [ self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    //[self hideHud];
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}


- (IBAction)share:(id)sender {
    [self showHudInView:self.view hint:@"载入中..."];
    NSString *url =[NSString stringWithFormat:@"%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"activity/invitFriend"];
    [NetManager GetRequestWithUrlString:url finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self hideHud];
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        if ([result[@"resultCode"] boolValue]) {
            [self showHint:result[@"resultMsg"] yOffset:0];
        }else {
            
            NSDictionary *dic= result[@"resultData"];
            shareTitle =dic[@"title"];
            shareDetail = dic[@"detail"];
            shareUrl = dic[@"url"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [UMSocialUIManager setPreDefinePlatforms:@[@(UMSocialPlatformType_WechatSession),@(UMSocialPlatformType_WechatTimeLine),@(UMSocialPlatformType_QQ)]];
                
                //显示分享面板
                [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
                    // 根据获取的platformType确定所选平台进行下一步操作
                    [self shareWebPageToPlatformType:platformType];
                }];
            });
           
        }
        
    } failed:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        if(error.code == -1009){
            [self showHint:@"网络连接失败，请检查网络状态。" yOffset:0];
        }else if(error.code == -1004){
            [self showHint:@"服务器开了个小差。" yOffset:0];
        }else if(error.code == -1001){
            [self showHint:@"请求超时，请检查网络状态。" yOffset:0];
        }
        [self hideHud];
        //[self.scrollView.mj_header endRefreshing];
    }];
    

}
- (void)shareWebPageToPlatformType:(UMSocialPlatformType)platformType
{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    //创建网页内容对象
   // NSString* thumbURL =  @"https://mobile.umeng.com/images/pic/home/social/img-1.png";
   // NSString *s = [NSString stringWithFormat:@"%@", shareDetail];
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:shareTitle descr:shareDetail thumImage:@"1024.png"];
    //设置网页地址
    shareObject.webpageUrl = shareUrl;
//    shareObject.webpageUrl = @"http://192.168.1.18:3002/mobile/shareRegister?channel=lzt";
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error) {
            UMSocialLogInfo(@"************Share fail with error %@*********",error);
        }else{
            if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                UMSocialShareResponse *resp = data;
                //分享结果消息
                UMSocialLogInfo(@"response message is %@",resp.message);
                //第三方原始返回的数据
                UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
                
            }else{
                UMSocialLogInfo(@"response data is %@",data);
            }
        }
       // [self showHint:error yOffset:0];
        //[self alertWithError:error];
    }];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self hideHud];
    
//   JSContext * _jsContext = [_webview valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
//    //捕获异常信息
//    _jsContext.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
//        context.exception = exceptionValue;
//        NSLog(@"异常信息：%@", exceptionValue);
//    };
//    _jsContext[@"gotoInvestFragmen"] = ^(NSDictionary *param) {
////        "iOS的内容在里边进行处理,页面跳转等操作,通过param可以获取到点击按钮后,HTML传过来的值和其他的东西"
//        NSLog(@"test");
//    };
//    'HTML中有对应传递参数的方法,接收的内容会在param字典中,如:'
//    function 123{
//        方法名({'key1':''value1'','key2':''value2''});
//    }
}
/**
 *  webView发送请求之前，都要调用这个方法（拦截请求来做相应的事情）
// */
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
//{
//    NSString *url = request.URL.absoluteString;
//    // 协议头是随便写的，为了区分http协议还是调用OC代码。。
//    NSString *scheme = @"test://";
//    if ([url containsString:scheme]) {
//        // JS要调用OC的方法，而不是直接加载请求
//        NSRange range = [url rangeOfString:scheme];
//        NSString *methodName = [url substringFromIndex:range.length];
//        SEL method = NSSelectorFromString(methodName);
//        [self performSelector:method withObject:nil];
//    }
//    return YES;
//}

- (void)gotoInvestFragment {
    //ReadBookController要跳转的界面
    NavigationController *nav =   (NavigationController *) [UIApplication sharedApplication].keyWindow.rootViewController ;
    MyTabbarController *tab =  nav.viewControllers[0];
    tab.selectedIndex = 3;
    [self.navigationController popViewControllerAnimated:false];
}
    
   
@end
