//
//  CZJLViewController.m
//  lzt
//
//  Created by hwq on 2017/12/7.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "CZJLViewController.h"
#import "CZJLCell.h"

#define ApearFooterCount 8 //数据量大于8条则显示上拉加载
@interface CZJLViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *headName;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavHeight;

@property (nonatomic, assign) int page;//分页
@property (nonatomic, assign) int limit;//每页数据量
@property (nonatomic, assign) int total;//总数据量
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation CZJLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self hideBackButtonText];
    if (iPhoneX) {
        _NavHeight.constant += 20;
    }
    // [self tableHeaderDidTriggerRefresh];
    self.page = 1;
    self.limit = 10;
    self.headName.text = _type;
    _dataSource = [[NSMutableArray alloc]init];
    [self setupTableView];
    [self showHudInView:self.view hint:@"载入中"];
    [self loadData];
    [self hideHud];
}

- (void)hideBackButtonText{
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:nil];
}

-(void) checkFooterState {
    if(_dataSource.count == _total ){
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.tableView.mj_footer endRefreshing];
    }
}
- (void)loadMoreData {
    
    if ([_type isEqualToString:@"提现记录"]) {
        _page++;
        _limit = 10;
        //载入数据
        NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
        NSString *url =[NSString stringWithFormat:@"%@%@%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"user/",userInfo[@"userId"],@"/withdraw/list"];
        NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
        // [param setValue:@"6381" forKey:@"code"];
        [param setValue:@"iOS" forKey:@"from"];
        [param setValue:userInfo[@"token"] forKey:@"token"];
        [param setValue:InnerVersion forKey:@"version"];
        [param setValue:[NSString stringWithFormat:@"%d", _page] forKey:@"page"];
        [param setValue:[NSString stringWithFormat:@"%d", _limit] forKey:@"limit"];
        [NetManager GetRequestWithUrlString:url  andDic:param finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
    }else {
        _page++;
        _limit = 10;
        //载入数据
        NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
        NSString *url =[NSString stringWithFormat:@"%@%@%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"user/",userInfo[@"userId"],@"/recharge/list"];
        NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
        // [param setValue:@"6381" forKey:@"code"];
        [param setValue:@"iOS" forKey:@"from"];
        [param setValue:userInfo[@"token"] forKey:@"token"];
        [param setValue:InnerVersion forKey:@"version"];
        [param setValue:[NSString stringWithFormat:@"%d", _page] forKey:@"page"];
        [param setValue:[NSString stringWithFormat:@"%d", _limit] forKey:@"limit"];
        [NetManager GetRequestWithUrlString:url andDic:param finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
}
-(void) setupTableView {
    self.navigationController.navigationBar.translucent = false;
    [self.tableView registerNib:[UINib nibWithNibName:@"CZJLCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    self.tableView.rowHeight = 100;
    self.tableView.estimatedRowHeight = 0;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    self.tableView.mj_footer.hidden = YES;//默认隐藏
}
- (void)loadData {
    if ([_type isEqualToString:@"提现记录"]) {
        _page = 1;
        _limit = 10;
        //载入数据
        NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
        NSString *url =[NSString stringWithFormat:@"%@%@%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"user/",userInfo[@"userId"],@"/withdraw/list"];
        NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
        // [param setValue:@"6381" forKey:@"code"];
        [param setValue:@"iOS" forKey:@"from"];
        [param setValue:userInfo[@"token"] forKey:@"token"];
        [param setValue:InnerVersion forKey:@"version"];
        [param setValue:[NSString stringWithFormat:@"%d", _page] forKey:@"page"];
        [param setValue:[NSString stringWithFormat:@"%d", _limit] forKey:@"limit"];
        [NetManager GetRequestWithUrlString:url andDic:param  finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
                    label.text = @"没有记录!";
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
    }else {
        _page = 1;
        _limit = 10;
        //载入数据
        NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
        NSString *url =[NSString stringWithFormat:@"%@%@%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"user/",userInfo[@"userId"],@"/recharge/list"];
        NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
        // [param setValue:@"6381" forKey:@"code"];
        [param setValue:@"iOS" forKey:@"from"];
        [param setValue:userInfo[@"token"] forKey:@"token"];
        [param setValue:InnerVersion forKey:@"version"];
        [param setValue:[NSString stringWithFormat:@"%d", _page] forKey:@"page"];
        [param setValue:[NSString stringWithFormat:@"%d", _limit] forKey:@"limit"];
        [NetManager GetRequestWithUrlString:url andDic:param finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
                    label.text = @"没有记录!";
                    label.font = [UIFont fontWithName:@"PingFang SC" size:14];
                    [view addSubview:label];
                    [self.tableView addSubview:view];
                    [self.tableView bringSubviewToFront:view];
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
    
}
- (void)createTableView {
    [self.tableView registerNib:[UINib nibWithNibName:@"CZJLCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    self.tableView.rowHeight = 100;
    self.tableView.estimatedRowHeight = 0;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CZJLCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" ];
    if (!cell) {
        cell = [[CZJLCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([_type isEqualToString:@"提现记录"]) {
        cell.txtime.text = [FuncPublic getTime:_dataSource[indexPath.row][@"time"]];
        cell.money.text =[NSString stringWithFormat:@"%.2f", [_dataSource[indexPath.row][@"money"] doubleValue]/100.0];
        cell.cgTime.text = @"";
        //提现状态判断
        if ( [_dataSource[indexPath.row][@"status"] isEqualToString:@"init"]) {
            cell.status.text = @"初始状态";
        }else if ( [_dataSource[indexPath.row][@"status"] isEqualToString:@"wait_verify"]) {
            cell.status.text = @"等待审核";
        }else  if ( [_dataSource[indexPath.row][@"status"] isEqualToString:@"recheck"]) {
            cell.status.text = @"等待复核";
        }else  if ( [_dataSource[indexPath.row][@"status"] isEqualToString:@"success"]) {
            cell.status.text = @"提现成功";
        }else  if ( [_dataSource[indexPath.row][@"status"] isEqualToString:@"verify_fail"]) {
            cell.status.text = @"审核未通过";
        }
    }else {
        cell.txtime.text = [FuncPublic getTime:_dataSource[indexPath.row][@"time"]];
        cell.money.text =[NSString stringWithFormat:@"%.2f", [_dataSource[indexPath.row][@"money"] doubleValue]/100.0];
        cell.cgTime.text = [FuncPublic getTime:_dataSource[indexPath.row][@"successTime"]]; ;
        //提现状态判断
        if ( [_dataSource[indexPath.row][@"status"] isEqualToString:@"init"]) {
            cell.status.text = @"初始状态";
        }else if ( [_dataSource[indexPath.row][@"status"] isEqualToString:@"wait_pay"]) {
            cell.status.text = @"待支付";
        }else  if ( [_dataSource[indexPath.row][@"status"] isEqualToString:@"overdue"]) {
            cell.status.text = @"失效";
        }else  if ( [_dataSource[indexPath.row][@"status"] isEqualToString:@"success"]) {
            cell.status.text = @"成功";
        }else  if ( [_dataSource[indexPath.row][@"status"] isEqualToString:@"fail"]) {
            cell.status.text = @"失败";
        }
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}
@end
