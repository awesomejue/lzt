//
//  FoundationController.m
//  lzt
//
//  Created by hwq on 2017/10/23.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "FoundationController.h"
#import "firstSectionCell.h"
#import "ZXViewController.h"
#import "FggViewController.h"
#import "htmlViewController.h"
#import "AboutViewController.h"

#import "XXPRViewController.h"
#import "NewsTableViewController.h"
#import "ServerViewController.h"
#import "CJWTViewController.h"
#import "HDDetailViewController.h"
#import "HDTableViewCell.h"
#import "UIImageView+WebCache.h"

#define ApearFooter 1

@interface FoundationController ()<UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource>
{
     int originContentSizeHeight;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavHeight;
@property (weak, nonatomic) IBOutlet UIView *parenttableView;

@property (weak, nonatomic) IBOutlet UIView *contentSizeView;
@property (assign, nonatomic) int count;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentSizeHeight;

@property (assign, nonatomic) BOOL isCanSideBack;

@property (nonatomic, assign) int page;//分页
@property (nonatomic, assign) int limit;//每页数据量
@property (nonatomic, assign) int total;//总数据量
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (weak, nonatomic) IBOutlet UITableView *tableView;



@end

@implementation FoundationController

- (void)viewDidLoad {
    [super viewDidLoad];
    _count = 0;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    self.tabBarController.navigationController.navigationItem.title = @"发现";
    if (iPhoneX) {
        _NavHeight.constant += 20;
    }
    [self hideBackButtonText];
    [self tableHeaderDidTriggerRefresh];
    originContentSizeHeight = _contentSizeView.frame.size.height;

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
    
    NSString *url =[NSString stringWithFormat:@"%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"activity/pic/list"];
    url = [NSString stringWithFormat:@"%@?page=%d&limit=%d&from=%@&version=%@&type=%@", url, self.page , self.limit, @"iOS", InnerVersion, @"index_mobile"];
    [NetManager GetRequestWithUrlString:url finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        if ([result[@"resultCode"] boolValue]) {
            [self showHint:result[@"resultMsg"] yOffset:0];
        }else {
            NSArray *array = result[@"resultData"];
            if (array.count > 2) {
                CGRect rect = _contentSizeView.frame;
                _contentSizeView.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, originContentSizeHeight + 220 * (array.count - 2));
                _tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, _tableView.frame.size.height + 220 * (array.count - 2));
            }
            //_contentSizeHeight.constant 
            if (array.count > 0) {
                [_dataSource removeAllObjects];//清空
                [_dataSource addObjectsFromArray:array];
                _total = [result[@"sumCount"] intValue];
                self.page = 1;//记录第一次请求的页,重置为第一页
                [self.tableView reloadData];
                if (_dataSource.count > ApearFooter) {//指定数量的数据才显示上拉加载
                    self.scrollView.mj_footer.hidden = false;
                }
                
                [self.scrollView.mj_header endRefreshing];
                [self checkFooterState];//检查footer状态
            }else {
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
//                [self.scrollView.mj_header endRefreshing];
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
        [self.scrollView.mj_header endRefreshing];
    }];
}


- (void)loadMoreData {
    self.page++;
    _limit = 10;
    
    NSString *url =[NSString stringWithFormat:@"%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"activity/pic/list"];
    url = [NSString stringWithFormat:@"%@?page=%d&limit=%d&from=%@&version=%@&type=%@", url, self.page , self.limit, @"iOS", InnerVersion, @"index_mobile"];
    
    [NetManager GetRequestWithUrlString:url finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        if ([result[@"resultCode"] boolValue]) {
            [self showHint:result[@"resultMsg"] yOffset:0];
        }else {
            NSArray *array = result[@"resultData"];
            if (array.count > _dataSource.count) {
                _contentSizeHeight.constant += array.count - _dataSource.count;
            }
            if (array.count > 0) {
                
                [_dataSource addObjectsFromArray:array];
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
        [self.scrollView.mj_footer endRefreshing];
    }];
}
-(void) checkFooterState {
    if(_dataSource.count == _total){
        [self.scrollView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.scrollView.mj_footer endRefreshing];
    }
}
-(void) setupTableView {
    [self.tableView registerNib:[UINib nibWithNibName:@"HDTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 220;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
//    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
//    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
//    self.tableView.mj_footer.hidden = YES;//默认隐藏
}

//下拉刷新
- (void)tableHeaderDidTriggerRefresh {
    
#ifdef __IPHONE_11_0
    if ([self.scrollView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
        if (@available(iOS 11.0, *)) {
            self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
        }
    }else {
        self.automaticallyAdjustsScrollViewInsets = false;
    }
#endif
    self.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        CGRect rect = _contentSizeView.frame;
        _contentSizeView.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, originContentSizeHeight);
        //_contentSizeHeight = originContentSizeHeight;
        [self loadData];
    }];
   self.scrollView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
       
        [self loadMoreData];
    }];
        self.scrollView.mj_footer.hidden = YES;//默认隐藏
}
- (void)hideBackButtonText{
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:nil];
}- (IBAction)xxptTouched:(id)sender {
//    XXPRViewController *xxpl = [self.storyboard instantiateViewControllerWithIdentifier:@"XXPRViewController"];
//    [self.navigationController pushViewController:xxpl animated:true];
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"HTML" bundle:nil];
    htmlViewController *news = [s instantiateViewControllerWithIdentifier:@"htmlViewController"];
    news.name = @"关于我们";
    [self.navigationController pushViewController:news animated:true];
}



- (IBAction)cjwtTouched:(id)sender {
    
    CJWTViewController *hwq = [self.storyboard instantiateViewControllerWithIdentifier:@"CJWTViewController"];
     [self.navigationController pushViewController:hwq animated:true];
}
- (IBAction)gywmTouched:(id)sender {
    AboutViewController *about = [self.storyboard instantiateViewControllerWithIdentifier:@"AboutViewController"];
    [self.navigationController pushViewController:about animated:true];
}
- (IBAction)xxkfTouched:(id)sender {
    //打电话
    UIWebView *webView = [[UIWebView alloc] init];
    NSString *string = [NSString stringWithFormat:@"tel://%@",@"400-661-1571"];
    NSURL *url = [NSURL URLWithString:string];
    
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    [self.view addSubview:webView];
}
- (IBAction)ptggTouched:(id)sender {
    
    FggViewController *ptgg = [self.storyboard instantiateViewControllerWithIdentifier:@"FggViewController"];
    [self.navigationController pushViewController:ptgg animated:true];
}

- (IBAction)mtzxTouched:(id)sender {
    //UIStoryboard *s = [UIStoryboard storyboardWithName:@"HomePage" bundle:nil];
    ZXViewController *news = [self.storyboard instantiateViewControllerWithIdentifier:@"ZXViewController"];
    [self.navigationController pushViewController:news animated:true];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
     [self.navigationController setNavigationBarHidden:YES animated:NO];
    //self.navigationController.navigationBarHidden = NO;
//    UILabel *navTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 44)];
//    navTitle.backgroundColor = [UIColor clearColor];
//    navTitle.text = @"发现";
//    navTitle.textColor = [UIColor whiteColor];
//    navTitle.textAlignment = NSTextAlignmentCenter;
//    navTitle.font = [UIFont fontWithName:@"PingFang SC" size:18];
//    self.navigationController.navigationBar.topItem.titleView = navTitle;
    
   // self.navigationController.navigationBar.hidden = NO;
  //  [[NSNotificationCenter defaultCenter] postNotificationName:@"tabBarAppear" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    
    [self resetSideBack];
    
}
/**
 
 * 禁用边缘返回
 
 */

-(void)forbiddenSideBack{
    
    self.isCanSideBack = NO;
    
    //关闭ios右滑返回
    
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        
        self.navigationController.interactivePopGestureRecognizer.delegate=self;
        
    }
    
}
-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    [self forbiddenSideBack];
    
}

/*
 * 恢复边缘返回
 */

- (void)resetSideBack {
    
    self.isCanSideBack=YES;
    
    //开启ios右滑返回
    
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer*)gestureRecognizer {
    
    return self.isCanSideBack;
    
}
- (IBAction)server:(id)sender {
    if (_count < 4) {
        _count++;
    }else{
        _count = 0;
        ServerViewController *server = [self.storyboard instantiateViewControllerWithIdentifier:@"ServerViewController"];
        [self.navigationController pushViewController:server animated:true];
    }
   
}
- (IBAction)gsjj:(id)sender {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"HTML" bundle:nil];
    htmlViewController *html = [s instantiateViewControllerWithIdentifier:@"htmlViewController"];
    html.name = @"公司简介";
    [self.navigationController pushViewController:html animated:true];
}
- (IBAction)tdgl:(id)sender {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"HTML" bundle:nil];
    htmlViewController *html = [s instantiateViewControllerWithIdentifier:@"htmlViewController"];
    html.name = @"团队管理";
    [self.navigationController pushViewController:html animated:true];
}
- (IBAction)ytdz:(id)sender {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"HTML" bundle:nil];
    htmlViewController *html = [s instantiateViewControllerWithIdentifier:@"htmlViewController"];
    html.name = @"约投订制";
    [self.navigationController pushViewController:html animated:true];
}



- (IBAction)yqyl:(id)sender {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"HTML" bundle:nil];
    htmlViewController *html = [s instantiateViewControllerWithIdentifier:@"htmlViewController"];
    html.name = @"邀请有礼";
    [self.navigationController pushViewController:html animated:true];
}

- (IBAction)back:(id)sender {
    //self.navigationController
}
- (IBAction)cpjs:(id)sender {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"HTML" bundle:nil];
    htmlViewController *html = [s instantiateViewControllerWithIdentifier:@"htmlViewController"];
    html.name = @"产品介绍";
    [self.navigationController pushViewController:html animated:true];
}
- (IBAction)gszz:(id)sender {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"HTML" bundle:nil];
    htmlViewController *html = [s instantiateViewControllerWithIdentifier:@"htmlViewController"];
    html.name = @"公司资质";
    [self.navigationController pushViewController:html animated:true];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _dataSource.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_dataSource[indexPath.row][@"status"] intValue]== 1) {
        
    }else {
        UIStoryboard *s = [UIStoryboard storyboardWithName:@"HomePage" bundle:nil];
        HDDetailViewController *html = [s instantiateViewControllerWithIdentifier:@"HDDetailViewController"];
        html.name = _dataSource[indexPath.row][@"title"];
        html.url = _dataSource[indexPath.row][@"url"];
        [self.navigationController pushViewController:html animated:true];
        
    }
    //    NewsDetailViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"NewsDetailViewController"];
    //    detail.noticeId = [NewsDatas[indexPath.row][@"id"] intValue];
    //    detail.typeName = @"资讯详情";
    //    [self.navigationController pushViewController:detail animated:true];
}- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" ];
    if (!cell) {
        cell = [[HDTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *date = [FuncPublic getTime:_dataSource[indexPath.row][@"startTime"]];
    cell.date.text =[ date substringToIndex:10];
    NSString *image = _dataSource[indexPath.row][@"picture"];
    image = [image stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [cell.image sd_setImageWithURL:[NSURL URLWithString:image] placeholderImage:[UIImage imageNamed:@"ytdz.png"]] ;
    if ([_dataSource[indexPath.row][@"status"] intValue] == 1) {//不正常
        // cell.backgroundColor = [UIColor lightGrayColor];
        cell.bg.backgroundColor = UIColorFromRGB(0xebebeb);
        cell.contentView.backgroundColor = UIColorFromRGB(0xf9f9f9);
    }else {
        //cell.backgroundColor = [UIColor lightGrayColor];
        cell.bg.backgroundColor = [UIColor whiteColor];
        cell.contentView.backgroundColor = UIColorFromRGB(0xf9f9f9);
    }
    
    return cell;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
@end
