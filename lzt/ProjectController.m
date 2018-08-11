//
//  ProjectController.m
//  lzt
//
//  Created by hwq on 2017/10/23.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "ProjectController.h"
#import "ProjectCell.h"
#import "NetManager.h"
#import "CPXQViewController.h"
#import "TESTViewController.h"
#import "Rank.h"
#import "RankScrollView.h"
#import "RankViewController.h"

#define ApearFooterCount 8 //数据量大于8条则显示上拉加载
#define TempSever @"https://www.futoulc.com/"

@interface ProjectController () <UITableViewDataSource, UITableViewDelegate>
{
//    NSMutableArray *dataSource;
//    int page;
//    int row;
//    int sumCount; //保存投资记录总数
//    int flag; //第一次加载数据
    Rank *rankView;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
//@property (strong, nonatomic)  UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayout;

@property (nonatomic, assign) int page;//分页
@property (nonatomic, assign) int limit;//每页数据量
@property (nonatomic, assign) int total;//总数据量
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, assign) int count;//标类型为4的标的数据量
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavHeight;

@end

@implementation ProjectController

- (void)viewDidLoad {
   
    [super viewDidLoad];
     self.navigationController.navigationBar.translucent = NO;
    self.page = 1;
    self.limit = 10;
    self.count = 0;
    _dataSource = [[NSMutableArray alloc]init];
   // [self initHD];
    [self loadData];
    [self createNav];
    [self createProjectTableView];
   // [self tableHeaderDidTriggerRefresh];
    [self hideBackButtonText];
    

    
}


- (void) createNav {
    //使用strings文件
    //self.navigationItem.title = NSLocalizedString(@"tab2Title", nil);
    if (iPhoneX) {
        _NavHeight.constant += 20;
    }
}
- (void) createProjectTableView {
   // self.tableView = [[UITableView alloc]init];
   // self.tableView.frame = CGRectMake(0, 64, Screen_Width, Screen_Height-64);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"ProjectCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    self.tableView.rowHeight = 190;
    self.tableView.estimatedRowHeight = 0;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    _tableView.estimatedSectionFooterHeight = 0;
   // _tableView.mj_header.ignoredScrollViewContentInsetTop = 20;
    if (@available(iOS 11.0, *)) {
       // self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        _tableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
    }
    
#ifdef __IPHONE_11_0
    if ([self.tableView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
        if (@available(iOS 11.0, *)) {
            self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
        }
    }
#endif
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    self.tableView.mj_footer.hidden = YES;//默认隐藏
}
- (void)initHD{
    //载入xib方法。
    rankView = [[[NSBundle mainBundle] loadNibNamed:@"Rank" owner:self options:nil] lastObject];
    rankView.rankScrollView.layer.cornerRadius = 5;
    rankView.rankScrollView.layer.masksToBounds = true;
    rankView.center = self.view.center;
    rankView.frame = CGRectMake(0, -Screen_Height, Screen_Width, Screen_Height);
    // [rankView.calBtn setCornerRadium];
    rankView.con = self;
    
    RankScrollerView *rank = [[RankScrollerView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width * 0.8, Screen_Height * 0.6) titleArray:@[@"日", @"月", @"总"]];
    // [self.rankScrollView addSubview: rank];
    // rank.backgroundColor = [UIColor redColor];
    rank.con = self;
    [rankView.rankScrollView addSubview: rank];
    
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(remove)];
    [rankView.close addGestureRecognizer:tap];
    UIWindow *w = [UIApplication sharedApplication].keyWindow;
    [w addSubview:rankView];
}
- (void)hideBackButtonText{
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:nil];
}

-(void) checkFooterState {
    if(_dataSource.count == _total - _count){
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.tableView.mj_footer endRefreshing];
    }
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
                if (_total > ApearFooterCount) {//指定数量的数据才显示上拉加载
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
- (IBAction)projectRankBtnClicked:(id)sender {
    RankViewController *rank = [self.storyboard instantiateViewControllerWithIdentifier:@"RankViewController"];
    [self.navigationController pushViewController:rank animated:true];
}

/**
 *载入计划列表
 */
//- (void) loadData:(int )page andRow:(int )rows{
//    //载入数据
//    NSString *url =[NSString stringWithFormat:@"%@%@", ROOTSERVER ,@"plans"];
//    url = [NSString stringWithFormat:@"%@?page=%d&limit=%d&from=%@&version=%@", url,page, rows, @"iOS", InnerVersion];
//    [NetManager GetRequestWithUrlString:url finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
//        if ([result[@"resultCode"] boolValue]) {
//            [self showHint:result[@"resultMsg"] yOffset:0];
//        }else {
//            if (dataSource.count > 0) {
//                [dataSource removeAllObjects];
//            }
//            NSArray *array = result[@"resultData"];
//            if (array.count > 0) {
//                for (NSDictionary *dic in array) {
//                    //标类型为4时，是隐藏标不显示。
//                    if ([dic[@"state"] intValue] == 4) {
//
//                    }else {
//                        [dataSource addObject:dic];
//                    }
//                }
//                sumCount = (int)array.count;
//
//                if (flag) {
//                    self.tableView.mj_footer  = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//                        row += 10;
//                        [self loadData:page andRow:row];
//                        if (row > sumCount) {
//                            [self.tableView.mj_footer endRefreshingWithNoMoreData];
//                        }else {
//                            [self.tableView.mj_footer endRefreshing];
//                        }
//                    }];
//                    flag = 0;
//                }
//
//                [self.tableView reloadData];
//            }else {
//                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
//
//                UILabel *label = [[UILabel alloc]init];
//                label.frame = CGRectMake(0, Screen_Height/6, Screen_Width, 50);
//                label.textAlignment = NSTextAlignmentCenter;
//                label.text = @"没有数据!";
//                label.font = [UIFont fontWithName:@"PingFang SC" size:14];
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
//}
//- (void)tableHeaderDidTriggerRefresh {
//    self.automaticallyAdjustsScrollViewInsets = false;
//      self.navigationController.navigationBar.translucent = false;
//#ifdef __IPHONE_11_0
//    if ([self.tableView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
//        if (@available(iOS 11.0, *)) {
//            self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//        } else {
//        }
//    }
//#endif
//    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//        row = 10;
//        [self loadData:page andRow:row];
//        [self.tableView.mj_header endRefreshing];
//    }];
//
//
//    //_tableView.mj_footer.ignoredScrollViewContentInsetBottom =120;
//}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
     [self.navigationController setNavigationBarHidden:YES animated:NO];
   
    //self.tableView.frame = CGRectMake(0, 64, Screen_Width, Screen_Height-64);
//    page = 1;
//    row = 10;
//    flag = 1;
//    dataSource = [[NSMutableArray alloc]init];
//    [self loadData:page andRow:row];
}

//动画效果添加子视图
- (void) animiationAddSubView {
    
    [UIView animateWithDuration:0.5 animations:^{
        rankView.frame = CGRectMake(0, 0, Screen_Width, Screen_Height);
    }];
//    [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
////        UIWindow *window = [UIApplication sharedApplication].keyWindow;
////        [window addSubview:rankView];
////        [window bringSubviewToFront:rankView];
//        rankView.frame = CGRectMake(0, 0, Screen_Width, Screen_Height);
//    }completion:^(BOOL finished){
//        NSLog(@"动画结束");
//    }];
    
    //    [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
    //                [self.view addSubview:cal];
    //                [self.view bringSubviewToFront:cal];
    //            }completion:^(BOOL finished){
    //                NSLog(@"动画结束");
    //            }];
}
- (IBAction)rankTouched:(id)sender {
    
    //    RankScrollerView *rank = [[RankScrollerView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width * 0.8, Screen_Height * 0.6) titleArray:@[@"日", @"月", @"总"]];
    //    // [self.rankScrollView addSubview: rank];
    //    // rank.backgroundColor = [UIColor redColor];
    //
    //    RankViewController *test = [self.storyboard instantiateViewControllerWithIdentifier:@"RankViewController"];
    //    rank.con = test;
    //    test.rankScrollView = rank;
    //  //  [test.view addSubview:rank];
    //    test.view.alpha = 0.6;
    //    [self.view addSubview:test.view];
    // [self presentViewController:test animated:true completion:nil];
    [self animiationAddSubView];
}
- (void)remove {
    rankView.frame = CGRectMake(0, -Screen_Height, Screen_Width, Screen_Height);
}
#pragma mark- uitableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 定义cell标识  每个cell对应一个自己的标识
   // NSString *CellIdentifier = [NSString stringWithFormat:@"cell%ld%ld",indexPath.section,indexPath.row];
    // 通过不同标识创建cell实例
   // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    ProjectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[ProjectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.name.text = _dataSource[indexPath.row][@"name"];
    //double rate = [_dataSource[indexPath.row][@"rate"] doubleValue]+ [_dataSource[indexPath.row][@"rasingRate"] doubleValue] ;
    if ([_dataSource[indexPath.row][@"rasingRate"] doubleValue] > 0) {
         cell.rate.text =[NSString stringWithFormat:@"%.1f+%.1f", [_dataSource[indexPath.row][@"rate"] doubleValue]/10, [_dataSource[indexPath.row][@"rasingRate"] doubleValue]/10];
    }else {
         cell.rate.text =[NSString stringWithFormat:@"%.1f", [_dataSource[indexPath.row][@"rate"] doubleValue]/10];
    }
   
    cell.time.text =[NSString stringWithFormat:@"%@", _dataSource[indexPath.row][@"staging"]];
    cell.timetype.text = [FuncPublic getDate:_dataSource[indexPath.row][@"stagingUnit"]];
    
    double i = [_dataSource[indexPath.row][@"nowSum"] doubleValue] /  [_dataSource[indexPath.row][@"amount"] doubleValue];
    NSString *str = _dataSource[indexPath.row][@"name"];
    if ([ str isEqualToString:@"投标宝-2017112901"]) {
        if (i > 1) {
            NSLog(@"%f",i);
        }
    }
    int indexx =[_dataSource[indexPath.row][@"state"] intValue];
    if (indexx == 1 || indexx == 2) {//还款或者已还款不考虑
        cell.mjorstImage.hidden = true;
    }else {
        cell.count = i;
        if([_dataSource[indexPath.row][@"nowSum"] doubleValue] == 0){
            cell.mjorstImage.hidden = false;
            cell.mjorstImage.image = [UIImage imageNamed:@"首投.png"];
        }else if(i >= 0.85 && i < 1){
            cell.mjorstImage.hidden = false;
            cell.mjorstImage.image = [UIImage imageNamed:@"满奖.png"];
        }
//        }else{
//            cell.mjorstImage.hidden = true;
//        }
    }
    
    //cell.progressView.progress = 0;
    cell.progressView.progress = i;
    cell.allMoney.text = [NSString stringWithFormat:@"%.0f", [_dataSource[indexPath.row][@"amount"] doubleValue] / 100];
    cell.percent.text = [NSString stringWithFormat:@"%d%%", (int)(i * 100)];
        
    if ([_dataSource[indexPath.row][@"type"] intValue] == 0) {
       // cell.leftType.text = @"投标宝";
        cell.leftType.text = _dataSource[indexPath.row][@"typeName"];
    }else if ([_dataSource[indexPath.row][@"type"] intValue] == 1) {
      //  cell.leftType.text = @"新客专享";
         cell.leftType.text = _dataSource[indexPath.row][@"typeName"];
    }else if ([_dataSource[indexPath.row][@"type"] intValue] == 2) {
        //cell.leftType.text = @"产融宝";
         cell.leftType.text = _dataSource[indexPath.row][@"typeName"];
    }else {
        //cell.leftType.text = @"优选理财";
         cell.leftType.text = _dataSource[indexPath.row][@"typeName"];
    }
        
    //标类型:写死不利于以后扩展
    int index =[_dataSource[indexPath.row][@"state"] intValue];
    switch (index) {
        case 1:
            
            cell.rightState.image = [UIImage imageNamed: @"还款中.png"];
            cell.rightState.hidden =false;
            cell.progressView.isGray = true;
            cell.leftBgImage.backgroundColor = [UIColor lightGrayColor];
            cell.leftBgImage.layer.cornerRadius = 10;
            cell.progressView.progressView.progressTintColor = [UIColor lightGrayColor];
            cell.percentSign.textColor = [UIColor lightGrayColor];
            cell.allmoneySign.textColor = [UIColor lightGrayColor];
            cell.rate.textColor = [UIColor lightGrayColor];
            cell.allMoney.textColor = [UIColor lightGrayColor];
            break;
        case 2:
            cell.rightState.image = [UIImage imageNamed: @"已还款.png"];
            cell.rightState.hidden = false;
            cell.progressView.isGray = true;
            cell.leftBgImage.backgroundColor = [UIColor lightGrayColor];
            cell.leftBgImage.layer.cornerRadius = 10;
             cell.progressView.progressView.progressTintColor = [UIColor lightGrayColor];
            cell.percentSign.textColor = [UIColor lightGrayColor];
            cell.allmoneySign.textColor = [UIColor lightGrayColor];
            cell.rate.textColor = [UIColor lightGrayColor];
            cell.allMoney.textColor = [UIColor lightGrayColor];
            break;
        default:
            cell.rightState.hidden = YES;
            cell.leftBgImage.backgroundColor = [UIColor colorWithRed:249.0/255 green:58.0/255 blue:79.0/255 alpha:1];
            cell.leftBgImage.layer.cornerRadius = 10;
             cell.progressView.progressView.progressTintColor = [UIColor colorWithRed:249.0/255 green:58.0/255 blue:79.0/255 alpha:1];
            
            cell.percentSign.textColor = UIColorFromRGB(0xfb0000);
            cell.allmoneySign.textColor = UIColorFromRGB(0xfb0000);
            cell.rate.textColor = UIColorFromRGB(0xfb0000);
            cell.allMoney.textColor = UIColorFromRGB(0xfb0000);
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"CPXQ" bundle:nil];
    CPXQViewController *cpxq = [s instantiateViewControllerWithIdentifier:@"CPXQViewController"];
    cpxq.cpId = [_dataSource[indexPath.row][@"id"] intValue];
    cpxq.xktype = [_dataSource[indexPath.row][@"type"] intValue];
    cpxq.cpState = [_dataSource[indexPath.row][@"state"] intValue];
    [self.navigationController pushViewController:cpxq animated:true];
//    TESTViewController *test = [self.storyboard instantiateViewControllerWithIdentifier:@"TESTViewController"];
//    [self.navigationController pushViewController:test animated:true];
}
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return Screen_Height * 0.25;
//}

@end
