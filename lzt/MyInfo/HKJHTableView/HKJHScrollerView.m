//
//  LXQScrollerView.m
//  memuDemo
//
//  Created by Jerry on 2017/7/5.
//  Copyright © 2017年 Jerry. All rights reserved.
//

#import "HKJHScrollerView.h"

#import "AFNetworking.h"
#import "FuncPublic.h"
#import "Constants.h"
#import "WToast.h"
#import "UserData.h"
#import "UIScrollView+MyScrollView.h"
#import "MJRefresh.h"
#import "UIImageView+WebCache.h"
#import "HKJHTableViewCell.h"
#define ApearFooterCount 1 //数据量大于8条则显示上拉加载

#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height

@interface HKJHScrollerView ()<UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource >
{
    
    NSMutableArray *dataSourceYHK;
    NSMutableArray *dataSourceDHK;

    int startContentOffsetX;
    int willEndContentOffsetX;
    int endContentOffsetX;
    
    int page;
    int limit;
    int dhksumCount;
    int yhksumCount;
    UIView *emptyView;
    
    int flagYHK;
    int flagdhk;
    UILabel *emptydhkLabel;
     UILabel *emptyyhkLabel;
    
}
@property (nonatomic, strong) UITableView *DHKTableView;
@property (nonatomic, strong) UITableView *YHKTableView;
//@property (nonatomic, strong) UILabel *repayedCorpus;//已收本金
//@property (nonatomic, strong) UILabel *repayedInterest;//已收利息


@property (nonatomic, strong) UIScrollView  *bigScrollerView;
@property (nonatomic, strong) UIView        *line;
@property (nonatomic, strong) UIView        *topView;
@property (nonatomic, assign) NSInteger     selectIndex;
@property (nonatomic, strong) NSArray       *titleArray;
@property (nonatomic, assign) NSInteger     count;
@property(nonatomic, assign) int NavHeight;

@end

@implementation HKJHScrollerView

- (instancetype)initWithFrame:(CGRect)frame
                   titleArray:(NSArray *)array
{
    self = [super initWithFrame:frame];
    if (self) {
        self.bigScrollerView.pagingEnabled = YES;
        self.selectIndex = 0;
        self.titleArray = array;
        self.count = array.count;
        if (iPhoneX) {
            _NavHeight = 20;
        }else {
            _NavHeight = 0;
        }
        
         page = 1;
        limit = 10;
        dataSourceDHK = [[NSMutableArray alloc]init];
        dataSourceYHK = [[NSMutableArray alloc]init];
        [self.con showHudInView:self hint:@"加载中"];
        // [self loadViewHeaderData];//载入章节头数据
          [self.con showHudInView:self.con.view hint:@"载入中"];
        [self loadData:1]; //待回款
        [self.con hideHud];
        [self prepareTopUI];
        [self prepareScrollerViewUI];
        [self tableHeaderDidTriggerRefresh];
        
       
        
        
        
        
    }
    return self;
}

- (void)loadData:(int)type {
    page = 1;
    limit = 10;
    NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
    NSString *url =[NSString stringWithFormat:@"%@%@/%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"user",userInfo[@"userId"],@"/repays"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setValue:@"iOS" forKey:@"from"];
    [param setValue:InnerVersion forKey:@"version"];
    [param setValue:userInfo[@"token"] forKey:@"token"];
    [param setValue:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    [param setValue:[NSString stringWithFormat:@"%d", limit] forKey:@"limit"];
    
    if (type == 1) { //待回款
        [param setValue:@"1" forKey:@"status"];
    }else if(type == 2){ //已回款
        [param setValue:@"2" forKey:@"status"];
    }
    
    [NetManager GetRequestWithUrlString:url andDic:param finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
       
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        if ([result[@"resultCode"] boolValue]) {
            [self.con showHint:result[@"resultMsg"] yOffset:0];
        }else {
            if (type == 1) { //待回款
                NSArray *array = result[@"resultData"];
                if (array.count  > 0) {
                    emptydhkLabel.hidden = YES;
                    [dataSourceDHK removeAllObjects];//清空
                    [dataSourceDHK addObjectsFromArray:array];
                    dhksumCount = [result[@"sumCount"] intValue];
                    page = 1;//记录第一次请求的页,重置为第一页
                    [self.DHKTableView reloadData];
                    if (dataSourceDHK.count > ApearFooterCount) {//指定数量的数据才显示上拉加载
                        self.DHKTableView.mj_footer.hidden = false;
                    }
                    [self.DHKTableView.mj_header endRefreshing];
                    [self DHYcheckFooterState];//检查footer状态
                }else {
                    emptydhkLabel.hidden = NO;
                    [self.DHKTableView.mj_header endRefreshing];
                }
                
            }else if(type == 2){
                NSArray *array = result[@"resultData"];
                if (array.count  > 0) {
                    emptyyhkLabel.hidden = YES;
                    [dataSourceYHK removeAllObjects];//清空
                    [dataSourceYHK addObjectsFromArray:array];
                    yhksumCount = [result[@"sumCount"] intValue];
                    page = 1;//记录第一次请求的页,重置为第一页
                    [self.YHKTableView reloadData];
                    if (dataSourceYHK.count > ApearFooterCount) {//指定数量的数据才显示上拉加载
                        self.YHKTableView.mj_footer.hidden = false;
                    }
                    [self.YHKTableView.mj_header endRefreshing];
                    [self YHKcheckFooterState];//检查footer状态
                }else {
                    [self.YHKTableView.mj_header endRefreshing];
                    emptyyhkLabel.hidden = NO;
                }
                
            }
          // [self loadViewHeaderData];//载入章节头数据
        }
       // [self.con hideHud];
    } failed:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        if(error.code == -1009){
            [self.con showHint:@"网络连接失败，请检查网络状态。" yOffset:0];
        }else if(error.code == -1004){
            [self.con showHint:@"服务器开了个小差。" yOffset:0];
        }else if(error.code == -1001){
            [self.con showHint:@"请求超时，请检查网络状态。" yOffset:0];
        }
        if (type == 1) {
            [self.DHKTableView.mj_header endRefreshing];
        }else {
            [self.YHKTableView.mj_header endRefreshing];
        }
        [self.con hideHud];
    }];
    
}
- (void)prepareTopUI
{
    self.line  = [[UIView alloc] initWithFrame:CGRectMake(0, 45+_NavHeight, kWidth / self.count, 1)];
    self.line.backgroundColor =[UIColor colorWithRed:255 /255.0 green:0 / 255.0 blue:0 /255.0 alpha:1];
    
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0+_NavHeight, kWidth, 46)];
    self.topView.backgroundColor = [UIColor whiteColor];
    
    for (NSInteger i = 0; i < self.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(kWidth / self.count * i, 0, kWidth / self.count, 45);
        [button setTitle:_titleArray[i] forState:UIControlStateNormal];
        button.titleLabel.font =  [UIFont fontWithName:@"Helvetica-Light" size:18];
        [button setTitleColor: [UIColor darkGrayColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        [self.topView addSubview:button];
    }
    [self.topView addSubview:self.line];
    [self addSubview:self.topView];
    [self changeButtonTextColor];
}

- (void)prepareScrollerViewUI
{
    self.bigScrollerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 46+_NavHeight, kWidth, self.frame.size.height-46)];
    self.bigScrollerView.contentSize = CGSizeMake(kWidth * self.count, self.frame.size.height-46-_NavHeight);
    self.bigScrollerView.scrollEnabled = YES;
    self.bigScrollerView.pagingEnabled = YES;
    self.bigScrollerView.delegate = self;
      self.bigScrollerView.showsHorizontalScrollIndicator = false;
    [self addSubview:self.bigScrollerView];
    
    for (NSInteger i = 0; i < self.count; i++) {
        if (i == 0) {
            [self initSecondView: (int)i];
        }else if(i == 1){
            [self initSecondView: (int)i];
        }
    }
    
}
-(void) DHYcheckFooterState {
    if(dataSourceDHK.count == dhksumCount ){
        [self.DHKTableView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.DHKTableView.mj_footer endRefreshing];
    }
}
-(void) YHKcheckFooterState {
    if(dataSourceYHK.count == yhksumCount ){
        [self.YHKTableView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.YHKTableView.mj_footer endRefreshing];
    }
}
- (void)loadMoreData:(int)type {
    page++;
    limit = 10;
    NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
    NSString *url =[NSString stringWithFormat:@"%@%@/%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"user",userInfo[@"userId"],@"/repays"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setValue:@"iOS" forKey:@"from"];
    [param setValue:InnerVersion forKey:@"version"];
    [param setValue:userInfo[@"token"] forKey:@"token"];
    [param setValue:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    [param setValue:[NSString stringWithFormat:@"%d", limit] forKey:@"limit"];
    
    if (type == 1) { //待回款
        [param setValue:@"1" forKey:@"status"];
    }else if(type == 2){ //已回款
        [param setValue:@"2" forKey:@"status"];
    }
    
    [NetManager GetRequestWithUrlString:url andDic:param finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        if ([result[@"resultCode"] boolValue]) {
            [self.con showHint:result[@"resultMsg"] yOffset:0];
        }else {
            if (type == 1) { //待回款
                NSArray *array = result[@"resultData"];
                [dataSourceDHK addObjectsFromArray:array];
                [self.DHKTableView reloadData];
                [self DHYcheckFooterState];//检查footer状态
            }else if(type == 2){
                NSArray *array = result[@"resultData"];
                
                [dataSourceYHK addObjectsFromArray:array];

                [self.YHKTableView reloadData];
                [self YHKcheckFooterState];//检查footer状态
            }
           // [self loadViewHeaderData];//载入章节头数据
        }
       
    } failed:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        if(error.code == -1009){
            [self.con showHint:@"网络连接失败，请检查网络状态。" yOffset:0];
        }else if(error.code == -1004){
            [self.con showHint:@"服务器开了个小差。" yOffset:0];
        }else if(error.code == -1001){
            [self.con showHint:@"请求超时，请检查网络状态。" yOffset:0];
        }
        if (type == 1) {
            [self.DHKTableView.mj_header endRefreshing];
        }else {
            [self.YHKTableView.mj_header endRefreshing];
        }
        [self.con hideHud];
    }];
}
//下拉刷新
- (void)tableHeaderDidTriggerRefresh {
#ifdef __IPHONE_11_0
    if ([_DHKTableView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
        if (@available(iOS 11.0, *)) {
            _DHKTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
        }
    }
#endif
    _DHKTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
       
        [self loadData:1];
    }];
    _DHKTableView.mj_footer  = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self loadMoreData:1];
    }];
     self.DHKTableView.mj_footer.hidden = YES;//默认隐藏
    
#ifdef __IPHONE_11_0
    if ([_YHKTableView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
        if (@available(iOS 11.0, *)) {
            _YHKTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
        }
    }
#endif
    _YHKTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadData:2];
    }];
   
    _YHKTableView.mj_footer  = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self loadMoreData:2];
    }];
    _YHKTableView.mj_footer.hidden = YES;//默认隐藏
}
- (void)initSecondView: (int)i {
    if (i == 0) {
       // UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, kHeight - 60)];
      //  _DHKTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kWidth, kHeight - 60-_NavHeight) style:UITableViewStylePlain];
        _DHKTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, kWidth,kHeight - 60-_NavHeight) style:UITableViewStylePlain];
        _DHKTableView.backgroundColor = [UIColor colorWithRed:242.0 / 255 green:242.0 / 255 blue:242.0 / 255 alpha:1];
        _DHKTableView.tag = 0;
        //注册
        [_DHKTableView registerNib:[UINib nibWithNibName:@"HKJHTableViewCell" bundle:nil]  forCellReuseIdentifier:@"ncell"];
        _DHKTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _DHKTableView.delegate = self;
        _DHKTableView.dataSource = self;
        _DHKTableView.rowHeight = 270;
        _DHKTableView.estimatedRowHeight = 0;
        
        emptydhkLabel = [[UILabel alloc]init];
        emptydhkLabel.frame = CGRectMake(_DHKTableView.frame.origin.x, _DHKTableView.frame.origin.y+200, _DHKTableView.frame.size.width, 40);
        emptydhkLabel.textAlignment = NSTextAlignmentCenter;
        emptydhkLabel.text = @"没有待回款计划";
        emptydhkLabel.textColor = [UIColor lightGrayColor];
        emptydhkLabel.hidden = YES;
        //emptydhkLabel.backgroundColor = [UIColor redColor];
        emptydhkLabel.font = [UIFont fontWithName:@"PingFang" size:13];
        [_DHKTableView addSubview:emptydhkLabel];
        [_DHKTableView bringSubviewToFront:emptydhkLabel];
      //  [view addSubview:_DHKTableView];
        
        [self.bigScrollerView addSubview:_DHKTableView];
        
    }else if(i == 1){
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(kWidth * i, 0, kWidth, kHeight - 60-_NavHeight)];
        _YHKTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width,view.frame.size.height-10) style:UITableViewStylePlain];
        _YHKTableView.backgroundColor = [UIColor colorWithRed:242.0 / 255 green:242.0 / 255 blue:242.0 / 255 alpha:1];
        _YHKTableView.tag = 1;
        //注册
        [_YHKTableView registerNib:[UINib nibWithNibName:@"HKJHTableViewCell" bundle:nil]  forCellReuseIdentifier:@"cell"];
        _YHKTableView.delegate = self;
        _YHKTableView.dataSource = self;
        _YHKTableView.rowHeight = 270;
        _YHKTableView.estimatedRowHeight = 0;
        _YHKTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        emptyyhkLabel = [[UILabel alloc]init];
        emptyyhkLabel.hidden = YES;
        emptyyhkLabel.frame = CGRectMake(_YHKTableView.frame.origin.x, 200, _YHKTableView.frame.size.width, 40);
        emptyyhkLabel.textAlignment = NSTextAlignmentCenter;
        emptyyhkLabel.text = @"没有已回款计划!";
        emptyyhkLabel.textColor = [UIColor lightGrayColor];
        emptyyhkLabel.font = [UIFont fontWithName:@"PingFang" size:13];
       // [view addSubview:emptyyhkLabel];
       // [_YHKTableView bringSubviewToFront:view];
        [_YHKTableView addSubview:emptyyhkLabel];
        [_YHKTableView bringSubviewToFront:emptyyhkLabel];
         [view addSubview:_YHKTableView];
    
        [self.bigScrollerView addSubview:view];
    }
}

- (void)buttonAction:(UIButton *)button
{
    self.selectIndex = button.tag;
    //滑动刷新
    if (self.selectIndex == 0 ) {
        if ( dataSourceDHK.count == 0) {
            [self loadData:1];
        }else {
            [_DHKTableView reloadData];
        }
        
    }else if (self.selectIndex == 1 ) {
        if ( dataSourceYHK.count == 0) {
            [self loadData:2];
        }else {
            [_YHKTableView reloadData];
        }
        
    }
    [self changeButtonTextColor];
    [self changeLinePlaceWithIndex:button.tag];
    [self changeScrollerViewPlace];
}

//改变滚动视图位置
- (void)changeScrollerViewPlace
{
    [UIView animateWithDuration:0.2 animations:^{
        
        CGPoint offset = self.bigScrollerView.contentOffset;
        offset.x = kWidth * self.selectIndex;
        self.bigScrollerView.contentOffset = offset;
    }];
}

//改变选中字体颜色
- (void)changeButtonTextColor
{
    for (UIView *view in [self.topView subviews]) {
        
        if ([view isKindOfClass:[UIButton class]]) {
            
            UIButton *button = (UIButton *)view;
            
            if (button.tag == self.selectIndex) {
                [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            }else{
                [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            }
        }
    }
}

//改变line位置
- (void)changeLinePlaceWithIndex:(NSInteger)index
{
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.line.frame;
      
        frame.origin.x = kWidth / self.count * index;
        self.line.frame = frame;
    }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{    //拖动前的起始坐标
    [emptyView removeFromSuperview];
    startContentOffsetX = scrollView.contentOffset.x;
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{    //将要停止前的坐标
    willEndContentOffsetX = scrollView.contentOffset.x;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    endContentOffsetX = scrollView.contentOffset.x;
    if (endContentOffsetX < willEndContentOffsetX && willEndContentOffsetX < startContentOffsetX) { //画面从右往左移动，前一页
        CGFloat x = scrollView.contentOffset.x;
        self.selectIndex = x / kWidth;
        [self changeButtonTextColor];
        [self changeLinePlaceWithIndex:self.selectIndex];
        
        //滑动刷新
        if (self.selectIndex == 0 ) {
            if ( dataSourceDHK.count == 0) {
                [self loadData:1];
            }else {
                [_DHKTableView reloadData];
            }
            
        }else if (self.selectIndex == 1 ) {
            if ( dataSourceYHK.count == 0) {
                [self loadData:2];
            }else {
                [_YHKTableView reloadData];
            }
            
        }
        
        
    } else if (endContentOffsetX > willEndContentOffsetX && willEndContentOffsetX > startContentOffsetX) {//画面从左往右移动，后一页
        
        CGFloat x = scrollView.contentOffset.x;
        self.selectIndex = x / kWidth;
        [self changeButtonTextColor];
        [self changeLinePlaceWithIndex:self.selectIndex];
        
        //滑动刷新
        if (self.selectIndex == 0 ) {
            if ( dataSourceDHK.count == 0) {
                [self loadData:1];
            }else {
                [_DHKTableView reloadData];
            }
            
        }else if (self.selectIndex == 1 ) {
            if ( dataSourceYHK.count == 0) {
                [self loadData:2];
            }else {
                [_YHKTableView reloadData];
            }
            
        }
        
        
        
    }
}
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{

//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        if (tableView.tag == 0) {
            return dataSourceDHK.count;
        }else{
            return dataSourceYHK.count;
        }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (tableView.tag == 0) {//待回款
        HKJHTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ncell" forIndexPath:indexPath];
        if (!cell) {
            cell = [[HKJHTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ncell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.name.text = dataSourceDHK[indexPath.row][@"name"];
        NSString *time = [FuncPublic getTime:dataSourceDHK[indexPath.row][@"repayDay"]];
        cell.repayDay.text = [time substringToIndex:10];
        NSString *str = [FuncPublic getTime:dataSourceDHK[indexPath.row][@"time"]];
        cell.acturlTime.text = [str substringToIndex:10];
        cell.interest.text = [NSString stringWithFormat:@"%.2f", [dataSourceDHK[indexPath.row][@"interest"] doubleValue] /100 + [dataSourceDHK[indexPath.row][@"raisingInterest"] doubleValue] /100];
        cell.repayedCorpus.text = [NSString stringWithFormat:@"%.2f", [dataSourceDHK[indexPath.row][@"corpus"] doubleValue] / 100];
        cell.period.text = [NSString stringWithFormat:@"%@/%@", dataSourceDHK[indexPath.row][@"period"],  dataSourceDHK[indexPath.row][@"length"] ];
        cell.firstView.layer.cornerRadius = 5;
        cell.firstView.layer.borderWidth = 1;
        cell.firstView.layer.borderColor = [UIColor colorWithRed:243.0/255 green:186.0/255 blue:190.0/255 alpha:1].CGColor;
        return cell;
        
    }else{//已回款
        HKJHTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        if (!cell) {
            cell = [[HKJHTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.name.text = dataSourceYHK[indexPath.row][@"name"];
        NSString *time = [FuncPublic getTime:dataSourceYHK[indexPath.row][@"repayDay"]];
        cell.repayDay.text = [time substringToIndex:10];
        NSString *str = [FuncPublic getTime:dataSourceYHK[indexPath.row][@"time"]];
        cell.acturlTime.text = [str substringToIndex:10];
        cell.interest.text = [NSString stringWithFormat:@"%.2f", [dataSourceYHK[indexPath.row][@"interest"] doubleValue] /100 + [dataSourceYHK[indexPath.row][@"raisingInterest"] doubleValue] /100];
        cell.repayedCorpus.text = [NSString stringWithFormat:@"%.2f", [dataSourceYHK[indexPath.row][@"corpus"] doubleValue] / 100];
        cell.period.text = [NSString stringWithFormat:@"%@/%@", dataSourceYHK[indexPath.row][@"period"],  dataSourceYHK[indexPath.row][@"length"] ];
        cell.firstView.layer.cornerRadius = 5;
        cell.firstView.layer.borderWidth = 1;
        cell.firstView.layer.borderColor = [UIColor colorWithRed:243.0/255 green:186.0/255 blue:190.0/255 alpha:1].CGColor;
        return cell;
        
    }
    
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView.tag == 0) {
         NSLog(@"sdf");
    }else {
        NSLog(@"sdf");
    }
   
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, 34)];
    view.backgroundColor= [UIColor colorWithRed:252.0/255.0 green:213/255.0 blue:216/255.0 alpha:1];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 2, 100, 30)];
    label.textColor = [UIColor darkGrayColor];
    label.font = [UIFont fontWithName:@"PingFang SC" size:13];
    label.text = @"已收本金(元)";
    
//    _repayedCorpus = [[UILabel alloc]initWithFrame:CGRectMake(110, 1, 90, 30)];
//    _repayedCorpus.textAlignment = NSTextAlignmentLeft;
//    _repayedCorpus.font = [UIFont systemFontOfSize:16];
//    _repayedCorpus.textColor = [UIColor redColor];
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(110, 2, 90, 30)];
    label2.textAlignment = NSTextAlignmentLeft;
    label2.font =  [UIFont fontWithName:@"PingFang SC" size:13];
    label2.text =[NSString stringWithFormat:@"%.2f", _repayedCorpus / 100];
    label2.textColor = [UIColor redColor];
    
    UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(200, 2, 110, 30)];
    label3.text = @"已收收益(元)";
    label3.font =  [UIFont fontWithName:@"PingFang SC" size:13];
    label3.textColor = [UIColor darkGrayColor];
   // label3.textColor = [UIColor redColor];
    //_repayedInterest = [[UILabel alloc]initWithFrame:CGRectMake(310, 1, 120, 30)];
   // label4.text = @"934.00";
    
    //_repayedInterest.font = [UIFont systemFontOfSize:16];
   // _repayedInterest.textColor = [UIColor redColor];
    
    UILabel *label4 = [[UILabel alloc]initWithFrame:CGRectMake(310, 2, 120, 30)];
    label4.text = [NSString stringWithFormat:@"%.2f", _repayedInterest/100];;
   // label4.textColor = [UIColor redColor];
    label4.font =  [UIFont fontWithName:@"PingFang SC" size:13];
    label4.textColor = [UIColor redColor];
    
    [view addSubview:label];
    [view addSubview:label2];
    //[view addSubview:_repayedCorpus];
    [view addSubview:label3];
    [view addSubview:label4];
  //  [view addSubview:_repayedInterest];
   
    return view;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}
@end

