//
//  TZJLViewController.m
//  lzt
//
//  Created by hwq on 2017/12/6.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "TZJLViewController.h"
#import "TZJLTableViewCell.h"
#define ApearFooterCount 8 
@interface TZJLViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) int page;//分页
@property (nonatomic, assign) int limit;//每页数据量
@property (nonatomic, assign) int total;//总数据量
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavHeight;
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation TZJLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (iPhoneX) {
        _NavHeight.constant += 20;
    }
    self.page = 1;
    self.limit = 10;
    _dataSource = [[NSMutableArray alloc]init];
    [self setupTableView];
    [self loadData];
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}


-(void) checkFooterState {
    if(_dataSource.count == _total ){
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.tableView.mj_footer endRefreshing];
    }
}
- (void)loadMoreData {
    _page++;
    _limit = 10;
    NSString *url =[NSString stringWithFormat:@"%@%@%d%@", [FuncPublic SharedFuncPublic].rootserver ,@"plan/",self.cpId,@"/investments"];
    url = [NSString stringWithFormat:@"%@?from=%@&version=%@&page=%d&limit=%d", url, @"iOS", InnerVersion, _page, _limit];
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
- (void)loadData {
    _page = 1;
    _limit = 10;
    //载入数据
    NSString *url =[NSString stringWithFormat:@"%@%@%d%@", [FuncPublic SharedFuncPublic].rootserver ,@"plan/",self.cpId,@"/investments"];
    url = [NSString stringWithFormat:@"%@?from=%@&version=%@&page=%d&limit=%d", url, @"iOS", InnerVersion, _page, _limit];
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
                label.text = @"没有数据!";
                label.textColor = [UIColor lightGrayColor];
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
    [self.tableView registerNib:[UINib nibWithNibName:@"TZJLTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    self.tableView.rowHeight = 100;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    self.tableView.mj_footer.hidden = YES;//默认隐藏
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TZJLTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[TZJLTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.money.text = [NSString stringWithFormat:@"%.2f元", ([_dataSource[indexPath.row][@"money"] doubleValue])/100];
    cell.time.text = [FuncPublic getTime:_dataSource[indexPath.row][@"createdTime"]];
    cell.userName.text = _dataSource[indexPath.row][@"name"];
    return cell;
}

@end
