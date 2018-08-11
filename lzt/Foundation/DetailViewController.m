//
//  NewsDetailViewController.m
//  lzt
//
//  Created by hwq on 2017/11/18.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "DetailViewController.h"
#import "NetManager.h"
@interface DetailViewController ()
{
    NSMutableArray *dataSounce;
}
@property (weak, nonatomic) IBOutlet UILabel *newsTitle;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UIWebView *content;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    [self setTitle:@"资讯详情"];
    [self loadData];
    
}
- (void)loadData {
    
        dataSounce = [[NSMutableArray alloc]init];
  
        NSString *url =[NSString stringWithFormat:@"%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"news/details/"];
        url = [NSString stringWithFormat:@"%@%d?from=%@&version=%@", url,_noticeId, @"iOS", InnerVersion];
        [NetManager GetRequestWithUrlString:url finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self showHudInView:self.view hint:@"载入中"];
            NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
            if ([result[@"resultCode"] boolValue]) {
                [self showHint:result[@"resultMsg"] yOffset:0];
            }else {
                NSDictionary *dic = result[@"resultData"];
                _newsTitle.text = dic[@"title"];
                _date.text = [FuncPublic getTime:dic[@"updatedTime"]];
                // [self.content loadHTMLString:dataSounce[1][@"content"] baseURL:[NSURL URLWithString:SERVER]];
                [self.content loadHTMLString:dic[@"content"] baseURL:nil];
            }
            [self hideHud];
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
        }];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}
- (void)viewWillAppear:(BOOL)animated {
    //  [self apearNav];
   // [[NSNotificationCenter defaultCenter] postNotificationName:@"tabBarHidden" object:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//显示导航栏
- (void) apearNav{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    //self.navigationController.navigationBar.hidden = false;
}
- (void)viewWillDisappear:(BOOL)animated {
    // [self.navigationController setNavigationBarHidden:YES animated:YES];
    //[self hideNavigationBar];
    // [[NSNotificationCenter defaultCenter] postNotificationName:@"tabBarAppear" object:nil];
}


@end

