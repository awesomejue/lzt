//
//  LXQScrollerView.m
//  memuDemo
//
//  Created by Jerry on 2017/7/5.
//  Copyright © 2017年 Jerry. All rights reserved.
//

#import "LXQScrollerView.h"
#import "CustomScrollView.h"
#import "AFNetworking.h"
#import "FuncPublic.h"
#import "Constants.h"
#import "WToast.h"
#import "UserData.h"
#import "UIScrollView+MyScrollView.h"
#import "MJRefresh.h"
#import "UIImageView+WebCache.h"
#import "HBTableViewCell.h"
#define ApearFooterCount 4 //数据量大于8条则显示上拉加载

#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height

@interface LXQScrollerView ()<UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource  >
{
//    NSMutableArray *newsTypeList;
//    NSMutableArray *dataSource;
      NSMutableArray *dataSourceUsed;
    NSMutableArray *dataSourceNOUse;
    NSMutableArray *dataSourceYGQ;
    int flagUsed;
    int flagNouse;
    int flagYGQ;

    int startContentOffsetX;
    int willEndContentOffsetX;
    int endContentOffsetX;

    int page;
    int limit;
    int usedsumCount;
    int nousesumCount;
    int ygqsumCount;
}
@property (nonatomic, strong) UITableView *usedTableView;
@property (nonatomic, strong) UITableView *noUseTableView;
@property (nonatomic, strong) UITableView *YGQTableView;
@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, strong) UILabel *emptyUsedLabel;
@property (nonatomic, strong) UILabel *emptyYGQLabel;
@property (nonatomic, strong) UILabel *emptyNoUsedLabel;
@property (nonatomic, strong) UIScrollView  *bigScrollerView;
@property (nonatomic, strong) UIView        *line;
@property (nonatomic, strong) UIView        *topView;
@property (nonatomic, assign) NSInteger     selectIndex;
@property (nonatomic, strong) NSArray       *titleArray;
@property (nonatomic, assign) NSInteger     count;
@property (nonatomic, assign) NSInteger     NavHeight;
@end

@implementation LXQScrollerView

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
        }else {
            _NavHeight = 0;
        }
        [self.con showHudInView:self.con.view hint:@"载入中"];
        [self loadData:0]; //未使用
        [self.con hideHud];
       // page = 0;
       // rows = 10;
        [self prepareTopUI];
        [self prepareScrollerViewUI];
        [self tableHeaderDidTriggerRefresh];
        dataSourceNOUse = [[NSMutableArray alloc]init];
        dataSourceUsed = [[NSMutableArray alloc]init];
        dataSourceYGQ = [[NSMutableArray alloc]init];
        page = 1;
        limit = 10;
       
       
       // [self loadData:page andRows:row andType:0];
        
        
    }

    return self;
}
- (void)loadData:(int)type {
    page = 1;
    limit = 10;
    NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
    NSString *url =[NSString stringWithFormat:@"%@%@/%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"user",userInfo[@"userId"],@"/account/vouchers"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setValue:@"iOS" forKey:@"from"];
    [param setValue:InnerVersion forKey:@"version"];
    [param setValue:userInfo[@"token"] forKey:@"token"];
    [param setValue:@"0" forKey:@"type"];
    [param setValue:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    [param setValue:[NSString stringWithFormat:@"%d", limit] forKey:@"limit"];
    
    if (type == 0) { //未使用
        [param setValue:@"0" forKey:@"status"];
    }else if(type == 1){ //已使用
        [param setValue:@"2" forKey:@"status"];
    }else {//过期
        [param setValue:@"1" forKey:@"status"];
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
            if (type == 0) { //未使用
                NSArray *array = result[@"resultData"];
                if (array.count > 0) {
                    [dataSourceNOUse removeAllObjects];//清空
                    [dataSourceNOUse addObjectsFromArray:array];
                    nousesumCount = [result[@"sumCount"] intValue];
                    page = 1;//记录第一次请求的页,重置为第一页
                    [self.noUseTableView reloadData];
                    if (dataSourceNOUse.count > ApearFooterCount) {//指定数量的数据才显示上拉加载
                        self.noUseTableView.mj_footer.hidden = false;
                    }
                    [self.noUseTableView.mj_header endRefreshing];
                    [self nousecheckFooterState];//检查footer状态
                }else {
                     _emptyNoUsedLabel.hidden = NO;
                    [self.noUseTableView.mj_header endRefreshing];
                }
               
            }else if(type == 1){//已使用
                NSArray *array = result[@"resultData"];
                if (array.count > 0) {
                    [dataSourceUsed removeAllObjects];//清空
                    [dataSourceUsed addObjectsFromArray:array];
                    usedsumCount = [result[@"sumCount"] intValue];
                    page = 1;//记录第一次请求的页,重置为第一页
                    [self.usedTableView reloadData];
                    if (dataSourceUsed.count > ApearFooterCount) {//指定数量的数据才显示上拉加载
                        self.usedTableView.mj_footer.hidden = false;
                    }
                    [self.usedTableView.mj_header endRefreshing];
                    [self usedcheckFooterState];//检查footer状态
                }else {
                    _emptyUsedLabel.hidden = NO;
                    [self.usedTableView.mj_header endRefreshing];
                }
                
            }else {
                NSArray *array = result[@"resultData"];
                if (array.count > 0) {
                    [dataSourceYGQ removeAllObjects];//清空
                    [dataSourceYGQ addObjectsFromArray:array];
                    ygqsumCount = [result[@"sumCount"] intValue];
                    page = 1;//记录第一次请求的页,重置为第一页
                    [self.YGQTableView reloadData];
                    if (dataSourceYGQ.count > ApearFooterCount) {//指定数量的数据才显示上拉加载
                        self.YGQTableView.mj_footer.hidden = false;
                    }
                    [self.YGQTableView.mj_header endRefreshing];
                    [self ygqcheckFooterState];//检查footer状态
                }else {
                    _emptyYGQLabel.hidden = NO;
                    [self.YGQTableView.mj_header endRefreshing];
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
            [self.noUseTableView.mj_header endRefreshing];
        }else if(type == 1){
            [self.usedTableView.mj_header endRefreshing];
        }else{
            [self.YGQTableView.mj_header endRefreshing];
        }
       
    }];

}
- (void)loadMoreData:(int)type {
    page++;
    limit = 10;
    NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
    NSString *url =[NSString stringWithFormat:@"%@%@/%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"user",userInfo[@"userId"],@"/account/vouchers"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setValue:@"iOS" forKey:@"from"];
    [param setValue:InnerVersion forKey:@"version"];
    [param setValue:userInfo[@"token"] forKey:@"token"];
    [param setValue:@"0" forKey:@"type"];
    [param setValue:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    [param setValue:[NSString stringWithFormat:@"%d", limit] forKey:@"limit"];
    
    if (type == 0) { //未使用
        [param setValue:@"0" forKey:@"status"];
    }else if(type == 1){ //已使用
        [param setValue:@"2" forKey:@"status"];
    }else {//过期
        [param setValue:@"1" forKey:@"status"];
    }
    
    [NetManager GetRequestWithUrlString:url andDic:param finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
      //  [self.con showHudInView:self hint:@"加载中"];
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        if ([result[@"resultCode"] boolValue]) {
            [self.con showHint:result[@"resultMsg"] yOffset:0];
        }else {
            if (type == 0) { //未使用
                NSArray *array = result[@"resultData"];
                [dataSourceNOUse addObjectsFromArray:array];
                [self.noUseTableView reloadData];
                [self nousecheckFooterState];
            }else if(type == 1){
                NSArray *array = result[@"resultData"];
               
                    [dataSourceUsed addObjectsFromArray:array];
                
                    [self.usedTableView reloadData];
                
                    [self usedcheckFooterState];//检查footer状态
                
            }else {
                NSArray *array = result[@"resultData"];
                
                    [dataSourceYGQ addObjectsFromArray:array];
                
                    [self.YGQTableView reloadData];
    
                    [self ygqcheckFooterState];//检查footer状态
              
            
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
            [self.noUseTableView.mj_header endRefreshing];
        }else if(type == 1){
            [self.usedTableView.mj_header endRefreshing];
        }else{
            [self.YGQTableView.mj_header endRefreshing];
        }
        //[self.con hideHud];
    }];
    
}
-(void) nousecheckFooterState {
    if(dataSourceNOUse.count == nousesumCount ){
        [self.noUseTableView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.noUseTableView.mj_footer endRefreshing];
    }
}
-(void) usedcheckFooterState {
    if(dataSourceUsed.count == usedsumCount ){
        [self.usedTableView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.usedTableView.mj_footer endRefreshing];
    }
}
-(void) ygqcheckFooterState {
    if(dataSourceYGQ.count == ygqsumCount ){
        [self.YGQTableView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.YGQTableView.mj_footer endRefreshing];
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
    self.bigScrollerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 46+_NavHeight, kWidth, self.frame.size.height - 46-_NavHeight)];
    self.bigScrollerView.contentSize = CGSizeMake(kWidth * self.count, self.frame.size.height - 46- _NavHeight);
    self.bigScrollerView.scrollEnabled = YES;
    self.bigScrollerView.pagingEnabled = YES;
    self.bigScrollerView.delegate = self;
    self.bigScrollerView.showsHorizontalScrollIndicator = false;
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
    if ([_noUseTableView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
        if (@available(iOS 11.0, *)) {
            _noUseTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
        }
    }
#endif
    _noUseTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadData:0];
    }];
    _noUseTableView.mj_footer  = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self loadMoreData:0];
    }];
    _noUseTableView.mj_footer.hidden = YES;//默认隐藏
#ifdef __IPHONE_11_0
    if ([_usedTableView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
        if (@available(iOS 11.0, *)) {
            _usedTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
        }
    }
#endif
    _usedTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadData:1];
    }];
    _usedTableView.mj_footer  = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self loadMoreData:1];
    }];
    _usedTableView.mj_footer.hidden = YES;//默认隐藏
#ifdef __IPHONE_11_0
    if ([_YGQTableView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
        if (@available(iOS 11.0, *)) {
            _YGQTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
        }
    }
#endif
    _YGQTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadData:2];
    }];
    _YGQTableView.mj_footer  = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self loadMoreData:2];
    }];
    _YGQTableView.mj_footer.hidden = YES;//默认隐藏
}
- (void)initSecondView: (int)i {
    if (i == 0) {
       
        _noUseTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, kWidth,kHeight - 60-_NavHeight) style:UITableViewStylePlain];
        _noUseTableView.backgroundColor = [UIColor colorWithRed:242.0 / 255 green:242.0 / 255 blue:242.0 / 255 alpha:1];
        _noUseTableView.tag = 0;
        //注册
        [_noUseTableView registerNib:[UINib nibWithNibName:@"HBTableViewCell" bundle:nil]  forCellReuseIdentifier:@"ncell"];
        _noUseTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _noUseTableView.delegate = self;
        _noUseTableView.dataSource = self;
        _noUseTableView.rowHeight = 120;
        _noUseTableView.estimatedRowHeight = 0;
        
        _emptyNoUsedLabel = [[UILabel alloc]init];
        _emptyNoUsedLabel.frame = CGRectMake(_noUseTableView.frame.origin.x, 200, _noUseTableView.frame.size.width, 40);
        _emptyNoUsedLabel.hidden = YES;
        _emptyNoUsedLabel.textAlignment = NSTextAlignmentCenter;
        _emptyNoUsedLabel.text = @"没有未使用的红包!";
        _emptyNoUsedLabel.textColor = [UIColor lightGrayColor];
        _emptyNoUsedLabel.font = [UIFont fontWithName:@"PingFang" size:13];
        [_noUseTableView addSubview:_emptyNoUsedLabel];
        [_noUseTableView bringSubviewToFront:_emptyNoUsedLabel];
        
       // [view addSubview:_usedTableView];
        [self.bigScrollerView addSubview:_noUseTableView];

    }else if(i == 1){
        
        //TZGGTableViewController *tzgg = [[TZGGTableViewController alloc]init];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(kWidth * i, 0, kWidth, kHeight-48-_NavHeight)];
        _usedTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width,view.frame.size.height-10) style:UITableViewStylePlain];
        _usedTableView.backgroundColor = [UIColor colorWithRed:242.0 / 255 green:242.0 / 255 blue:242.0 / 255 alpha:1];
        _usedTableView.tag = 1;
        //注册
        [_usedTableView registerNib:[UINib nibWithNibName:@"HBTableViewCell" bundle:nil]  forCellReuseIdentifier:@"cell"];
        _usedTableView.delegate = self;
        _usedTableView.dataSource = self;
        _usedTableView.rowHeight = 120;
        _usedTableView.estimatedRowHeight = 0;
        _usedTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        //_emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,view.frame.size.width, 40)];
        
        _emptyUsedLabel = [[UILabel alloc]init];
        _emptyUsedLabel.hidden = YES;
        _emptyUsedLabel.frame = CGRectMake(_usedTableView.frame.origin.x, 200, _usedTableView.frame.size.width, 40);
        _emptyUsedLabel.textAlignment = NSTextAlignmentCenter;
        _emptyUsedLabel.text = @"没有已使用的红包!";
        _emptyUsedLabel.textColor = [UIColor lightGrayColor];
        _emptyUsedLabel.font = [UIFont fontWithName:@"PingFang" size:13];
        [_usedTableView addSubview:_emptyUsedLabel];
        [_usedTableView bringSubviewToFront:_emptyUsedLabel];
        
        [view addSubview:_usedTableView];
        [self.bigScrollerView addSubview:view];
    }else {
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(kWidth * i, 0, kWidth, kHeight-50-_NavHeight)];
        _YGQTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width,view.frame.size.height-10) style:UITableViewStylePlain];
        _YGQTableView.backgroundColor = [UIColor colorWithRed:242.0 / 255 green:242.0 / 255 blue:242.0 / 255 alpha:1];
        _YGQTableView.tag = 2;
        //注册
        [_YGQTableView registerNib:[UINib nibWithNibName:@"HBTableViewCell" bundle:nil]  forCellReuseIdentifier:@"ycell"];
        _YGQTableView.delegate = self;
        _YGQTableView.dataSource = self;
        _YGQTableView.rowHeight = 120;
        _YGQTableView.estimatedRowHeight = 0;
        _YGQTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        _emptyYGQLabel = [[UILabel alloc]init];
        _emptyYGQLabel.hidden = YES;
        _emptyYGQLabel.frame = CGRectMake(_YGQTableView.frame.origin.x, 200, _usedTableView.frame.size.width, 40);
        _emptyYGQLabel.textAlignment = NSTextAlignmentCenter;
        _emptyYGQLabel.text = @"没有已过期的红包!";
        _emptyYGQLabel.textColor = [UIColor lightGrayColor];
        _emptyYGQLabel.font = [UIFont fontWithName:@"PingFang" size:13];
        [_YGQTableView addSubview:_emptyYGQLabel];
        [_YGQTableView bringSubviewToFront:_emptyYGQLabel];
        
        [view addSubview:_YGQTableView];
        [self.bigScrollerView addSubview:view];
    }
}

- (void)buttonAction:(UIButton *)button
{
    self.selectIndex = button.tag;
    //滑动刷新
    if (self.selectIndex == 1 ) {
        if ( dataSourceUsed.count == 0) {
            [self loadData:1];
        }else {
            [_usedTableView reloadData];
        }
        
    }else if (self.selectIndex == 2 ) {
        if ( dataSourceYGQ.count == 0) {
            [self loadData:2];
        }else {
            [_YGQTableView reloadData];
        }
        
    }else if (self.selectIndex == 0 ) {
        if ( dataSourceNOUse.count == 0) {
            [self loadData:0];
        }else {
            [_noUseTableView reloadData];
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
            if ( dataSourceUsed.count == 0) {
                [self loadData:1];
            }else {
                [_usedTableView reloadData];
            }
            
        }else if (self.selectIndex == 2 ) {
            if ( dataSourceYGQ.count == 0) {
                [self loadData:2];
            }else {
                [_YGQTableView reloadData];
            }
            
        }else if (self.selectIndex == 0 ) {
            if ( dataSourceNOUse.count == 0) {
                [self loadData:0];
            }else {
                [_noUseTableView reloadData];
            }
            
        }

    } else if (endContentOffsetX > willEndContentOffsetX && willEndContentOffsetX > startContentOffsetX) {//画面从左往右移动，后一页
        CGFloat x = scrollView.contentOffset.x;
        self.selectIndex = x / kWidth;
        [self changeLinePlaceWithIndex:self.selectIndex];
        [self changeButtonTextColor];
        
        
        //滑动刷新
        if (self.selectIndex == 1 ) {
            if ( dataSourceUsed.count == 0) {
                [self loadData:1];
            }else {
                [_usedTableView reloadData];
            }
            
        }else if (self.selectIndex == 2 ) {
            if ( dataSourceYGQ.count == 0) {
                [self loadData:2];
            }else {
                [_YGQTableView reloadData];
            }
            
        }else if (self.selectIndex == 0 ) {
            if ( dataSourceNOUse.count == 0) {
                [self loadData:0];
            }else {
                [_noUseTableView reloadData];
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
        return dataSourceNOUse.count;
    }else if (self.selectIndex == 1){
        return dataSourceUsed.count;
    }else{
        return dataSourceYGQ.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 0) {//未使用
        
        HBTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ncell" forIndexPath:indexPath];
        if (!cell) {
            cell = [[HBTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ncell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.money.text = [NSString stringWithFormat:@"%d", [dataSourceNOUse[indexPath.row][@"voucherValue"] intValue] / 100];
        NSString *begin = [FuncPublic getTime:dataSourceNOUse[indexPath.row][@"beginTime"]];
        NSString *end = [FuncPublic getTime:dataSourceNOUse[indexPath.row][@"expiredTime"]];
        cell.label4.text = [NSString stringWithFormat:@"%@至%@", [begin substringToIndex:10], [end substringToIndex:10]];
        cell.label1.text = dataSourceNOUse[indexPath.row][@"name"];
//        cell.label2.text = [NSString stringWithFormat:@"投资金额≥%d元", [dataSourceNOUse[indexPath.row][@"voucherCondition"] intValue] / 100];
//        cell.label3.text = [NSString stringWithFormat:@"%@天及以上标的使用", dataSourceNOUse[indexPath.row][@"restricta"]];
        cell.label2.text = dataSourceNOUse[indexPath.row][@"moneyCondition"];
        cell.label3.text= dataSourceNOUse[indexPath.row][@"dayCondition"];
        
        if ([_hborjxq isEqualToString:@"红包"]) {
            [self HBHideComponent:cell];
            cell.ygqIimageView.hidden = true;
        }else {
            cell.ygqIimageView.hidden = true;
            [self JXQHideComponent:cell];
        }
        return cell;

    }else  if (tableView.tag == 1){//已使用
        HBTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        if (!cell) {
            cell = [[HBTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.money.text = [NSString stringWithFormat:@"%d", [dataSourceUsed[indexPath.row][@"voucherValue"] intValue] / 100];
        NSString *begin = [FuncPublic getTime:dataSourceUsed[indexPath.row][@"beginTime"]];
        NSString *end = [FuncPublic getTime:dataSourceUsed[indexPath.row][@"expiredTime"]];
        cell.label4.text = [NSString stringWithFormat:@"%@至%@", [begin substringToIndex:10], [end substringToIndex:10]];
        cell.label1.text = dataSourceUsed[indexPath.row][@"name"];
//        cell.label2.text = [NSString stringWithFormat:@"投资金额≥%d元", [dataSourceUsed[indexPath.row][@"voucherCondition"] intValue] / 100];
//        cell.label3.text = [NSString stringWithFormat:@"%@天及以上标的使用", dataSourceUsed[indexPath.row][@"restricta"]];
        cell.label2.text = dataSourceUsed[indexPath.row][@"moneyCondition"];
        cell.label3.text= dataSourceUsed[indexPath.row][@"dayCondition"];
        if ([_hborjxq isEqualToString:@"红包"]) {
            [self HBHideComponent:cell];
            cell.ygqIimageView.hidden = true;
        }else {
            cell.ygqIimageView.hidden = true;
            [self JXQHideComponent:cell];
        }
        [self HBOverUse:cell];
        return cell;

    }else {//过期
        HBTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ycell" forIndexPath:indexPath];
        if (!cell) {
            cell = [[HBTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ycell"];
        }
       cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.money.text = [NSString stringWithFormat:@"%d", [dataSourceYGQ[indexPath.row][@"voucherValue"] intValue] / 100];
        NSString *begin = [FuncPublic getTime:dataSourceYGQ[indexPath.row][@"beginTime"]];
        NSString *end = [FuncPublic getTime:dataSourceYGQ[indexPath.row][@"expiredTime"]];
        cell.label4.text = [NSString stringWithFormat:@"%@至%@", [begin substringToIndex:10], [end substringToIndex:10]];
        cell.label1.text = dataSourceYGQ[indexPath.row][@"name"];
//        cell.label2.text = [NSString stringWithFormat:@"投资金额≥%d元", [dataSourceYGQ[indexPath.row][@"voucherCondition"] intValue] / 100];
//        cell.label3.text = [NSString stringWithFormat:@"%@天及以上标的使用", dataSourceYGQ[indexPath.row][@"restricta"]];
        cell.label2.text = dataSourceYGQ[indexPath.row][@"moneyCondition"];
        cell.label3.text= dataSourceYGQ[indexPath.row][@"dayCondition"];
        if ([_hborjxq isEqualToString:@"红包"]) {
            [self HBHideComponent:cell];
             [self HBYGQ:cell];
        }else {
            [self JXQHideComponent:cell];
        }
        [self HBYGQ:cell];
        return cell;
    }
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}
#pragma mark - cell method
- (void)HBHideComponent:(HBTableViewCell *)cell {
    //cell.ygqIimageView.hidden = YES;
    cell.persentLabel.hidden = YES;
}
- (void)JXQHideComponent:(HBTableViewCell *)cell {
   // cell.ygqIimageView.hidden = YES;
    cell.moneySign.hidden = YES;
}
- (void)HBYGQ:(HBTableViewCell *)cell {
    cell.backgroudimageview.image = [UIImage imageNamed:@"矩形11.png"];
    cell.ygqIimageView.hidden = false;
    cell.persentLabel.hidden = true;
    cell.moneySign.hidden = false;
    cell.moneySign.textColor = [UIColor grayColor];
    cell.money.textColor = [UIColor grayColor];
}
- (void)JXQYGQ:(HBTableViewCell *)cell {
    cell.backgroudimageview.image = [UIImage imageNamed:@"矩形11.png"];
    cell.ygqIimageView.hidden = false;
    cell.persentLabel.hidden = false;
    cell.moneySign.hidden = true;
    cell.persentLabel.textColor = [UIColor grayColor];
    cell.money.textColor = [UIColor grayColor];
}
- (void)HBNormal :(HBTableViewCell *)cell{
    cell.backgroudimageview.image = [UIImage imageNamed:@"矩形11.png"];
    cell.ygqIimageView.hidden = true;
    cell.moneySign.hidden = false;
    cell.persentLabel.hidden = true;
    cell.moneySign.textColor = [UIColor redColor];
    cell.money.textColor = [UIColor redColor];
}
- (void)JXQNormal:(HBTableViewCell *)cell {
    cell.backgroudimageview.image = [UIImage imageNamed:@"矩形11.png"];
    cell.ygqIimageView.hidden = true;
    cell.moneySign.hidden = true;
    cell.persentLabel.hidden = false;
    cell.persentLabel.textColor = [UIColor redColor];
    cell.money.textColor = [UIColor redColor];
}
- (void)HBOverUse:(HBTableViewCell *)cell {
    cell.backgroudimageview.image = [UIImage imageNamed:@"矩形11.png"];
    cell.ygqIimageView.hidden = YES;
    cell.moneySign.hidden = false;
    cell.persentLabel.hidden = true;
    //cell.persentLabel.textColor = [UIColor redColor];
    cell.money.textColor = [UIColor grayColor];
    cell.moneySign.textColor = [UIColor grayColor];
}
- (void)JXQOverUse:(HBTableViewCell *)cell {
    cell.backgroudimageview.image = [UIImage imageNamed:@"矩形11.png"];
    cell.ygqIimageView.hidden = YES;
    cell.persentLabel.hidden = false;
    cell.moneySign.hidden = true;
    cell.persentLabel.textColor = [UIColor grayColor];
    cell.money.textColor = [UIColor grayColor];
}

@end
