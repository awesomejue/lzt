//
//  ZJMXViewController.m
//  lzt
//
//  Created by hwq on 2017/12/2.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "ZJMXViewController.h"
#import "ZJMXCell.h"
#import "NavigationController.h"
#import "MyTabbarController.h"
#define ApearFooterCount 6 //数据量大于8条则显示上拉加载
@interface ZJMXViewController ()<UITableViewDelegate,UITableViewDataSource>
{
//    NSMutableArray *dataSource;
//    int page;
//    int row;
//    int sumCount;
//    int flag;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavHeight;
@property (nonatomic, assign) int page;//分页
@property (nonatomic, assign) int limit;//每页数据量
@property (nonatomic, assign) int total;//总数据量
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation ZJMXViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
//    dataSource = [[NSMutableArray alloc]init];
//    [self setTitle:@"资金明细"];
//    [self hideBackButtonText];
//    [self createTableView];
//  //  [self apearNav];
//    [self tableHeaderDidTriggerRefresh];
    self.page = 1;
    self.limit = 10;
    _dataSource = [[NSMutableArray alloc]init];
    if (iPhoneX) {
        _NavHeight.constant += 20;
    }
    [self setupTableView];
    [self showHudInView:self.view hint:@"载入中"];
    [self loadData];
    [self hideHud];
}
- (void)viewWillAppear:(BOOL)animated {
//    page = 1;
//    row = 10;
//    flag = 0;
//    [self loadData:page andRow:10];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"tabBarHidden" object:nil];
}
- (void)hideBackButtonText{
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:nil];
}

- (void)loadData {
    _page = 1;
    _limit = 10;
    NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
    NSString *url =[NSString stringWithFormat:@"%@%@%@%@?token=%@&from=%@&version=%@&page=%d&limit=%d", [FuncPublic SharedFuncPublic].rootserver ,@"user/",userInfo[@"userId"],@"/tradeRecords", userInfo[@"token"], @"iOS", InnerVersion, _page, _limit];
    [NetManager GetRequestWithUrlString:url finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        int b = [result[@"resultCode"] intValue];
        if (b == 1) {
            [self showHint:result[@"resultMsg"] yOffset:0];
        }else if(b == 2){//token失效
            [self showHint:result[@"resultMsg"] yOffset:0];
            [FuncPublic SaveDefaultInfo:@"0" Key:userIsLogin];
            [FuncPublic SaveDefaultInfo:@"" Key:mSaveAccount];
            [FuncPublic SaveDefaultInfo:@"" Key:mUserInfo];
            [UIView transitionWithView:self.view duration:1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                //跳回首页
                NavigationController *nav =   (NavigationController *) [UIApplication sharedApplication].keyWindow.rootViewController ;
                MyTabbarController *tab =  nav.viewControllers[0];
                tab.selectedIndex = 0;
                [self.navigationController popViewControllerAnimated:true];
            }completion:^(BOOL finished){
                NSLog(@"动画结束");
            }];
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

-(void) setupTableView {
    [self.tableView registerNib:[UINib nibWithNibName:@"ZJMXCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    self.tableView.rowHeight = 100;
    self.tableView.estimatedRowHeight = 0;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    self.tableView.mj_footer.hidden = YES;//默认隐藏
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        _tableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
    }
    
}
- (void)loadMoreData {
    _page++;
    _limit = 10;
    NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
    NSString *url =[NSString stringWithFormat:@"%@%@%@%@?token=%@&from=%@&version=%@&page=%d&limit=%d", [FuncPublic SharedFuncPublic].rootserver ,@"user/",userInfo[@"userId"],@"/tradeRecords", userInfo[@"token"], @"iOS", InnerVersion, _page, _limit];
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
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZJMXCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.avaiableMoney.text = [NSString stringWithFormat:@"%.2f", [_dataSource[indexPath.row][@"balance"] doubleValue]/100.0];
    cell.time.text = [FuncPublic getTime:_dataSource[indexPath.row][@"createdTime"]];
   
    int state = [_dataSource[indexPath.row][@"state"] intValue];
    switch (state) {
        case 0:
            cell.state.text = @"投资成功";
             cell.money.text =  [NSString stringWithFormat:@"-%.2f", [_dataSource[indexPath.row][@"money"] doubleValue]/100.0];
            cell.money.textColor = [UIColor blueColor];
            break;
        case 1:
            cell.state.text = @"充值成功";
             cell.money.text =  [NSString stringWithFormat:@"+%.2f", [_dataSource[indexPath.row][@"money"] doubleValue]/100.0];
            cell.money.textColor = [UIColor redColor];
            break;
        case 2:
            cell.state.text = @"申请提现";
             cell.money.text =  [NSString stringWithFormat:@"-%.2f", [_dataSource[indexPath.row][@"money"] doubleValue]/100.0];
            cell.money.textColor = [UIColor blueColor];
            break;
        case 3:
            cell.state.text = @"提现成功";
             cell.money.text =  [NSString stringWithFormat:@"-%.2f", [_dataSource[indexPath.row][@"money"] doubleValue]/100.0];
            cell.money.textColor = [UIColor blueColor];
            break;
        case 4:
            cell.state.text = @"提现失败";
             cell.money.text =  [NSString stringWithFormat:@"%.2f", [_dataSource[indexPath.row][@"money"] doubleValue]/100.0];
            cell.money.textColor = [UIColor redColor];
            break;
        case 5:
            cell.state.text = @"正常还款";
             cell.money.text =  [NSString stringWithFormat:@"+%.2f", [_dataSource[indexPath.row][@"money"] doubleValue]/100.0];
            cell.money.textColor = [UIColor redColor];
            break;
        case 6:
            cell.state.text = @"平台奖励";
             cell.money.text =  [NSString stringWithFormat:@"+%.2f", [_dataSource[indexPath.row][@"money"] doubleValue]/100.0];
            cell.money.textColor = [UIColor redColor];
            break;
        default:
            break;
    }
    return cell;
}
@end
