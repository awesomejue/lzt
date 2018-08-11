//
//  TESTViewController.m
//  lzt
//
//  Created by hwq on 2017/12/6.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "TESTViewController.h"
#import "ProjectCell.h"
#import "NetManager.h"
#import "CPXQViewController.h"
#import "MJRefresh.h"

@interface TESTViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) int page;//分页
@property (nonatomic, assign) int limit;//每页数据量
@property (nonatomic, assign) int total;//总数据量
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, assign) int count;//标类型为4的标的数据量
@end

@implementation TESTViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.page = 1;
    self.limit = 10;
    self.count = 0;
    _dataSource = [[NSMutableArray alloc]init];
    [self setupTableView];
    [self loadData];
}


- (void)loadData {
    _count = 0;
    _page = 1;
    _limit = 10;
    NSString *url =[NSString stringWithFormat:@"%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"plans"];
    url = [NSString stringWithFormat:@"%@?page=%d&limit=%d&from=%@&version=%@", url, self.page , self.limit, @"iOS", InnerVersion];
    [NetManager GetRequestWithUrlString:url finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        if ([result[@"resultCode"] boolValue]) {
            [self showHint:result[@"resultMsg"] yOffset:0];
        }else {
            NSArray *array = result[@"resultData"];
            if (array.count > 0) {
                [_dataSource removeAllObjects];//清空
                for (NSDictionary *dic in array) {
                    //标类型为4时，是隐藏标不显示。
                    if ([dic[@"state"] intValue] == 4) {
                        _count++;
                    }else {
                        [_dataSource addObject:dic];
                    }
                }
                _total = [result[@"sumCount"] intValue];
                self.page = 1;//记录第一次请求的页,重置为第一页
                [self.tableView reloadData];
                if (_dataSource.count > 12) {//指定数量的数据才显示上拉加载
                     self.tableView.mj_footer.hidden = false;
                }
               
                [self.tableView.mj_header endRefreshing];
                [self checkFooterState];//检查footer状态
            }else {
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
                
                UILabel *label = [[UILabel alloc]init];
                label.frame = CGRectMake(0, Screen_Height/6, Screen_Width, 50);
                label.textAlignment = NSTextAlignmentCenter;
                label.text = @"没有数据!";
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
    self.page++;
    _limit = 10;
    NSString *url =[NSString stringWithFormat:@"%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"plans"];
    url = [NSString stringWithFormat:@"%@?page=%d&limit=%d&from=%@&version=%@", url,self.page, self.limit, @"iOS", InnerVersion];
    [NetManager GetRequestWithUrlString:url finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        if ([result[@"resultCode"] boolValue]) {
            [self showHint:result[@"resultMsg"] yOffset:0];
        }else {
            NSArray *array = result[@"resultData"];
            NSMutableArray *temp = [[NSMutableArray alloc]init];
            if (array.count > 0) {
                for (NSDictionary *dic in array) {
                    //标类型为4时，是隐藏标不显示。
                    if ([dic[@"state"] intValue] == 4) {
                        _count++;
                    }else {
                        [temp addObject:dic];
                    }
                }
                [_dataSource addObjectsFromArray:temp];
                [self.tableView reloadData];
                [self checkFooterState];//检查footer状态
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
        [self.tableView.mj_footer endRefreshing];
    }];
}
-(void) checkFooterState {
    if(_dataSource.count == _total - _count){
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.tableView.mj_footer endRefreshing];
    }
}
-(void) setupTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    self.tableView.mj_footer.hidden = YES;//默认隐藏
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%.2f---%ld", [_dataSource[indexPath.row][@"amount"] doubleValue] / 100, (long)indexPath.row];
    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}
@end
