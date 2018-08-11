//
//  NewsTableViewController.m
//  lzt
//
//  Created by hwq on 2017/11/18.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "NewsTableViewController.h"
#import "NewsCell.h"
#import "NewsDetailViewController.h"
#import "NetManager.h"
#import "UIImageView+WebCache.h"
@interface NewsTableViewController ()
{
    NSMutableArray *NewsDatas;
    int page;
    int row;
}

@end

@implementation NewsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = true;
    [self setTitle:@"来浙投资讯"];
    //[self apearNav];
    [self hideBackButtonText];
    [self createTableview];
    [self tableHeaderDidTriggerRefresh];
}
- (void)createTableview {
    //样式设置为grouped，section头部移动
    [self.tableView registerNib:[UINib nibWithNibName:@"NewsCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    self.tableView.rowHeight = 90;
    self.tableView.estimatedRowHeight = 70;
   // self.tableView.sectionHeaderHeight = 50;
    NewsDatas = [[NSMutableArray alloc]init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
}

//显示导航栏
- (void) apearNav{
     [self.navigationController setNavigationBarHidden:NO animated:YES];
   // self.navigationController.navigationBar.hidden = false;
}

- (void)viewWillAppear:(BOOL)animated {
     [self.navigationController setNavigationBarHidden:NO animated:YES];
    //[self apearNav];
    page = 1;
    row = 10;
    [self showHudInView:self.view hint:@"载入中"];
    [self loadNewsData:page andRows:row];
    [self hideHud];
    // [[NSNotificationCenter defaultCenter] postNotificationName:@"tabBarHidden" object:nil];
}

- (void)loadNewsData:(int)page andRows:(int)row {
//    if (NewsDatas.count > 0) {
//        [NewsDatas removeAllObjects];
//    }
    //载入新闻数据
    NSString *url =[NSString stringWithFormat:@"%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"news/list?"];
    url = [NSString stringWithFormat:@"%@page=%d&limit=%d&from=%@&version=%@", url, page,row,@"iOS", InnerVersion];
    [NetManager GetRequestWithUrlString:url finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        if ([result[@"resultCode"] boolValue]) {
            [self showHint:result[@"resultMsg"] yOffset:0];
        }else {
            NewsDatas = result[@"resultData"];
            [self.tableView reloadData];
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
    }];
}
- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)hideBackButtonText{
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:nil];
}
//下拉刷新
- (void)tableHeaderDidTriggerRefresh {
     //self.navigationController.navigationBar.translucent = false;
    //tableview的style为grouped时无需判断。适配iOS11
//#ifdef __IPHONE_11_0
//    if ([self.tableView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
//        if (@available(iOS 11.0, *)) {
//            self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//        } else {
//        }
//    }
//#endif
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        row += 10;
        [self loadNewsData:page andRows:row];
        [self.tableView.mj_header endRefreshing];
    }];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return NewsDatas.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" ];
    if (!cell) {
        cell = [[NewsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
   
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *image =[NSString stringWithFormat:@"%@%@",[FuncPublic SharedFuncPublic].rootserver, NewsDatas[indexPath.row][@"coverImage"]];
    image = [image stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
   // [cell.newsimage sd_setImageWithURL:[NSURL URLWithString:image] placeholderImage:[UIImage imageNamed:@"news.jpg"]];
    
    cell.newstitle.text = NewsDatas[indexPath.row][@"title"];
    
//    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[NewsDatas[indexPath.row][@"content"] dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
//
//    cell.newscontent.attributedText = attrStr;
    cell.newscontent.text = NewsDatas[indexPath.row][@"subTitle"];
    
    NSString *createTime = [FuncPublic getTime: NewsDatas[indexPath.row][@"updatedTime"]];
    cell.newsTime.text = [createTime substringToIndex:10];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsDetailViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"NewsDetailViewController"];
    detail.noticeId = [NewsDatas[indexPath.row][@"id"] intValue];
    detail.typeName = @"资讯详情";
    [self.navigationController pushViewController:detail animated:true];
}
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, 50)];
//    view.backgroundColor= [UIColor whiteColor];
//    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 12, 100, 30)];
//    label.text = @"最新资讯";
//    [view addSubview:label];
//    return view;
//}


@end
