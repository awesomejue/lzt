//
//  WDTZJLViewController.m
//  lzt
//
//  Created by hwq on 2017/11/20.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "WDTZJLViewController.h"
#import "WDZJLUCell.h"
#import "NavigationController.h"
#import "MyTabbarController.h"
#define ApearFooterCount 8 //数据量大于8条则显示上拉加载

@interface WDTZJLViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    //NSMutableArray *dataSource;
//    int page;
//    int row;
//    int sumCount;
//    int flag;
}

@property (weak, nonatomic) IBOutlet UITableView *tzjlTableView;
@property (nonatomic, assign) int page;//分页
@property (nonatomic, assign) int limit;//每页数据量
@property (nonatomic, assign) int total;//总数据量
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavHeight;

@end

@implementation WDTZJLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
   // [self setTitle:@"投资记录"];
    //[self apearNav];
    [self hideBackButtonText];
    if (iPhoneX) {
        _NavHeight.constant += 20;
    }
    self.page = 1;
    self.limit = 10;
    _dataSource = [[NSMutableArray alloc]init];
    [self setupTableView];
      [self showHudInView:self.view hint:@"载入中"];
    [self loadData];
    [self hideHud];
}


- (void)loadData {
    _page = 1;
    _limit = 10;
    //载入数据
    NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
    NSString *url =[NSString stringWithFormat:@"%@%@%@%@?token=%@&from=%@&version=%@&page=%d&limit=%d", [FuncPublic SharedFuncPublic].rootserver ,@"user/",userInfo[@"userId"],@"/investments", userInfo[@"token"], @"iOS", InnerVersion, _page, _limit];
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
                [self.tzjlTableView reloadData];
                if (_dataSource.count > ApearFooterCount) {//指定数量的数据才显示上拉加载
                    self.tzjlTableView.mj_footer.hidden = false;
                }
                
                [self.tzjlTableView.mj_header endRefreshing];
                [self checkFooterState];//检查footer状态
            }else {
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
                
                UILabel *label = [[UILabel alloc]init];
                label.frame = CGRectMake(0, Screen_Height/6, Screen_Width, 50);
                label.textAlignment = NSTextAlignmentCenter;
                label.text = @"没有记录!";
                label.font = [UIFont fontWithName:@"PingFang SC" size:14];
                [view addSubview:label];
                [self.tzjlTableView addSubview:view];
                [self.tzjlTableView bringSubviewToFront:view];
                [self.tzjlTableView.mj_header endRefreshing];
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
        [self.tzjlTableView.mj_header endRefreshing];
    }];
}
-(void) checkFooterState {
    if(_dataSource.count == _total ){
        [self.tzjlTableView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.tzjlTableView.mj_footer endRefreshing];
    }
}
//显示导航栏
- (void) apearNav{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    // self.navigationController.navigationBar.hidden = false;
}
- (void)hideBackButtonText{
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:nil];
}
- (void)loadMoreData {
    _page++;
    _limit = 10;
    NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
    NSString *url =[NSString stringWithFormat:@"%@%@%@%@?token=%@&from=%@&version=%@&page=%d&limit=%d", [FuncPublic SharedFuncPublic].rootserver ,@"user/",userInfo[@"userId"],@"/investments", userInfo[@"token"], @"iOS", InnerVersion, _page, _limit];
    [NetManager GetRequestWithUrlString:url finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        if ([result[@"resultCode"] boolValue]) {
            [self showHint:result[@"resultMsg"] yOffset:0];
        }else {
            NSArray *array = result[@"resultData"];
            [_dataSource addObjectsFromArray:array];
            [self.tzjlTableView reloadData];
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
        [self.tzjlTableView.mj_footer endRefreshing];
    }];
}

//- (void)loadData:(int )page andRow:(int)rows {
//
//    NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
//    NSString *url =[NSString stringWithFormat:@"%@%@%@%@?token=%@&from=%@&version=%@&page=%d&limit=%d", ROOTSERVER ,@"user/",userInfo[@"userId"],@"/investments", userInfo[@"token"], @"iOS", InnerVersion, page, rows];
//   // [self showHudInView:self.view hint:@"载入中"];
//    [NetManager GetRequestWithUrlString:url finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        [self hideHud];
//        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
//        if ([result[@"resultCode"] boolValue]) {
//            [self showHint:result[@"resultMsg"] yOffset:0];
//        }else {
//            dataSource = result[@"resultData"];
//            if (dataSource.count == 0) {
//                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 40)];
//                UILabel *label = [[UILabel alloc]init];
//                label.frame = CGRectMake(0, Screen_Height/6, Screen_Width, 40);
//                label.textAlignment = NSTextAlignmentCenter;
//                label.text = @"没有记录!";
//                label.textColor = [UIColor lightGrayColor];
//                label.font = [UIFont fontWithName:@"PingFang" size:13];
//                //label.font = [UIFont systemFontOfSize:20];
//                [view addSubview:label];
//                [self.tzjlTableView addSubview:view];
//                [self.tzjlTableView bringSubviewToFront:view];
//            }else {
//                sumCount = [result[@"sumCount"] intValue];
//                if (!flag) {
//                    self.tzjlTableView.mj_footer  = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//                        row += 10;
//                        [self loadData:page andRow:row];
//                        if (row > sumCount) {
//                            [self.tzjlTableView.mj_footer endRefreshingWithNoMoreData];
//                        }else {
//                            [self.tzjlTableView.mj_footer endRefreshing];
//                        }
//
//                    }];
//                    flag = 1;
//                }
//                [self.tzjlTableView reloadData];
//            }
//        }
//        [self hideHud];
//    } failed:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"%@", error);
//        [self hideHud];
//    }];
//}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}
-(void) setupTableView {
    self.tzjlTableView.delegate = self;
    self.tzjlTableView.dataSource = self;
    [self.tzjlTableView registerNib:[UINib nibWithNibName:@"WDZJLUCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    //    self.tzjlTableView.rowHeight = UITableViewAutomaticDimension;
    //    self.tzjlTableView.estimatedRowHeight = 100;
    self.tzjlTableView.rowHeight = 100;
    self.tzjlTableView.estimatedRowHeight = 0;
    //
    self.tzjlTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tzjlTableView.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1];
    self.tzjlTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    self.tzjlTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    self.tzjlTableView.mj_footer.hidden = YES;//默认隐藏
}

- (void)createTableView {
    self.tzjlTableView.delegate = self;
    self.tzjlTableView.dataSource = self;
    [self.tzjlTableView registerNib:[UINib nibWithNibName:@"WDZJLUCell" bundle:nil] forCellReuseIdentifier:@"cell"];
//    self.tzjlTableView.rowHeight = UITableViewAutomaticDimension;
//    self.tzjlTableView.estimatedRowHeight = 100;
    self.tzjlTableView.rowHeight = 120;
    self.tzjlTableView.estimatedRowHeight = 0;
    //
    self.tzjlTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tzjlTableView.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WDZJLUCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.date.text = [FuncPublic getTime:_dataSource[indexPath.row][@"createdTime"]];
    cell.hb.text =[NSString stringWithFormat:@"%.2f", [_dataSource[indexPath.row][@"pocketMoney"] doubleValue] / 100];
    cell.jxq.text =[NSString stringWithFormat:@"%.1f", [_dataSource[indexPath.row][@"raisingRates"] doubleValue] / 10];
    cell.money.text = [NSString stringWithFormat:@"%.2f", [_dataSource[indexPath.row][@"money"] doubleValue] / 100];
    NSString *name = [NSString stringWithFormat:@"%@",_dataSource[indexPath.row][@"name"]];
    NSArray *array = [name componentsSeparatedByString:@"-"];
    if (array.count > 1) {
        cell.name1.text = array[0];
        cell.nameTime.text = array[1];
    }else {
        cell.name1.text = array[0];
        cell.nameTime.text = @"";
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _dataSource.count;
}




@end
