//
//  RankScrollView.m
//  lzt
//
//  Created by hwq on 2018/1/10.
//  Copyright © 2018年 hwq. All rights reserved.
//


#import "RankScrollView.h"
#import "CustomScrollView.h"
#import "AFNetworking.h"
#import "FuncPublic.h"
#import "Constants.h"
#import "WToast.h"
#import "UserData.h"
#import "UIScrollView+MyScrollView.h"
#import "MJRefresh.h"
#import "UIImageView+WebCache.h"
#import "RankTableViewCell.h"
#define ApearFooterCount 4 //数据量大于8条则显示上拉加载



@interface RankScrollerView ()<UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    //    NSMutableArray *newsTypeList;
    //    NSMutableArray *dataSource;
    NSMutableArray *dataSourceDay;
    NSMutableArray *dataSourceMonth;
    NSMutableArray *dataSourceTotal;
//    int flagUsed;
//    int flagNouse;
//    int flagYGQ;
    
    int startContentOffsetX;
    int willEndContentOffsetX;
    int endContentOffsetX;
    
    int page;
    int limit;
    int daysumCount;
    int monthsumCount;
    int totalsumCount;
}
@property (nonatomic, strong) UITableView *DayTableView;
@property (nonatomic, strong) UITableView *MonthTableView;
@property (nonatomic, strong) UITableView *TotalTableView;
@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, strong) UILabel *emptyDayLabel;
@property (nonatomic, strong) UILabel *emptyMonthLabel;
@property (nonatomic, strong) UILabel *emptyTotalLabel;
@property (nonatomic, strong) UIScrollView  *bigScrollerView;
@property (nonatomic, strong) UIView        *line;
@property (nonatomic, strong) UIView        *topView;
@property (nonatomic, assign) NSInteger     selectIndex;
@property (nonatomic, strong) NSArray       *titleArray;
@property (nonatomic, assign) NSInteger     count;
@property (nonatomic, assign) NSInteger     NavHeight;

@property (nonatomic, assign) int kWidth ;
@property (nonatomic, assign) int  kHeight;
@end

@implementation RankScrollerView

- (instancetype)initWithFrame:(CGRect)frame
                   titleArray:(NSArray *)array
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _kWidth  = frame.size.width;
        _kHeight =  frame.size.height;
        // [self loadData:page andRows:row andType:0];
        self.backgroundColor = [UIColor whiteColor];
        
        // self.bigScrollerView.pagingEnabled = YES;
        self.selectIndex = 0;
        self.titleArray = array;
        self.count = array.count;
        if (iPhoneX) {
            _NavHeight  = 20;
        }else {
            _NavHeight = 0;
        }
        
        [self.con showHudInView:self.con.view hint:@"载入中"];
        [self loadData:0]; //
        [self.con hideHud];
        
        // page = 0;
        // rows = 10;
        [self prepareTopUI];
        [self prepareScrollerViewUI];
       // [self tableHeaderDidTriggerRefresh];
        dataSourceDay = [[NSMutableArray alloc]init];
        dataSourceMonth = [[NSMutableArray alloc]init];
        dataSourceTotal = [[NSMutableArray alloc]init];
        page = 1;
        limit = 10;
        
        
        
    }
    
    return self;
}
- (void)loadData:(int)type {
    page = 1;
    limit = 10;
    NSString *url =[NSString stringWithFormat:@"%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"user/investment/ranking"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setValue:@"iOS" forKey:@"from"];
    [param setValue:InnerVersion forKey:@"version"];
    [param setValue:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    [param setValue:[NSString stringWithFormat:@"%d", limit] forKey:@"limit"];
    if (type == 0) { //
        [param setValue:@"day" forKey:@"key"];
    }else if(type == 1){ //
        [param setValue:@"month" forKey:@"key"];
    }else {//
        [param setValue:@"total" forKey:@"key"];
    }
    
    [NetManager GetRequestWithUrlString:url andDic:param finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        // [self.con showHudInView:self hint:@"加载中"];
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        int b = [result[@"resultCode"] intValue];
        if (b == 1) {
            [self.con showHint:result[@"resultMsg"] yOffset:0];
        }else if(b == 2){
            [[NSNotificationCenter defaultCenter]postNotificationName:@"tokenlost" object:nil];
        }else {
            if (type == 0) { //
                NSArray *array = result[@"resultData"];
                if (array.count > 0) {
                    [dataSourceDay removeAllObjects];//清空
                    [dataSourceDay addObjectsFromArray:array];
                    daysumCount = [result[@"sumCount"] intValue];
                    page = 1;//记录第一次请求的页,重置为第一页
                    [self.DayTableView reloadData];
                   // [self daycheckFooterState];
                }else {
                    _emptyDayLabel.hidden = NO;
                    [self.DayTableView.mj_header endRefreshing];
                }
                
            }else if(type == 1){//
                NSArray *array = result[@"resultData"];
                if (array.count > 0) {
                    [dataSourceMonth removeAllObjects];//清空
                    [dataSourceMonth addObjectsFromArray:array];
                    monthsumCount = [result[@"sumCount"] intValue];
                    page = 1;//记录第一次请求的页,重置为第一页
                    [self.MonthTableView reloadData];
                   // [self daycheckFooterState];
                }else {
                    _emptyMonthLabel.hidden = NO;
                    [self.MonthTableView.mj_header endRefreshing];
                }
                
            }else {
                NSArray *array = result[@"resultData"];
                if (array.count > 0) {
                    [dataSourceTotal removeAllObjects];//清空
                    [dataSourceTotal addObjectsFromArray:array];
                    totalsumCount = [result[@"sumCount"] intValue];
                    page = 1;//记录第一次请求的页,重置为第一页
                    [self.TotalTableView reloadData];
                   // [self totalcheckFooterState];
                }else {
                    _emptyTotalLabel.hidden = NO;
                    [self.TotalTableView.mj_header endRefreshing];
                }
                
            }
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
        if (type == 0) {
            [self.DayTableView.mj_header endRefreshing];
        }else if(type == 1){
            [self.MonthTableView.mj_header endRefreshing];
        }else{
            [self.TotalTableView.mj_header endRefreshing];
        }
        
    }];
    
}
//- (void)loadMoreData:(int)type {
//    page++;
//    limit = 10;
//    NSString *url =[NSString stringWithFormat:@"%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"user/investment/ranking"];
//    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
//    [param setValue:@"iOS" forKey:@"from"];
//    [param setValue:InnerVersion forKey:@"version"];
//    [param setValue:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
//    [param setValue:[NSString stringWithFormat:@"%d", limit] forKey:@"limit"];
//    if (type == 0) { //
//        [param setValue:@"day" forKey:@"key"];
//    }else if(type == 1){ //
//        [param setValue:@"month" forKey:@"key"];
//    }else {//
//        [param setValue:@"total" forKey:@"key"];
//    }
//
//
//    [NetManager GetRequestWithUrlString:url andDic:param finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        //  [self.con showHudInView:self hint:@"加载中"];
//        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
//        if ([result[@"resultCode"] boolValue]) {
//            [self.con showHint:result[@"resultMsg"] yOffset:0];
//        }else {
//            if (type == 0) { //未使用
//                NSArray *array = result[@"resultData"];
//                [dataSourceDay addObjectsFromArray:array];
//                [self.DayTableView reloadData];
//                [self daycheckFooterState];
//            }else if(type == 1){
//                NSArray *array = result[@"resultData"];
//
//                [dataSourceMonth addObjectsFromArray:array];
//
//                [self.MonthTableView reloadData];
//
//                [self monthcheckFooterState];//检查footer状态
//
//            }else {
//                NSArray *array = result[@"resultData"];
//
//                [dataSourceTotal addObjectsFromArray:array];
//
//                [self.TotalTableView reloadData];
//
//                [self totalcheckFooterState];//检查footer状态
//
//
//            }
//        }
//        //[self.con hideHud];
//    } failed:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"%@", error);
//        if(error.code == -1009){
//            [self.con showHint:@"网络连接失败，请检查网络状态。" yOffset:0];
//        }else if(error.code == -1004){
//            [self.con showHint:@"服务器开了个小差。" yOffset:0];
//        }else if(error.code == -1001){
//            [self.con showHint:@"请求超时，请检查网络状态。" yOffset:0];
//        }
//        if (type == 0) {
//            [self.DayTableView.mj_header endRefreshing];
//        }else if(type == 1){
//            [self.MonthTableView.mj_header endRefreshing];
//        }else{
//            [self.TotalTableView.mj_header endRefreshing];
//        }
//        //[self.con hideHud];
//    }];
//
//}
//-(void) daycheckFooterState {
//    if(dataSourceDay.count == daysumCount ){
//        [self.noUseTableView.mj_footer endRefreshingWithNoMoreData];
//    }else {
//        [self.noUseTableView.mj_footer endRefreshing];
//    }
//}
//-(void) monthcheckFooterState {
//    if(dataSourceUsed.count == usedsumCount ){
//        [self.usedTableView.mj_footer endRefreshingWithNoMoreData];
//    }else {
//        [self.usedTableView.mj_footer endRefreshing];
//    }
//}
//-(void) totalcheckFooterState {
//    if(dataSourceYGQ.count == ygqsumCount ){
//        [self.YGQTableView.mj_footer endRefreshingWithNoMoreData];
//    }else {
//        [self.YGQTableView.mj_footer endRefreshing];
//    }
//}
- (void)prepareTopUI
{
    self.line  = [[UIView alloc] initWithFrame:CGRectMake(0, 45+_NavHeight, _kWidth / self.count, 1)];
    self.line.backgroundColor =[UIColor colorWithRed:255 /255.0 green:0 / 255.0 blue:0 /255.0 alpha:1];
    
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0+_NavHeight, _kWidth, 46)];
    self.topView.backgroundColor = [UIColor whiteColor];
    
    for (NSInteger i = 0; i < self.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(_kWidth / self.count * i, 0+_NavHeight, _kWidth / self.count, 45);
        [button setTitle:_titleArray[i] forState:UIControlStateNormal];
        button.titleLabel.font =  [UIFont fontWithName:@"PingFang SC" size:17];
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
    self.bigScrollerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 46+_NavHeight, _kWidth, _kHeight-40)];
    self.bigScrollerView.contentSize = CGSizeMake(_kWidth * self.count,_kHeight-40 );
    self.bigScrollerView.scrollEnabled = YES;
    self.bigScrollerView.pagingEnabled = YES;
    self.bigScrollerView.delegate = self;
    [self addSubview:self.bigScrollerView];
    
    //  NSArray *array = @[[UIColor redColor], [UIColor yellowColor], [UIColor whiteColor]];
    //NSMutableArray *array2 = [[NSMutableArray alloc]init];
    
    
    
    
    for (NSInteger i = 0; i < self.count; i++) {
        if (i == 0) {
            [self initSecondView: (int)i];
        }else if(i == 1){
            [self initSecondView: (int)i];
        }else {
            [self initSecondView: (int)i];
        }
    }
    
}
//下拉刷新
- (void)tableHeaderDidTriggerRefresh {
#ifdef __IPHONE_11_0
    if ([_DayTableView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
        if (@available(iOS 11.0, *)) {
            _DayTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
        }
    }
#endif
    _DayTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadData:0];
    }];
//    _DayTableView.mj_footer  = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//        [self loadMoreData:0];
//    }];
//    _noUseTableView.mj_footer.hidden = YES;//默认隐藏
#ifdef __IPHONE_11_0
    if ([_MonthTableView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
        if (@available(iOS 11.0, *)) {
            _MonthTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
        }
    }
#endif
    _MonthTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadData:1];
    }];
//    _usedTableView.mj_footer  = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//        [self loadMoreData:1];
//    }];
   // _usedTableView.mj_footer.hidden = YES;//默认隐藏
#ifdef __IPHONE_11_0
    if ([_TotalTableView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
        if (@available(iOS 11.0, *)) {
            _TotalTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
        }
    }
#endif
    _TotalTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadData:2];
    }];
//    _YGQTableView.mj_footer  = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//        [self loadMoreData:2];
//    }];
//    _YGQTableView.mj_footer.hidden = YES;//默认隐藏
}
- (void)initSecondView: (int)i {
    if (i == 0) {
        
        _DayTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, _kWidth,_kHeight-40) style:UITableViewStylePlain];
        _DayTableView.backgroundColor = [UIColor colorWithRed:242.0 / 255 green:242.0 / 255 blue:242.0 / 255 alpha:1];
        _DayTableView.tag = 0;
        //注册
        [_DayTableView registerNib:[UINib nibWithNibName:@"RankTableViewCell" bundle:nil]  forCellReuseIdentifier:@"ncell"];
        _DayTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _DayTableView.delegate = self;
        _DayTableView.dataSource = self;
        _DayTableView.rowHeight = (_kHeight -46)*0.1;
        _DayTableView.estimatedRowHeight = 0;
       // _DayTableView.backgroundColor = [UIColor redColor];
//        _emptyDayLabel = [[UILabel alloc]init];
//        _emptyDayLabel.frame = CGRectMake(_DayTableView.frame.origin.x, 50, _DayTableView.frame.size.width, 40);
//        _emptyDayLabel.hidden = YES;
//        _emptyDayLabel.textAlignment = NSTextAlignmentCenter;
//        _emptyDayLabel.text = @"没有数据!";
//        _emptyDayLabel.textColor = [UIColor lightGrayColor];
//        _emptyDayLabel.font = [UIFont fontWithName:@"PingFang" size:13];
//        [_DayTableView addSubview:_emptyDayLabel];
//        [_DayTableView bringSubviewToFront:_emptyDayLabel];
        
        // [view addSubview:_usedTableView];
        [self.bigScrollerView addSubview:_DayTableView];
        
    }else if(i == 1){
        
        //TZGGTableViewController *tzgg = [[TZGGTableViewController alloc]init];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(_kWidth * i, 0, _kWidth, _kHeight-40)];
        _MonthTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width,view.frame.size.height-10) style:UITableViewStylePlain];
        _MonthTableView.backgroundColor = [UIColor colorWithRed:242.0 / 255 green:242.0 / 255 blue:242.0 / 255 alpha:1];
        _MonthTableView.tag = 1;
        //注册
        [_MonthTableView registerNib:[UINib nibWithNibName:@"RankTableViewCell" bundle:nil]  forCellReuseIdentifier:@"cell"];
        _MonthTableView.delegate = self;
        _MonthTableView.dataSource = self;
        _MonthTableView.rowHeight = (_kHeight -46) *0.1;
        _MonthTableView.estimatedRowHeight = 0;
        _MonthTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        //_emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,view.frame.size.width, 40)];
        
//        _emptyMonthLabel = [[UILabel alloc]init];
//        _emptyMonthLabel.hidden = YES;
//        _emptyMonthLabel.frame = CGRectMake(_MonthTableView.frame.origin.x, 50, _MonthTableView.frame.size.width, 40);
//        _emptyMonthLabel.textAlignment = NSTextAlignmentCenter;
//        _emptyMonthLabel.text = @"没有数据!";
//        _emptyMonthLabel.textColor = [UIColor lightGrayColor];
//        _emptyMonthLabel.font = [UIFont fontWithName:@"PingFang" size:13];
//        [_MonthTableView addSubview:_emptyMonthLabel];
//        [_MonthTableView bringSubviewToFront:_emptyMonthLabel];
//
        [view addSubview:_MonthTableView];
        [self.bigScrollerView addSubview:view];
    }else {
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(_kWidth * i, 0, _kWidth, _kHeight-40)];
        _TotalTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width,view.frame.size.height) style:UITableViewStylePlain];
        _TotalTableView.backgroundColor = [UIColor colorWithRed:242.0 / 255 green:242.0 / 255 blue:242.0 / 255 alpha:1];
        _TotalTableView.tag = 2;
        
        //注册
        [_TotalTableView registerNib:[UINib nibWithNibName:@"RankTableViewCell" bundle:nil]  forCellReuseIdentifier:@"ycell"];
        _TotalTableView.delegate = self;
        _TotalTableView.dataSource = self;
        _TotalTableView.rowHeight = (_kHeight -46) *0.1;
        _TotalTableView.estimatedRowHeight = 0;
        _TotalTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
//        _emptyTotalLabel = [[UILabel alloc]init];
//        _emptyTotalLabel.hidden = YES;
//        _emptyTotalLabel.frame = CGRectMake(_TotalTableView.frame.origin.x, 5, _TotalTableView.frame.size.width, 40);
//        _emptyTotalLabel.textAlignment = NSTextAlignmentCenter;
//        _emptyTotalLabel.text = @"没有已过期的红包!";
//        _emptyTotalLabel.textColor = [UIColor lightGrayColor];
//        _emptyTotalLabel.font = [UIFont fontWithName:@"PingFang" size:13];
//        [_TotalTableView addSubview:_emptyTotalLabel];
//        [_TotalTableView bringSubviewToFront:_emptyTotalLabel];
//
        [view addSubview:_TotalTableView];
        [self.bigScrollerView addSubview:view];
    }
}

- (void)buttonAction:(UIButton *)button
{
    self.selectIndex = button.tag;
    //滑动刷新
    if (self.selectIndex == 0 ) {
        if ( dataSourceDay.count == 0) {
            [self loadData:0];
        }else {
            [_DayTableView reloadData];
        }
        
    }else if (self.selectIndex == 1 ) {
        if ( dataSourceMonth.count == 0) {
            [self loadData:1];
        }else {
            [_MonthTableView reloadData];
        }
        
    }else if (self.selectIndex == 2 ) {
        if ( dataSourceTotal.count == 0) {
            [self loadData:2];
        }else {
            [_TotalTableView reloadData];
        }
        
    }
    [self changeLinePlaceWithIndex:button.tag];
    [self changeButtonTextColor];
    
    [self changeScrollerViewPlace];
}

//改变滚动视图位置
- (void)changeScrollerViewPlace
{
    [UIView animateWithDuration:0.2 animations:^{
        
        CGPoint offset = self.bigScrollerView.contentOffset;
        offset.x = _kWidth * self.selectIndex;
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
        frame.origin.x = _kWidth / self.count * index;
        self.line.frame = frame;
    }];
}
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    // 首先判断otherGestureRecognizer是不是系统pop手势
//    if ([otherGestureRecognizer.view isKindOfClass:NSClassFromString(@"UILayoutContainerView")]) {
//        // 再判断系统手势的state是began还是fail，同时判断scrollView的位置是不是正好在最左边
//        if (otherGestureRecognizer.state == UIGestureRecognizerStateBegan && self.bigScrollerView. contentOffset.x == 0) {
//            return YES;
//        }
//    }
//
//    return NO;
//}
#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{    //拖动前的起始坐标
    [_emptyView removeFromSuperview];
    startContentOffsetX = scrollView.contentOffset.x;
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{    //将要停止前的坐标
    willEndContentOffsetX = scrollView.contentOffset.x;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    endContentOffsetX = scrollView.contentOffset.x;
    if (endContentOffsetX < willEndContentOffsetX && willEndContentOffsetX < startContentOffsetX) { //画面从右往左移动，前一页
        CGFloat x = scrollView.contentOffset.x;
        self.selectIndex = x / _kWidth;
        [self changeLinePlaceWithIndex:self.selectIndex];
        [self changeButtonTextColor];
        
        
        //滑动刷新
        if (self.selectIndex == 0 ) {
            if ( dataSourceDay.count == 0) {
                [self loadData:0];
            }else {
                [_DayTableView reloadData];
            }
            
        }else if (self.selectIndex == 1 ) {
            if ( dataSourceMonth.count == 0) {
                [self loadData:1];
            }else {
                [_MonthTableView reloadData];
            }
            
        }else if (self.selectIndex == 2 ) {
            if ( dataSourceTotal.count == 0) {
                [self loadData:2];
            }else {
                [_TotalTableView reloadData];
            }
            
        }
        
    } else if (endContentOffsetX > willEndContentOffsetX && willEndContentOffsetX > startContentOffsetX) {//画面从左往右移动，后一页
        CGFloat x = scrollView.contentOffset.x;
        self.selectIndex = x / _kWidth;
        [self changeLinePlaceWithIndex:self.selectIndex];
        [self changeButtonTextColor];
        
        
        //滑动刷新
        if (self.selectIndex == 0 ) {
            if ( dataSourceDay.count == 0) {
                [self loadData:0];
            }else {
                [_DayTableView reloadData];
            }
            
        }else if (self.selectIndex == 1 ) {
            if ( dataSourceMonth.count == 0) {
                [self loadData:1];
            }else {
                [_MonthTableView reloadData];
            }
            
        }else if (self.selectIndex == 2 ) {
            if ( dataSourceTotal.count == 0) {
                [self loadData:2];
            }else {
                [_TotalTableView reloadData];
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.selectIndex == 0) {
        return dataSourceDay.count;
    }else if (self.selectIndex == 1){
        return dataSourceMonth.count;
    }else{
        return dataSourceTotal.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectIndex == 0) {//
        
        RankTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ncell" forIndexPath:indexPath];
        if (!cell) {
            cell = [[RankTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ncell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.name.text = dataSourceDay[indexPath.row][@"user_name"];
        
        cell.money.text = [NSString stringWithFormat:@"¥%.0f", [dataSourceDay[indexPath.row][@"sum_money"] doubleValue] / 100 ];
        if (indexPath.row == 0) {
            cell.imageview.image = [UIImage imageNamed:@"奖牌1"];

        }else if(indexPath.row == 1){
            cell.imageview.image = [UIImage imageNamed:@"奖牌2"];
        }else if(indexPath.row == 2){
            cell.imageview.image = [UIImage imageNamed:@"奖牌3"];
        }else{
            cell.rank.text = [NSString stringWithFormat:@"%d", (int)indexPath.row+1];
            cell.rank.textColor = [UIColor lightGrayColor];
            cell.name.textColor = [UIColor lightGrayColor];
            cell.money.textColor = [UIColor lightGrayColor];
            // cell.imageView.hidden = YES;
        }
        
        return cell;
        
    }else  if (self.selectIndex == 1){//
        RankTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        if (!cell) {
            cell = [[RankTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.name.text = dataSourceMonth[indexPath.row][@"user_name"];
        
        cell.money.text = [NSString stringWithFormat:@"¥%.0f", [dataSourceMonth[indexPath.row][@"sum_money"] doubleValue] / 100 ];
        if (indexPath.row == 0) {
            cell.imageview.image = [UIImage imageNamed:@"奖牌1"];
            
        }else if(indexPath.row == 1){
            cell.imageview.image = [UIImage imageNamed:@"奖牌2"];
        }else if(indexPath.row == 2){
            cell.imageview.image = [UIImage imageNamed:@"奖牌3"];
        }else{
            cell.rank.text = [NSString stringWithFormat:@"%d", (int)indexPath.row + 1];
           // cell.imageView.hidden = YES;
            cell.rank.textColor = [UIColor lightGrayColor];
            cell.name.textColor = [UIColor lightGrayColor];
            cell.money.textColor = [UIColor lightGrayColor];
        }
        return cell;
        
    }else {
        RankTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ycell" forIndexPath:indexPath];
        if (!cell) {
            cell = [[RankTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ycell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.name.text = dataSourceTotal[indexPath.row][@"user_name"];
        
        cell.money.text = [NSString stringWithFormat:@"¥%.0f", [dataSourceTotal[indexPath.row][@"sum_money"] doubleValue] / 100 ];
        if (indexPath.row == 0) {
            cell.imageview.image = [UIImage imageNamed:@"奖牌1"];
            
        }else if(indexPath.row == 1){
            cell.imageview.image = [UIImage imageNamed:@"奖牌2"];
        }else if(indexPath.row == 2){
            cell.imageview.image = [UIImage imageNamed:@"奖牌3"];
        }else{
            cell.rank.text = [NSString stringWithFormat:@"%d", (int)indexPath.row+1];
          //   cell.imageView.hidden = YES;
            cell.rank.textColor = [UIColor lightGrayColor];
            cell.name.textColor = [UIColor lightGrayColor];
            cell.money.textColor = [UIColor lightGrayColor];
        }
        return cell;
    }
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, 34)];
    view.backgroundColor= UIColorFromRGB(0xebebeb);
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(_kWidth / self.count * 0, 3, _kWidth/self.count, 30)];
    label.textColor = [UIColor darkGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"PingFang SC" size:15];
    label.text = @"排名";
    
    //    _repayedCorpus = [[UILabel alloc]initWithFrame:CGRectMake(110, 1, 90, 30)];
    //    _repayedCorpus.textAlignment = NSTextAlignmentLeft;
    //    _repayedCorpus.font = [UIFont systemFontOfSize:16];
    //    _repayedCorpus.textColor = [UIColor redColor];
    
    
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(_kWidth /self.count *2, 3, _kWidth/self.count, 30)];
    label2.text = @"投资总额(元)";
    label2.textAlignment = NSTextAlignmentCenter;
    label2.font =  [UIFont fontWithName:@"PingFang SC" size:15];
    label2.textColor = [UIColor darkGrayColor];
    
    // label3.textColor = [UIColor redColor];
    //_repayedInterest = [[UILabel alloc]initWithFrame:CGRectMake(310, 1, 120, 30)];
    // label4.text = @"934.00";
    
    //_repayedInterest.font = [UIFont systemFontOfSize:16];
    // _repayedInterest.textColor = [UIColor redColor];
    
  
    
    [view addSubview:label];
    [view addSubview:label2];
    //  [view addSubview:_repayedInterest];
    
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}
@end
    

    
    
