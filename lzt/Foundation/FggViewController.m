//
//  FggViewController.m
//  lzt
//
//  Created by hwq on 2017/12/2.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "FggViewController.h"
#import "PTGGTableViewCell.h"
#import "NewsDetailViewController.h"
#import "NetManager.h"
#import "htmlViewController.h"
#import "testViewController.h"

#define ApearFooterCount 8 //数据量大于8条则显示上拉加载
@interface FggViewController ()<UITableViewDataSource, UITableViewDelegate>
{
//    NSMutableArray *dataSource;
//    int page;
//    int row;
//    int flag;
//    int sumCount;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) int page;//分页
@property (nonatomic, assign) int limit;//每页数据量
@property (nonatomic, assign) int total;//总数据量
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavHeight;

@end

@implementation FggViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    [self hideBackButtonText];
    self.page = 1;
    self.limit = 10;
    _dataSource = [[NSMutableArray alloc]init];
    if(iPhoneX){
        _NavHeight.constant += 20;
    }
    [self setupTableView];
    [self showHudInView:self.view hint:@"载入中"];
    [self loadData];
    [self hideHud];
//    [self createTableView];
//    [self tableHeaderDidTriggerRefresh];
}
- (void)loadData {
    _page = 1;
    _limit = 10;
    //载入数据
    NSString *url =[NSString stringWithFormat:@"%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"notice/list?"];
    url = [NSString stringWithFormat:@"%@page=%d&limit=%d&from=%@&version=%@", url,_page,_limit, @"iOS", InnerVersion];
    [NetManager GetRequestWithUrlString:url finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        if ([result[@"resultCode"] boolValue]) {
            [self showHint:result[@"resultMsg"] yOffset:0];
        }else {
            NSArray *array = result[@"resultData"];
            if (array.count > 0) {
                [_dataSource removeAllObjects];//清空
                [_dataSource addObjectsFromArray:array];
                _total = [result[@"sumCount"] intValue];
                self.page = 1;//记录第一次请求的页,重置为第一页
                [self.tableView reloadData];
                if (_dataSource.count > ApearFooterCount) {//指定数量的数据才显示上拉加载
                    self.tableView.mj_footer.hidden = false;
                }
                
                [self.tableView.mj_header endRefreshing];
                [self checkFooterState];//检查footer状态
            }else {
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
                
                UILabel *label = [[UILabel alloc]init];
                label.frame = CGRectMake(0, Screen_Height/6, Screen_Width, 50);
                label.textAlignment = NSTextAlignmentCenter;
                label.text = @"没有公告!";
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

- (void)loadMoreData {
    _page++;
    _limit = 10;
    NSString *url =[NSString stringWithFormat:@"%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"notice/list?"];
    url = [NSString stringWithFormat:@"%@page=%d&limit=%d&from=%@&version=%@", url,_page,_limit, @"iOS", InnerVersion];
    [NetManager GetRequestWithUrlString:url finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        if ([result[@"resultCode"] boolValue]) {
            [self showHint:result[@"resultMsg"] yOffset:0];
        }else {
            NSArray *array = result[@"resultData"];
            
            [_dataSource addObjectsFromArray:array];
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
-(void) checkFooterState {
    if(_dataSource.count == _total ){
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.tableView.mj_footer endRefreshing];
    }
}
-(void) setupTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"PTGGTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50;
    //
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1];
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
//- (void)tableHeaderDidTriggerRefresh {
//    //    if ([FuncPublic getSystemVersion].doubleValue >= 11.0) {
//    //        self.automaticallyAdjustsScrollViewInsets = true;
//    //        if ([self.tableView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
//    //                if (@available(iOS 11.0, *)) {
//    //                        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//    //                } else {
//    //                }
//    //        }
//    //        self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//    //                NSLog(@"刷新");
//    //                [self.tableView.mj_header endRefreshing];
//    //        }];
//    //    }else {
//    //        self.automaticallyAdjustsScrollViewInsets = false;
//    //
//    //        self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//    //            NSLog(@"刷新");
//    //            [self.tableView.mj_header endRefreshing];
//    //        }];
//    //    }
//    //防止tableview被导航栏遮挡。
//    self.navigationController.navigationBar.translucent = false;
//    //self.automaticallyAdjustsScrollViewInsets = false;
//    if ([self.tableView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
//        if (@available(iOS 11.0, *)) {
//            self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//        } else {
//        }
//    }
//    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//        row = 10;
//        [self loadData:page andRows:row];
//        NSLog(@"刷新");
//        [self.tableView.mj_header endRefreshing];
//    }];
//
//}
//- (void)createTableView {
//    _dataSource = [[NSMutableArray alloc]init];
//    self.tableView.delegate = self;
//    self.tableView.dataSource = self;
//    [self.tableView registerNib:[UINib nibWithNibName:@"PTGGTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
//    self.tableView.estimatedRowHeight = 50;
//    //
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    self.tableView.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1];
//}
//- (void)loadData: (int)pages andRows:(int)rows {
////    if (dataSource.count > 0) {//清空
////        [dataSource removeAllObjects];
////    }
//    NSString *url =[NSString stringWithFormat:@"%@%@", ROOTSERVER ,@"notice/list?"];
//    url = [NSString stringWithFormat:@"%@page=%d&limit=%d&from=%@&version=%@", url,pages,rows, @"iOS", InnerVersion];
//    [NetManager GetRequestWithUrlString:url finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//
//        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
//        if ([result[@"resultCode"] boolValue]) {
//            [self showHint:result[@"resultMsg"] yOffset:0];
//        }else {
//            dataSource = result[@"resultData"];
//            if (dataSource.count > 0) {
//                if (!flag) {
//                    sumCount = [result[@"sumCount"] intValue];
//
//                    self.tableView.mj_footer  = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//                        row += 10;
//                        [self loadData:page andRows:row];
//                        if (row > sumCount) {
//                            [self.tableView.mj_footer endRefreshingWithNoMoreData];
//                        }else {
//                            [self.tableView.mj_footer endRefreshing];
//                        }
//
//                    }];
//                    flag = 1;
//                    [self.tableView reloadData];
//                }
//            }else {
//                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 40)];
//                UILabel *label = [[UILabel alloc]init];
//                label.frame = CGRectMake(0, Screen_Height/6, Screen_Width, 40);
//                label.textAlignment = NSTextAlignmentCenter;
//                label.text = @"没有公告!";
//                label.textColor = [UIColor lightGrayColor];
//                label.font = [UIFont fontWithName:@"PingFang" size:13];
//
//                [view addSubview:label];
//                [self.tableView addSubview:view];
//                [self.tableView bringSubviewToFront:view];
//            }
//
//        }
//
//    } failed:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"%@", error);
//    }];
//
//}
- (void)viewWillAppear:(BOOL)animated {
    //[self apearNav];
//    page = 1;
//    flag = 0;
//    row = 10;
//    [self loadData:page andRows:row];
   
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _dataSource.count;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"HTML" bundle:nil];
    htmlViewController *detail = [s instantiateViewControllerWithIdentifier:@"htmlViewController"];
    detail.nid = [_dataSource[indexPath.row][@"id"] intValue];
    detail.name = @"公告详情";
    [self.navigationController pushViewController:detail animated:true];
    
//    testViewController *test = [[testViewController alloc]init];
//    test.id  =  [_dataSource[indexPath.row][@"id"] intValue];
//    [self.navigationController pushViewController:test animated:true];
//    UIStoryboard *s = [UIStoryboard storyboardWithName:@"HomePage" bundle:nil];
//    NewsDetailViewController *detail = [s instantiateViewControllerWithIdentifier:@"NewsDetailViewController"];
//    detail.noticeId = [_dataSource[indexPath.row][@"id"] intValue];
//    detail.typeName = @"公告详情";
//    [self.navigationController pushViewController:detail animated:true];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PTGGTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.name.text = _dataSource[indexPath.row][@"title"];
    cell.time.text =[FuncPublic getTime: _dataSource[indexPath.row][@"updatedTime"]];
    
    return cell;
}@end
