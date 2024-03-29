//
//  NewFoundationViewController.m
//  lzt
//
//  Created by hwq on 2018/1/11.
//  Copyright © 2018年 hwq. All rights reserved.
//

#import "NewFoundationViewController.h"
#import "FoundationTableViewCell.h"
#import "HDTableViewCell.h"
#import "HDDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "htmlViewController.h"
#import "ServerViewController.h"
#import "FggViewController.h"
#import "ZXViewController.h"
#import "CJWTViewController.h"
#define ApearFooter 1

@interface NewFoundationViewController ()<UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NaviHeight;
@property (assign, nonatomic) int count;
@property (nonatomic, assign) int page;//分页
@property (nonatomic, assign) int limit;//每页数据量
@property (nonatomic, assign) int total;//总数据量
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation NewFoundationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _count = 0;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    self.tabBarController.navigationController.navigationItem.title = @"发现";
    if (iPhoneX) {
        _NaviHeight.constant += 20;
    }
    //[self hideBackButtonText];
   // [self tableHeaderDidTriggerRefresh];
    //originContentSizeHeight = _contentSizeView.frame.size.height;
    //   int i = _contentSizeHeight.constant;
    // int i= self.tableView.contentSize.height;
    // originContentSizeHeight = _contentSizeHeight;
    //CGRect rect =  _contentSizeView.frame;
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
            //            if (array.count > 2) {
            //                CGRect rect = _contentSizeView.frame;
            //                _contentSizeView.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, originContentSizeHeight + 220 * (array.count - 2));
            //                _tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, _tableView.frame.size.height + 220 * (array.count - 2));
            //            }
            //_contentSizeHeight.constant
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
                [self.tableView.mj_header endRefreshing];
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
                //                [self.tableView.mj_header endRefreshing];
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
    [self.tableView registerNib:[UINib nibWithNibName:@"FoundationTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
      [self.tableView registerNib:[UINib nibWithNibName:@"HDTableViewCell" bundle:nil] forCellReuseIdentifier:@"hcell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //self.tableView.rowHeight = 220;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
        self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
        self.tableView.mj_footer.hidden = YES;//默认隐藏
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
- (void)cpjs:(id)sender {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"HTML" bundle:nil];
    htmlViewController *html = [s instantiateViewControllerWithIdentifier:@"htmlViewController"];
    html.name = @"产品介绍";
    [self.navigationController pushViewController:html animated:true];
}

- (void)gsjj:(id)sender {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"HTML" bundle:nil];
    htmlViewController *html = [s instantiateViewControllerWithIdentifier:@"htmlViewController"];
    html.name = @"公司简介";
    [self.navigationController pushViewController:html animated:true];
}
- (void)tdgl:(id)sender {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"HTML" bundle:nil];
    htmlViewController *html = [s instantiateViewControllerWithIdentifier:@"htmlViewController"];
    html.name = @"团队管理";
    [self.navigationController pushViewController:html animated:true];
}


- (void)gszz:(id)sender {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"HTML" bundle:nil];
    htmlViewController *html = [s instantiateViewControllerWithIdentifier:@"htmlViewController"];
    html.name = @"平台资质";
    [self.navigationController pushViewController:html animated:true];
}
- (void)xxptTouched:(id)sender {
    //    XXPRViewController *xxpl = [self.storyboard instantiateViewControllerWithIdentifier:@"XXPRViewController"];
    //    [self.navigationController pushViewController:xxpl animated:true];
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"HTML" bundle:nil];
    htmlViewController *news = [s instantiateViewControllerWithIdentifier:@"htmlViewController"];
    news.name = @"关于我们";
    [self.navigationController pushViewController:news animated:true];
}


- (void)ptggTouched:(id)sender {
    
    FggViewController *ptgg = [self.storyboard instantiateViewControllerWithIdentifier:@"FggViewController"];
    [self.navigationController pushViewController:ptgg animated:true];
}

- (void)mtzxTouched:(id)sender {
    //UIStoryboard *s = [UIStoryboard storyboardWithName:@"HomePage" bundle:nil];
    ZXViewController *news = [self.storyboard instantiateViewControllerWithIdentifier:@"ZXViewController"];
    [self.navigationController pushViewController:news animated:true];
}
- (void)cjwtTouched:(id)sender {
    
    CJWTViewController *hwq = [self.storyboard instantiateViewControllerWithIdentifier:@"CJWTViewController"];
    [self.navigationController pushViewController:hwq animated:true];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 300;
    }else {
        return  220;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }else{
         return _dataSource.count;
    }
   
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        FoundationTableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" ];
        if (!cell) {
           
            cell = [[FoundationTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UITapGestureRecognizer *ptggtap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ptggTouched:)];
        
        [cell.ptgg addGestureRecognizer:ptggtap];
        UITapGestureRecognizer *mtzxtap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(mtzxTouched:)];
        [cell.mtzx addGestureRecognizer:mtzxtap];
        
        UITapGestureRecognizer *cjwttap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cjwtTouched:)];
        [cell.cjwt addGestureRecognizer:cjwttap];
        
        UITapGestureRecognizer *gsjjtap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gsjj:)];
        [cell.gsjj addGestureRecognizer:gsjjtap];
        
        UITapGestureRecognizer *tdgltap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tdgl:)];
        [cell.tdgl addGestureRecognizer:tdgltap];
        
        UITapGestureRecognizer *ptzztap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gszz:)];
        [cell.ptzz addGestureRecognizer:ptzztap];
        
        UITapGestureRecognizer *cpjstap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cpjs:)];
        [cell.cpjs addGestureRecognizer:cpjstap];
        
        return cell;
    }else {
        HDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"hcell" ];
        if (!cell) {
            cell = [[HDTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"hcell"];
        }
           cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSString *date = [FuncPublic getTime:_dataSource[indexPath.row][@"startTime"]];
        cell.date.text =[ date substringToIndex:10];
        cell.name.text = _dataSource[indexPath.row][@"title"];
        NSString *image = _dataSource[indexPath.row][@"picture"];
        image = [image stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [cell.image sd_setImageWithURL:[NSURL URLWithString:image] placeholderImage:[UIImage imageNamed:@"ytdz.png"]] ;
        if ([_dataSource[indexPath.row][@"status"] intValue] == 1) {//不正常
            // cell.backgroundColor = [UIColor lightGrayColor];
//            cell.bg.backgroundColor = UIColorFromRGB(0xebebeb);
//            cell.contentView.backgroundColor = UIColorFromRGB(0xf9f9f9);
            cell.overImage.hidden = false;
            cell.overbg.hidden = false;
        }else {
            //cell.backgroundColor = [UIColor lightGrayColor];
//            cell.bg.backgroundColor = [UIColor whiteColor];
//            cell.contentView.backgroundColor = UIColorFromRGB(0xf9f9f9);
            cell.overImage.hidden = true;
            cell.overbg.hidden = true;
        }
        
        return cell;
    }
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        
    }else {
        if ([_dataSource[indexPath.row][@"status"] intValue]== 1) {
            
        }else {
            UIStoryboard *s = [UIStoryboard storyboardWithName:@"HomePage" bundle:nil];
            HDDetailViewController *html = [s instantiateViewControllerWithIdentifier:@"HDDetailViewController"];
            html.name = _dataSource[indexPath.row][@"title"];
            html.url = _dataSource[indexPath.row][@"url"];
            [self.navigationController pushViewController:html animated:true];
            
        }
    }
    
    //    NewsDetailViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"NewsDetailViewController"];
    //    detail.noticeId = [NewsDatas[indexPath.row][@"id"] intValue];
    //    detail.typeName = @"资讯详情";
    //    [self.navigationController pushViewController:detail animated:true];
}
@end
