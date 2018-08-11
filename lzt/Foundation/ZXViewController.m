//
//  ZXViewController.m
//  lzt
//
//  Created by hwq on 2017/12/2.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "ZXViewController.h"
#import "NewsCell.h"
#import "DetailViewController.h"
#import "NewsDetailViewController.h"
#import "NetManager.h"
#import "UIImageView+WebCache.h"
#import "htmlViewController.h"

#define ApearFooterCount 7 //数据量大于8条则显示上拉加载
@interface ZXViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *NewsDatas;
//    int page;
//    int row;
//    int flag;
//    int sumCount;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) int page;//分页
@property (nonatomic, assign) int limit;//每页数据量
@property (nonatomic, assign) int total;//总数据量
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavHeight;

@end

@implementation ZXViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = true;
    [self setTitle:@"资讯"];
    if (iPhoneX) {
        _NavHeight.constant += 20;
    }
    //[self apearNav];
    [self hideBackButtonText];
    //[self createTableview];
    //[self tableHeaderDidTriggerRefresh];
    self.page = 1;
    self.limit = 10;
    NewsDatas = [[NSMutableArray alloc]init];
    [self setupTableView];
    [self showHudInView:self.view hint:@"载入中"];
    [self loadData];
    [self hideHud];
}
- (IBAction)BACK:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

-(void) checkFooterState {
    if(NewsDatas.count == _total ){
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.tableView.mj_footer endRefreshing];
    }
}
- (void)loadMoreData {
    _page++;
    _limit = 10;
    NSString *url =[NSString stringWithFormat:@"%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"news/list?"];
    url = [NSString stringWithFormat:@"%@page=%d&limit=%d&from=%@&version=%@", url, _page,_limit,@"iOS", InnerVersion];
    [NetManager GetRequestWithUrlString:url finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        if ([result[@"resultCode"] boolValue]) {
            [self showHint:result[@"resultMsg"] yOffset:0];
        }else {
            NSArray *array = result[@"resultData"];
            
            [NewsDatas addObjectsFromArray:array];
            [self.tableView reloadData];
            [self checkFooterState];//检查footer状态
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
        [self.tableView.mj_footer endRefreshing];
    }];
}
- (void)loadData {
    _page = 1;
    _limit = 10;
    //载入数据
    NSString *url =[NSString stringWithFormat:@"%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"news/list?"];
    url = [NSString stringWithFormat:@"%@page=%d&limit=%d&from=%@&version=%@", url, _page,_limit,@"iOS", InnerVersion];
    [NetManager GetRequestWithUrlString:url finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        if ([result[@"resultCode"] boolValue]) {
            [self showHint:result[@"resultMsg"] yOffset:0];
        }else {
            NSArray *array = result[@"resultData"];
            if (array.count > 0) {
                [NewsDatas removeAllObjects];//清空
                [NewsDatas addObjectsFromArray:array];
                _total = [result[@"sumCount"] intValue];
                self.page = 1;//记录第一次请求的页,重置为第一页
                [self.tableView reloadData];
                if (NewsDatas.count > ApearFooterCount) {//指定数量的数据才显示上拉加载
                    self.tableView.mj_footer.hidden = false;
                }
                
                [self.tableView.mj_header endRefreshing];
                [self checkFooterState];//检查footer状态
            }else {
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
                
                UILabel *label = [[UILabel alloc]init];
                label.frame = CGRectMake(0, Screen_Height/6, Screen_Width, 50);
                label.textAlignment = NSTextAlignmentCenter;
                label.text = @"没有数据";
                label.font = [UIFont fontWithName:@"PingFang SC" size:14];
                [view addSubview:label];
                [self.tableView addSubview:view];
                [self.tableView bringSubviewToFront:view];
                [self.tableView.mj_header endRefreshing];
            }
            
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
        [self.tableView.mj_header endRefreshing];
    }];
}
-(void) setupTableView {
    //样式设置为grouped，section头部移动
    [self.tableView registerNib:[UINib nibWithNibName:@"NewsCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    self.tableView.rowHeight = 90;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 0;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    self.tableView.mj_footer.hidden = YES;//默认隐藏
}


- (void)hideBackButtonText{
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return NewsDatas.count;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"HTML" bundle:nil];
    htmlViewController *detail = [s instantiateViewControllerWithIdentifier:@"htmlViewController"];
    detail.nid = [NewsDatas[indexPath.row][@"id"] intValue];
    detail.name = @"来浙投资讯";
    [self.navigationController pushViewController:detail animated:true];
    //    UIStoryboard *s = [UIStoryboard storyboardWithName:@"HomePage" bundle:nil];
    //    NewsDetailViewController *detail = [s instantiateViewControllerWithIdentifier:@"NewsDetailViewController"];
    //    detail.noticeId = [NewsDatas[indexPath.row][@"id"] intValue];
    //    detail.typeName = @"来浙投资讯";
    //    [self.navigationController pushViewController:detail animated:true];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" ];
    if (!cell) {
        cell = [[NewsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *image =[NSString stringWithFormat:@"%@%@",@"", NewsDatas[indexPath.row][@"coverImage"]];
    image = [image stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
     [cell.newsimage sd_setImageWithURL:[NSURL URLWithString:image] placeholderImage:[UIImage imageNamed:@""]];
    
    cell.newstitle.text = NewsDatas[indexPath.row][@"title"];
    
    //    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[NewsDatas[indexPath.row][@"content"] dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    //
    //    cell.newscontent.attributedText = attrStr;
    cell.newscontent.text = NewsDatas[indexPath.row][@"subTitle"];
    
    NSString *createTime = [FuncPublic getTime: NewsDatas[indexPath.row][@"updatedTime"]];
    cell.newsTime.text = [createTime substringToIndex:10];
    return cell;
}


@end
