//
//  LXQScrollerView.m
//  memuDemo
//
//  Created by Jerry on 2017/7/5.
//  Copyright © 2017年 Jerry. All rights reserved.
//

#import "ProjectScrollerView.h"
#import "CustomScrollView.h"
#import "AFNetworking.h"
#import "FuncPublic.h"
#import "Constants.h"
#import "WToast.h"
#import "UserData.h"
#import "UIScrollView+MyScrollView.h"
#import "MJRefresh.h"
#import "UIImageView+WebCache.h"
#import "ProjectCell.h"
#import "CPXQViewController.h"

#define ApearFooterCount 2 //数据量大于8条则显示上拉加载


#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height

@interface ProjectScrollerView ()<UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource  >
{
//    NSMutableArray *newsTypeList;
//    NSMutableArray *dataSource;
      NSMutableArray *dataSourceF;//第一列
    NSMutableArray *dataSourceS;//第二列
    NSMutableArray *dataSourceT;//第三列
    int flagF;
    int flagS;
    int flagT;

    int startContentOffsetX;
    int willEndContentOffsetX;
    int endContentOffsetX;

    int page;
    int limit;
    int FsumCount;
    int SsumCount;
    int TsumCount;
}
@property (nonatomic, strong) UITableView *FTableView;
@property (nonatomic, strong) UITableView *STableView;
@property (nonatomic, strong) UITableView *TTableView;
@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, strong) UILabel *emptyFLabel;
@property (nonatomic, strong) UILabel *emptySLabel;
@property (nonatomic, strong) UILabel *emptyTLabel;
@property (nonatomic, strong) UIScrollView  *bigScrollerView;
@property (nonatomic, strong) UIView        *line;
@property (nonatomic, strong) UIView        *topView;
@property (nonatomic, assign) NSInteger     selectIndex;
@property (nonatomic, strong) NSArray       *titleArray;
@property (nonatomic, assign) NSInteger     count;
@property (nonatomic, assign) NSInteger     NavHeight;
@property (nonatomic, assign) NSInteger     TabbarHeight;
@property (nonatomic, assign) int FourCount;//标类型为4的标的数据量
@end

@implementation ProjectScrollerView

- (instancetype)initWithFrame:(CGRect)frame
           titleArray:(NSArray *)array
{
    self = [super initWithFrame:frame];
    if (self) {
       // self.bigScrollerView.pagingEnabled = YES;
        self.selectIndex = 0;
        self.titleArray = array;
        self.count = array.count;
        if (iPhoneX) {
            _NavHeight  = 20;
            _TabbarHeight = 83;
        }else {
            _NavHeight = 0;
            _TabbarHeight = 49;
        }
        [self.con showHudInView:self.con.view hint:@"载入中"];
        [self loadData:1]; //
        [self.con hideHud];
       // page = 0;
       // rows = 10;
        [self prepareTopUI];
        [self prepareScrollerViewUI];
        [self tableHeaderDidTriggerRefresh];
        dataSourceF = [[NSMutableArray alloc]init];
        dataSourceS = [[NSMutableArray alloc]init];
        dataSourceT = [[NSMutableArray alloc]init];
        page = 1;
        limit = 10;
       
       
       // [self loadData:page andRows:row andType:0];
        
        
    }

    return self;
}
- (void)loadData:(int)type {
    page = 1;
    limit = 10;
    NSString *url =[NSString stringWithFormat:@"%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"plans"];
    url = [NSString stringWithFormat:@"%@?page=%d&limit=%d&from=%@&version=%@", url, page , limit, @"iOS", InnerVersion];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setValue:@"iOS" forKey:@"from"];
    [param setValue:InnerVersion forKey:@"version"];
    [param setValue:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    [param setValue:[NSString stringWithFormat:@"%d", limit] forKey:@"limit"];
    
    if (type == 0) { //投标宝
        [param setValue:@"0" forKey:@"type"];
    }else if(type == 1){ //新手标
        [param setValue:@"1" forKey:@"type"];
    }else {//产融宝
        [param setValue:@"2" forKey:@"type"];
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
                    [dataSourceS removeAllObjects];//清空
                    
                    [dataSourceS addObjectsFromArray:array];
                    SsumCount = [result[@"sumCount"] intValue];
                    page = 1;//记录第一次请求的页,重置为第一页
                    [self.STableView reloadData];
                    if (dataSourceS.count > ApearFooterCount) {//指定数量的数据才显示上拉加载
                        self.STableView.mj_footer.hidden = false;
                    }
                    [self.STableView.mj_header endRefreshing];
                    [self ScheckFooterState];//检查footer状态
                }else {
                     _emptySLabel.hidden = NO;
                    [self.STableView.mj_header endRefreshing];
                }
               
            }else if(type == 1){//
                NSArray *array = result[@"resultData"];
                if (array.count > 0) {
                    [dataSourceF removeAllObjects];//清空
                    
                    [dataSourceF addObjectsFromArray:array];
                    FsumCount = [result[@"sumCount"] intValue];
                    page = 1;//记录第一次请求的页,重置为第一页
                    [self.FTableView reloadData];
                    if (dataSourceF.count > ApearFooterCount) {//指定数量的数据才显示上拉加载
                        self.FTableView.mj_footer.hidden = false;
                    }
                    [self.FTableView.mj_header endRefreshing];
                    [self FcheckFooterState];//检查footer状态
                }else {
                    _emptyFLabel.hidden = NO;
                    [self.FTableView.mj_header endRefreshing];
                }
                
            }else {
                NSArray *array = result[@"resultData"];
                if (array.count > 0) {
                    [dataSourceT removeAllObjects];//清空
                    [dataSourceT addObjectsFromArray:array];
                    TsumCount = [result[@"sumCount"] intValue];
                    page = 1;//记录第一次请求的页,重置为第一页
                    [self.TTableView reloadData];
                    if (dataSourceT.count > ApearFooterCount) {//指定数量的数据才显示上拉加载
                        self.TTableView.mj_footer.hidden = false;
                    }
                    [self.TTableView.mj_header endRefreshing];
                    [self TcheckFooterState];//检查footer状态
                }else {
                    _emptyTLabel.hidden = NO;
                    [self.TTableView.mj_header endRefreshing];
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
            [self.STableView.mj_header endRefreshing];
        }else if(type == 1){
            [self.FTableView.mj_header endRefreshing];
        }else{
            [self.TTableView.mj_header endRefreshing];
        }
       
    }];

}
- (void)loadMoreData:(int)type {
    page++;
    limit = 10;
    
    NSString *url =[NSString stringWithFormat:@"%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"plans"];
    url = [NSString stringWithFormat:@"%@?page=%d&limit=%d&from=%@&version=%@", url, page , limit, @"iOS", InnerVersion];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setValue:@"iOS" forKey:@"from"];
    [param setValue:InnerVersion forKey:@"version"];
    [param setValue:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    [param setValue:[NSString stringWithFormat:@"%d", limit] forKey:@"limit"];
    
    if (type == 0) { //投标宝
        [param setValue:@"0" forKey:@"type"];
    }else if(type == 1){ //新手标
        [param setValue:@"1" forKey:@"type"];
    }else {//产融宝
        [param setValue:@"2" forKey:@"type"];
    }
    
    [NetManager GetRequestWithUrlString:url andDic:param finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
      //  [self.con showHudInView:self hint:@"加载中"];
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        if ([result[@"resultCode"] boolValue]) {
            [self.con showHint:result[@"resultMsg"] yOffset:0];
        }else {
            if (type == 0) { //
                NSArray *array = result[@"resultData"];
                [dataSourceS addObjectsFromArray:array];
                [self.STableView reloadData];
                [self ScheckFooterState];
            }else if(type == 1){
                NSArray *array = result[@"resultData"];
               
                    [dataSourceF addObjectsFromArray:array];
                
                    [self.FTableView reloadData];
                
                    [self FcheckFooterState];//检查footer状态
                
            }else {
                NSArray *array = result[@"resultData"];
                
                    [dataSourceT addObjectsFromArray:array];
                
                    [self.TTableView reloadData];
    
                    [self TcheckFooterState];//检查footer状态
              
            
            }
        }
        //[self.con hideHud];
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
            [self.STableView.mj_header endRefreshing];
        }else if(type == 1){
            [self.FTableView.mj_header endRefreshing];
        }else{
            [self.TTableView.mj_header endRefreshing];
        }
        //[self.con hideHud];
    }];
    
}
-(void) FcheckFooterState {
    if(dataSourceF.count == FsumCount ){
        [self.FTableView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.FTableView.mj_footer endRefreshing];
    }
}
-(void) ScheckFooterState {
    if(dataSourceS.count == SsumCount ){
        [self.STableView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.STableView.mj_footer endRefreshing];
    }
}
-(void)TcheckFooterState {
    if(dataSourceT.count == TsumCount ){
        [self.TTableView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.TTableView.mj_footer endRefreshing];
    }
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
    self.bigScrollerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 46+_NavHeight, kWidth, self.frame.size.height - 46-_NavHeight-_TabbarHeight)];
    self.bigScrollerView.contentSize = CGSizeMake(kWidth * self.count, self.frame.size.height - 46- _NavHeight- _TabbarHeight);
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
    if ([_FTableView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
        if (@available(iOS 11.0, *)) {
            _FTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
        }
    }
#endif
    _FTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadData:1];
    }];
    _FTableView.mj_footer  = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self loadMoreData:1];
    }];
    _FTableView.mj_footer.hidden = YES;//默认隐藏
#ifdef __IPHONE_11_0
    if ([_STableView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
        if (@available(iOS 11.0, *)) {
            _STableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
        }
    }
#endif
    _STableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadData:0];
    }];
    _STableView.mj_footer  = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self loadMoreData:0];
    }];
    _STableView.mj_footer.hidden = YES;//默认隐藏
#ifdef __IPHONE_11_0
    if ([_TTableView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
        if (@available(iOS 11.0, *)) {
            _TTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
        }
    }
#endif
    _TTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadData:2];
    }];
    _TTableView.mj_footer  = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self loadMoreData:2];
    }];
    _TTableView.mj_footer.hidden = YES;//默认隐藏
}
- (void)initSecondView: (int)i {
    if (i == 0) {
       
        _FTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, kWidth,kHeight - 60-_NavHeight-_TabbarHeight) style:UITableViewStylePlain];
        _FTableView.backgroundColor = [UIColor colorWithRed:242.0 / 255 green:242.0 / 255 blue:242.0 / 255 alpha:1];
        _FTableView.tag = 0;
        //注册
        [_FTableView registerNib:[UINib nibWithNibName:@"ProjectCell" bundle:nil]  forCellReuseIdentifier:@"fcell"];
        _FTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _FTableView.delegate = self;
        _FTableView.dataSource = self;
        _FTableView.rowHeight = 190;
        _FTableView.estimatedRowHeight = 0;
        
        _emptyFLabel = [[UILabel alloc]init];
        _emptyFLabel.frame = CGRectMake(_FTableView.frame.origin.x, 200, _FTableView.frame.size.width, 40);
        _emptyFLabel.hidden = YES;
        _emptyFLabel.textAlignment = NSTextAlignmentCenter;
        _emptyFLabel.text = @"没有未使用的红包!";
        _emptyFLabel.textColor = [UIColor lightGrayColor];
        _emptyFLabel.font = [UIFont fontWithName:@"PingFang" size:13];
        [_FTableView addSubview:_emptyFLabel];
        [_FTableView bringSubviewToFront:_emptyFLabel];
        
       // [view addSubview:_usedTableView];
        [self.bigScrollerView addSubview:_FTableView];

    }else if(i == 1){
        
        //TZGGTableViewController *tzgg = [[TZGGTableViewController alloc]init];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(kWidth * i, 0, kWidth, kHeight-48-_NavHeight-_TabbarHeight)];
        _STableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width,view.frame.size.height-10) style:UITableViewStylePlain];
        _STableView.backgroundColor = [UIColor colorWithRed:242.0 / 255 green:242.0 / 255 blue:242.0 / 255 alpha:1];
        _STableView.tag = 1;
        //注册
        [_STableView registerNib:[UINib nibWithNibName:@"ProjectCell" bundle:nil]  forCellReuseIdentifier:@"scell"];
        _STableView.delegate = self;
        _STableView.dataSource = self;
        _STableView.rowHeight = 190;
        _STableView.estimatedRowHeight = 0;
        _STableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        //_emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,view.frame.size.width, 40)];
        
        _emptySLabel = [[UILabel alloc]init];
        _emptySLabel.hidden = YES;
        _emptySLabel.frame = CGRectMake(_STableView.frame.origin.x, 200, _STableView.frame.size.width, 40);
        _emptySLabel.textAlignment = NSTextAlignmentCenter;
        _emptySLabel.text = @"没有已使用的红包!";
        _emptySLabel.textColor = [UIColor lightGrayColor];
        _emptySLabel.font = [UIFont fontWithName:@"PingFang" size:13];
        [_STableView addSubview:_emptySLabel];
        [_STableView bringSubviewToFront:_emptySLabel];
        
        [view addSubview:_STableView];
        [self.bigScrollerView addSubview:view];
    }else {
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(kWidth * i, 0, kWidth, kHeight-50-_NavHeight-_TabbarHeight)];
        _TTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width,view.frame.size.height-10) style:UITableViewStylePlain];
        _TTableView.backgroundColor = [UIColor colorWithRed:242.0 / 255 green:242.0 / 255 blue:242.0 / 255 alpha:1];
        _TTableView.tag = 2;
        //注册
        [_TTableView registerNib:[UINib nibWithNibName:@"ProjectCell" bundle:nil]  forCellReuseIdentifier:@"tcell"];
        _TTableView.delegate = self;
        _TTableView.dataSource = self;
        _TTableView.rowHeight = 190;
        _TTableView.estimatedRowHeight = 0;
        _TTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        _emptyTLabel = [[UILabel alloc]init];
        _emptyTLabel.hidden = YES;
        _emptyTLabel.frame = CGRectMake(_TTableView.frame.origin.x, 200, _TTableView.frame.size.width, 40);
        _emptyTLabel.textAlignment = NSTextAlignmentCenter;
        _emptyTLabel.text = @"没有已过期的红包!";
        _emptyTLabel.textColor = [UIColor lightGrayColor];
        _emptyTLabel.font = [UIFont fontWithName:@"PingFang" size:13];
        [_TTableView addSubview:_emptyTLabel];
        [_TTableView bringSubviewToFront:_emptyTLabel];
        
        [view addSubview:_TTableView];
        [self.bigScrollerView addSubview:view];
    }
}

- (void)buttonAction:(UIButton *)button
{
    self.selectIndex = button.tag;
    //滑动刷新
    if (self.selectIndex == 1 ) {
        if ( dataSourceS.count == 0) {
            [self loadData:0];
        }else {
            [_STableView reloadData];
        }
        
    }else if (self.selectIndex == 2 ) {
        if ( dataSourceT.count == 0) {
            [self loadData:2];
        }else {
            [_TTableView reloadData];
        }
        
    }else if (self.selectIndex == 0 ) {
        if ( dataSourceF.count == 0) {
            [self loadData:1];
        }else {
            [_FTableView reloadData];
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
        self.selectIndex = x / kWidth;
        [self changeLinePlaceWithIndex:self.selectIndex];
        [self changeButtonTextColor];
        
        
        //滑动刷新
        if (self.selectIndex == 1 ) {
            if ( dataSourceS.count == 0) {
                [self loadData:0];
            }else {
                [_STableView reloadData];
            }
            
        }else if (self.selectIndex == 2 ) {
            if ( dataSourceT.count == 0) {
                [self loadData:2];
            }else {
                [_TTableView reloadData];
            }
            
        }else if (self.selectIndex == 0 ) {
            if ( dataSourceF.count == 0) {
                [self loadData:1];
            }else {
                [_FTableView reloadData];
            }
            
        }

    } else if (endContentOffsetX > willEndContentOffsetX && willEndContentOffsetX > startContentOffsetX) {//画面从左往右移动，后一页
        CGFloat x = scrollView.contentOffset.x;
        self.selectIndex = x / kWidth;
        [self changeLinePlaceWithIndex:self.selectIndex];
        [self changeButtonTextColor];
        
        
        //滑动刷新
        if (self.selectIndex == 1 ) {
            if ( dataSourceS.count == 0) {
                [self loadData:0];
            }else {
                [_STableView reloadData];
            }
            
        }else if (self.selectIndex == 2 ) {
            if ( dataSourceT.count == 0) {
                [self loadData:2];
            }else {
                [_TTableView reloadData];
            }
            
        }else if (self.selectIndex == 0 ) {
            if ( dataSourceF.count == 0) {
                [self loadData:1];
            }else {
                [_FTableView reloadData];
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
        return dataSourceF.count;
    }else if (self.selectIndex == 1){
        return dataSourceS.count;
    }else{
        return dataSourceT.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 0) {//
        
        ProjectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fcell"];
        if (!cell) {
            cell = [[ProjectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"fcell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.name.text = dataSourceF[indexPath.row][@"name"];
        //double rate = [_dataSource[indexPath.row][@"rate"] doubleValue]+ [_dataSource[indexPath.row][@"rasingRate"] doubleValue] ;
        if ([dataSourceF[indexPath.row][@"rasingRate"] doubleValue] > 0) {
            cell.rate.text =[NSString stringWithFormat:@"%.1f+%.1f", [dataSourceF[indexPath.row][@"rate"] doubleValue]/10, [dataSourceF[indexPath.row][@"rasingRate"] doubleValue]/10];
        }else {
            cell.rate.text =[NSString stringWithFormat:@"%.1f", [dataSourceF[indexPath.row][@"rate"] doubleValue]/10];
        }
        
        cell.time.text =[NSString stringWithFormat:@"%@", dataSourceF[indexPath.row][@"staging"]];
        cell.timetype.text = [FuncPublic getDate:dataSourceF[indexPath.row][@"stagingUnit"]];
        
        double i = [dataSourceF[indexPath.row][@"nowSum"] doubleValue] /  [dataSourceF[indexPath.row][@"amount"] doubleValue];
        NSString *str = dataSourceF[indexPath.row][@"name"];
        if ([ str isEqualToString:@"投标宝-2017112901"]) {
            if (i > 1) {
                NSLog(@"%f",i);
            }
        }
        cell.count = i;
        //cell.progressView.progress = 0;
        cell.progressView.progress = i;
        if(i == 0){
            cell.mjorstImage.hidden = false;
            cell.mjorstImage.image = [UIImage imageNamed:@"首投.png"];
        }else if(i >= 0.85 && i < 1){
            cell.mjorstImage.hidden = false;
            cell.mjorstImage.image = [UIImage imageNamed:@"满奖.png"];
        }else{
            cell.mjorstImage.hidden = true;
        }
        cell.allMoney.text = [NSString stringWithFormat:@"%.0f", [dataSourceF[indexPath.row][@"amount"] doubleValue] / 100];
        cell.percent.text = [NSString stringWithFormat:@"%d%%", (int)(i * 100)];
        cell.leftType.text = @"新客专享";
//        if ([dataSourceF[indexPath.row][@"type"] intValue] == 0) {
//            cell.leftType.text = @"投标宝";
//        }else if ([dataSourceF[indexPath.row][@"type"] intValue] == 1) {
//            cell.leftType.text = @"新客专享";
//        }else if ([dataSourceF[indexPath.row][@"type"] intValue] == 2) {
//            cell.leftType.text = @"产融宝";
//        }else {
//            cell.leftType.text = @"优选理财";
//        }
        
        //标类型:写死不利于以后扩展
        int index =[dataSourceF[indexPath.row][@"state"] intValue];
        switch (index) {
            case 1:
                cell.rightState.image = [UIImage imageNamed: @"还款中.png"];
                cell.rightState.hidden =false;
                cell.progressView.isGray = true;
                cell.leftBgImage.backgroundColor = [UIColor lightGrayColor];
                cell.leftBgImage.layer.cornerRadius = 10;
                cell.progressView.progressView.progressTintColor = [UIColor lightGrayColor];
                break;
            case 2:
                cell.rightState.image = [UIImage imageNamed: @"已还款.png"];
                cell.rightState.hidden = false;
                cell.progressView.isGray = true;
                cell.leftBgImage.backgroundColor = [UIColor lightGrayColor];
                cell.leftBgImage.layer.cornerRadius = 10;
                cell.progressView.progressView.progressTintColor = [UIColor lightGrayColor];
                break;
            default:
                cell.rightState.hidden = YES;
                cell.leftBgImage.backgroundColor = [UIColor colorWithRed:249.0/255 green:58.0/255 blue:79.0/255 alpha:1];
                cell.leftBgImage.layer.cornerRadius = 10;
                cell.progressView.progressView.progressTintColor = [UIColor colorWithRed:249.0/255 green:58.0/255 blue:79.0/255 alpha:1];
                break;
        }
        
        return cell;

    }else  if (tableView.tag == 1){//已使用
        ProjectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"scell"];
        if (!cell) {
            cell = [[ProjectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"scell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.name.text = dataSourceS[indexPath.row][@"name"];
        //double rate = [_dataSource[indexPath.row][@"rate"] doubleValue]+ [_dataSource[indexPath.row][@"rasingRate"] doubleValue] ;
        if ([dataSourceS[indexPath.row][@"rasingRate"] doubleValue] > 0) {
            cell.rate.text =[NSString stringWithFormat:@"%.1f+%.1f", [dataSourceS[indexPath.row][@"rate"] doubleValue]/10, [dataSourceS[indexPath.row][@"rasingRate"] doubleValue]/10];
        }else {
            cell.rate.text =[NSString stringWithFormat:@"%.1f", [dataSourceS[indexPath.row][@"rate"] doubleValue]/10];
        }
        
        cell.time.text =[NSString stringWithFormat:@"%@", dataSourceS[indexPath.row][@"staging"]];
        cell.timetype.text = [FuncPublic getDate:dataSourceS[indexPath.row][@"stagingUnit"]];
        
        double i = [dataSourceS[indexPath.row][@"nowSum"] doubleValue] /  [dataSourceS[indexPath.row][@"amount"] doubleValue];
        NSString *str = dataSourceS[indexPath.row][@"name"];
        if ([ str isEqualToString:@"投标宝-2017112901"]) {
            if (i > 1) {
                NSLog(@"%f",i);
            }
        }
        cell.count = i;
        if(i == 0){
            cell.mjorstImage.hidden = false;
            cell.mjorstImage.image = [UIImage imageNamed:@"首投.png"];
        }else if(i >= 0.85 && i < 1){
            cell.mjorstImage.hidden = false;
            cell.mjorstImage.image = [UIImage imageNamed:@"满奖.png"];
        }else{
            cell.mjorstImage.hidden = true;
        }
        cell.progressView.progress = i;
        cell.allMoney.text = [NSString stringWithFormat:@"%.0f", [dataSourceS[indexPath.row][@"amount"] doubleValue] / 100];
        cell.percent.text = [NSString stringWithFormat:@"%d%%", (int)(i * 100)];
        cell.leftType.text = @"投标宝";
//        if ([_dataSource[indexPath.row][@"type"] intValue] == 0) {
//            cell.leftType.text = @"投标宝";
//        }else if ([_dataSource[indexPath.row][@"type"] intValue] == 1) {
//            cell.leftType.text = @"新客专享";
//        }else if ([_dataSource[indexPath.row][@"type"] intValue] == 2) {
//            cell.leftType.text = @"产融宝";
//        }else {
//            cell.leftType.text = @"优选理财";
//        }
        
        //标类型:写死不利于以后扩展
        int index =[dataSourceS[indexPath.row][@"state"] intValue];
        switch (index) {
            case 1:
                cell.rightState.image = [UIImage imageNamed: @"还款中.png"];
                cell.rightState.hidden =false;
                cell.progressView.isGray = true;
                cell.leftBgImage.backgroundColor = [UIColor lightGrayColor];
                cell.leftBgImage.layer.cornerRadius = 10;
                cell.progressView.progressView.progressTintColor = [UIColor lightGrayColor];
                break;
            case 2:
                cell.rightState.image = [UIImage imageNamed: @"已还款.png"];
                cell.rightState.hidden = false;
                cell.progressView.isGray = true;
                cell.leftBgImage.backgroundColor = [UIColor lightGrayColor];
                cell.leftBgImage.layer.cornerRadius = 10;
                cell.progressView.progressView.progressTintColor = [UIColor lightGrayColor];
                break;
            default:
                cell.rightState.hidden = YES;
                cell.leftBgImage.backgroundColor = [UIColor colorWithRed:249.0/255 green:58.0/255 blue:79.0/255 alpha:1];
                cell.leftBgImage.layer.cornerRadius = 10;
                cell.progressView.progressView.progressTintColor = [UIColor colorWithRed:249.0/255 green:58.0/255 blue:79.0/255 alpha:1];
                break;
        }
        
        return cell;
    }else {//过期
        ProjectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tcell"];
        if (!cell) {
            cell = [[ProjectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tcell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.name.text = dataSourceT[indexPath.row][@"name"];
        //double rate = [_dataSource[indexPath.row][@"rate"] doubleValue]+ [_dataSource[indexPath.row][@"rasingRate"] doubleValue] ;
        if ([dataSourceT[indexPath.row][@"rasingRate"] doubleValue] > 0) {
            cell.rate.text =[NSString stringWithFormat:@"%.1f+%.1f", [dataSourceT[indexPath.row][@"rate"] doubleValue]/10, [dataSourceT[indexPath.row][@"rasingRate"] doubleValue]/10];
        }else {
            cell.rate.text =[NSString stringWithFormat:@"%.1f", [dataSourceT[indexPath.row][@"rate"] doubleValue]/10];
        }
        
        cell.time.text =[NSString stringWithFormat:@"%@", dataSourceT[indexPath.row][@"staging"]];
        cell.timetype.text = [FuncPublic getDate:dataSourceT[indexPath.row][@"stagingUnit"]];
        
        double i = [dataSourceT[indexPath.row][@"nowSum"] doubleValue] /  [dataSourceT[indexPath.row][@"amount"] doubleValue];
        NSString *str = dataSourceT[indexPath.row][@"name"];
        if ([ str isEqualToString:@"投标宝-2017112901"]) {
            if (i > 1) {
                NSLog(@"%f",i);
            }
        }
        cell.count = i;
        if(i == 0){
            cell.mjorstImage.hidden = false;
            cell.mjorstImage.image = [UIImage imageNamed:@"首投.png"];
        }else if(i >= 0.85 && i < 1){
            cell.mjorstImage.hidden = false;
            cell.mjorstImage.image = [UIImage imageNamed:@"满奖.png"];
        }else{
            cell.mjorstImage.hidden = true;
        }
        cell.progressView.progress = i;
        cell.allMoney.text = [NSString stringWithFormat:@"%.0f", [dataSourceT[indexPath.row][@"amount"] doubleValue] / 100];
        cell.percent.text = [NSString stringWithFormat:@"%d%%", (int)(i * 100)];
        cell.leftType.text = @"产融宝";
//        if ([_dataSource[indexPath.row][@"type"] intValue] == 0) {
//            cell.leftType.text = @"投标宝";
//        }else if ([_dataSource[indexPath.row][@"type"] intValue] == 1) {
//            cell.leftType.text = @"新客专享";
//        }else if ([_dataSource[indexPath.row][@"type"] intValue] == 2) {
//            cell.leftType.text = @"产融宝";
//        }else {
//            cell.leftType.text = @"优选理财";
//        }
        
        //标类型:写死不利于以后扩展
        int index =[dataSourceT[indexPath.row][@"state"] intValue];
        switch (index) {
            case 1:
                cell.rightState.image = [UIImage imageNamed: @"还款中.png"];
                cell.rightState.hidden =false;
                cell.progressView.isGray = true;
                cell.leftBgImage.backgroundColor = [UIColor lightGrayColor];
                cell.leftBgImage.layer.cornerRadius = 10;
                cell.progressView.progressView.progressTintColor = [UIColor lightGrayColor];
                break;
            case 2:
                cell.rightState.image = [UIImage imageNamed: @"已还款.png"];
                cell.rightState.hidden = false;
                cell.progressView.isGray = true;
                cell.leftBgImage.backgroundColor = [UIColor lightGrayColor];
                cell.leftBgImage.layer.cornerRadius = 10;
                cell.progressView.progressView.progressTintColor = [UIColor lightGrayColor];
                break;
            default:
                cell.rightState.hidden = YES;
                cell.leftBgImage.backgroundColor = [UIColor colorWithRed:249.0/255 green:58.0/255 blue:79.0/255 alpha:1];
                cell.leftBgImage.layer.cornerRadius = 10;
                cell.progressView.progressView.progressTintColor = [UIColor colorWithRed:249.0/255 green:58.0/255 blue:79.0/255 alpha:1];
                break;
        }
        
        return cell;
    }
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 0) {
        UIStoryboard *s = [UIStoryboard storyboardWithName:@"CPXQ" bundle:nil];
        CPXQViewController *cpxq = [s instantiateViewControllerWithIdentifier:@"CPXQViewController"];
        cpxq.cpId = [dataSourceF[indexPath.row][@"id"] intValue];
        cpxq.xktype = [dataSourceF[indexPath.row][@"type"] intValue];
        
        [self.con.navigationController pushViewController:cpxq animated:true];
    }else if(tableView.tag == 1){
        UIStoryboard *s = [UIStoryboard storyboardWithName:@"CPXQ" bundle:nil];
        CPXQViewController *cpxq = [s instantiateViewControllerWithIdentifier:@"CPXQViewController"];
        cpxq.cpId = [dataSourceS[indexPath.row][@"id"] intValue];
        cpxq.xktype = [dataSourceS[indexPath.row][@"type"] intValue];
        
        [self.con.navigationController pushViewController:cpxq animated:true];
    }else{
        UIStoryboard *s = [UIStoryboard storyboardWithName:@"CPXQ" bundle:nil];
        CPXQViewController *cpxq = [s instantiateViewControllerWithIdentifier:@"CPXQViewController"];
        cpxq.cpId = [dataSourceT[indexPath.row][@"id"] intValue];
        cpxq.xktype = [dataSourceT[indexPath.row][@"type"] intValue];
        
        [self.con.navigationController pushViewController:cpxq animated:true];
    }
}
#pragma mark - cell method

@end
