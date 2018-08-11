//
//  HDViewController.m
//  lzt
//
//  Created by hwq on 2018/1/10.
//  Copyright © 2018年 hwq. All rights reserved.
//

#import "HDViewController.h"
#import "HDTableViewCell.h"
#import "htmlViewController.h"
#import "UIImageView+WebCache.h"
#import "HDDetailViewController.h"
#define ApearFooter 2
@interface HDViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NaviHeight;

@property (nonatomic, assign) int page;//分页
@property (nonatomic, assign) int limit;//每页数据量
@property (nonatomic, assign) int total;//总数据量
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, assign) int count;//标类型为4的标的数据量


@end

@implementation HDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    
    if(iPhoneX){
        _NaviHeight.constant += 20;
    }
    self.page = 1;
    self.limit = 10;
    self.count = 0;
    _dataSource = [[NSMutableArray alloc]init];
    [self setupTableView];
    [self loadData];
}

-(void) checkFooterState {
    if(_dataSource.count == _total){
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.tableView.mj_footer endRefreshing];
    }
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
        [self.tableView.mj_footer endRefreshing];
    }];
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
            if (array.count > 0) {
                [_dataSource removeAllObjects];//清空
                [_dataSource addObjectsFromArray:array];
                _total = [result[@"sumCount"] intValue];
                self.page = 1;//记录第一次请求的页,重置为第一页
                [self.tableView reloadData];
                if (_dataSource.count > ApearFooter) {//指定数量的数据才显示上拉加载
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
-(void) setupTableView {
    [self.tableView registerNib:[UINib nibWithNibName:@"HDTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 220;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //self.tableView.backgroundColor = [UIColor darkGrayColor];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    self.tableView.mj_footer.hidden = YES;//默认隐藏
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" ];
    if (!cell) {
        cell = [[HDTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *date = [FuncPublic getTime:_dataSource[indexPath.row][@"startTime"]];
    cell.date.text =[ date substringToIndex:10];
    cell.name.text = _dataSource[indexPath.row][@"title"];
    NSString *image = _dataSource[indexPath.row][@"picture"];
    image = [image stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [cell.image sd_setImageWithURL:[NSURL URLWithString:image] placeholderImage:[UIImage imageNamed:@"ytdz.png"]] ;
    if ([_dataSource[indexPath.row][@"status"] intValue] == 1) {//不正常
       // cell.backgroundColor = [UIColor lightGrayColor];
        //cell.bg.backgroundColor = UIColorFromRGB(0xebebeb);
        cell.overImage.hidden = false;
        cell.overbg.hidden = false;
    }else {
        cell.overImage.hidden = true;
        cell.overbg.hidden = true;
        //cell.backgroundColor = [UIColor lightGrayColor];
       // cell.bg.backgroundColor = [UIColor whiteColor];
    }
    return cell;
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
}
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, 50)];
//    view.backgroundColor= [UIColor whiteColor];
//    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 12, 100, 30)];
//    label.text = @"最新资讯";
//    [view addSubview:label];
//    return view;
//}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
