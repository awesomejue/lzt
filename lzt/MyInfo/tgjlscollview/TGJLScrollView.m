//
//  LXQScrollerView.m
//  memuDemo
//
//  Created by Jerry on 2017/7/5.
//  Copyright © 2017年 Jerry. All rights reserved.
//

#import "TGJLScrollView.h"
#import "CustomScrollView.h"
#import "AFNetworking.h"
#import "FuncPublic.h"
#import "Constants.h"
#import "WToast.h"
#import "UserData.h"
#import "UIScrollView+MyScrollView.h"
#import "MJRefresh.h"
#import "UIImageView+WebCache.h"
#import "TGJLCell.h"
#import "HBTableViewCell.h"
#define ApearFooterCount 4 //数据量大于8条则显示上拉加载

#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height

@interface TGJLScrollView ()<UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource  >
{
    //    NSMutableArray *newsTypeList;
    //    NSMutableArray *dataSource;
    NSMutableArray *dataSourceTGJL;
    NSMutableArray *dataSourceHB;
   
    int flagTGJL;
    int flagHB;
   
    int startContentOffsetX;
    int willEndContentOffsetX;
    int endContentOffsetX;
    
    int page;
    int limit;
    int tgjlsumCount;
    int hbsumCount;
}
@property (nonatomic, strong) UITableView *tgjlTableView;
@property (nonatomic, strong) UITableView *hbTableView;

@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, strong) UILabel *emptytgjlLabel;
@property (nonatomic, strong) UILabel *emptyhbLabel;

@property (nonatomic, strong) UIScrollView  *bigScrollerView;
@property (nonatomic, strong) UIView        *line;
@property (nonatomic, strong) UIView        *topView;
@property (nonatomic, assign) NSInteger     selectIndex;
@property (nonatomic, strong) NSArray       *titleArray;
@property (nonatomic, assign) NSInteger     count;
@property (nonatomic, assign) NSInteger     NavHeight;
@end

@implementation TGJLScrollView

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
        [self loadData:0]; //0:推广记录， 1:红包记录
        [self.con hideHud];
        // page = 0;
        // rows = 10;
        [self prepareTopUI];
        [self prepareScrollerViewUI];
        [self tableHeaderDidTriggerRefresh];
        dataSourceTGJL = [[NSMutableArray alloc]init];
        dataSourceHB = [[NSMutableArray alloc]init];
        page = 1;
        limit = 10;
        
        
    }
    
    return self;
}
- (void)loadData:(int)type {
    page = 1;
    limit = 10;
    NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
    NSString *url;
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    if (type == 0) { //推广记录
        url =[NSString stringWithFormat:@"%@%@/%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"user",userInfo[@"userId"],@"/recommend"];
        [param removeAllObjects];
        [param setValue:@"iOS" forKey:@"from"];
        [param setValue:InnerVersion forKey:@"version"];
        [param setValue:userInfo[@"token"] forKey:@"token"];
    
        [param setValue:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
        [param setValue:[NSString stringWithFormat:@"%d", limit] forKey:@"limit"];
        
    }else { //红包记录
        url =[NSString stringWithFormat:@"%@%@/%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"user",userInfo[@"userId"],@"/pocket/invite"];
        [param removeAllObjects];
        [param setValue:@"iOS" forKey:@"from"];
        [param setValue:InnerVersion forKey:@"version"];
        [param setValue:userInfo[@"token"] forKey:@"token"];
       
        [param setValue:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
        [param setValue:[NSString stringWithFormat:@"%d", limit] forKey:@"limit"];
        
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
                    [dataSourceTGJL removeAllObjects];//清空
                    [dataSourceTGJL addObjectsFromArray:array];
                    tgjlsumCount = [result[@"sumCount"] intValue];
                    page = 1;//记录第一次请求的页,重置为第一页
                    [self.tgjlTableView reloadData];
                    if (dataSourceTGJL.count > ApearFooterCount) {//指定数量的数据才显示上拉加载
                        self.tgjlTableView.mj_footer.hidden = false;
                    }
                    [self.tgjlTableView.mj_header endRefreshing];
                    [self tgjlcheckFooterState];//检查footer状态
                }else {
                    _emptytgjlLabel.hidden = NO;
                    [self.tgjlTableView.mj_header endRefreshing];
                }
                
            }else if(type == 1){//
                NSArray *array = result[@"resultData"];
                if (array.count > 0) {
                    [dataSourceHB removeAllObjects];//清空
                    [dataSourceHB addObjectsFromArray:array];
                    hbsumCount = [result[@"sumCount"] intValue];
                    page = 1;//记录第一次请求的页,重置为第一页
                    [self.hbTableView reloadData];
                    if (dataSourceHB.count > ApearFooterCount) {//指定数量的数据才显示上拉加载
                        self.hbTableView.mj_footer.hidden = false;
                    }
                    [self.hbTableView.mj_header endRefreshing];
                    [self hbcheckFooterState];//检查footer状态
                }else {
                    _emptyhbLabel.hidden = NO;
                    [self.hbTableView.mj_header endRefreshing];
                }
                
            }else {
                NSArray *array = result[@"resultData"];
                if (array.count > 0) {
                    [dataSourceHB removeAllObjects];//清空
                    [dataSourceHB addObjectsFromArray:array];
                    hbsumCount = [result[@"sumCount"] intValue];
                    page = 1;//记录第一次请求的页,重置为第一页
                    [self.hbTableView reloadData];
                    if (dataSourceHB.count > ApearFooterCount) {//指定数量的数据才显示上拉加载
                        self.hbTableView.mj_footer.hidden = false;
                    }
                    [self.hbTableView.mj_header endRefreshing];
                    [self hbcheckFooterState];//检查footer状态
                }else {
                    _emptyhbLabel.hidden = NO;
                    [self.hbTableView.mj_header endRefreshing];
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
            [self.tgjlTableView.mj_header endRefreshing];
        }else if(type == 1){
            [self.hbTableView.mj_header endRefreshing];
        }
        
    }];
    
}
- (void)loadMoreData:(int)type {
    page++;
    limit = 10;
    NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
    NSString *url;
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    if (type == 0) { //推广记录
        url =[NSString stringWithFormat:@"%@%@/%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"user",userInfo[@"userId"],@"/recommend"];
        [param removeAllObjects];
        [param setValue:@"iOS" forKey:@"from"];
        [param setValue:InnerVersion forKey:@"version"];
        [param setValue:userInfo[@"token"] forKey:@"token"];
        
        [param setValue:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
        [param setValue:[NSString stringWithFormat:@"%d", limit] forKey:@"limit"];
        
    }else { //红包记录
        url =[NSString stringWithFormat:@"%@%@/%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"user",userInfo[@"userId"],@"/pocket/invite"];
        [param removeAllObjects];
        [param setValue:@"iOS" forKey:@"from"];
        [param setValue:InnerVersion forKey:@"version"];
        [param setValue:userInfo[@"token"] forKey:@"token"];
        
        [param setValue:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
        [param setValue:[NSString stringWithFormat:@"%d", limit] forKey:@"limit"];
        
    }
    
    
    
    [NetManager GetRequestWithUrlString:url andDic:param finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //  [self.con showHudInView:self hint:@"加载中"];
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        if ([result[@"resultCode"] boolValue]) {
            [self.con showHint:result[@"resultMsg"] yOffset:0];
        }else {
            if (type == 0) { //
                NSArray *array = result[@"resultData"];
                [dataSourceTGJL addObjectsFromArray:array];
                [self.tgjlTableView reloadData];
                [self tgjlcheckFooterState];
            }else if(type == 1){
                NSArray *array = result[@"resultData"];
                
                [dataSourceHB addObjectsFromArray:array];
                
                [self.hbTableView reloadData];
                
                [self hbcheckFooterState];//检查footer状态
                
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
            [self.tgjlTableView.mj_header endRefreshing];
        }else if(type == 1){
            [self.hbTableView.mj_header endRefreshing];
        }
    }];
    
}
-(void) tgjlcheckFooterState {
    if(dataSourceTGJL.count == tgjlsumCount ){
        [self.tgjlTableView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.tgjlTableView.mj_footer endRefreshing];
    }
}
-(void) hbcheckFooterState {
    if(dataSourceHB.count == hbsumCount ){
        [self.hbTableView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.hbTableView.mj_footer endRefreshing];
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
        }
    }
    
}
//下拉刷新
- (void)tableHeaderDidTriggerRefresh {
#ifdef __IPHONE_11_0
    if ([_tgjlTableView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
        if (@available(iOS 11.0, *)) {
            _tgjlTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
        }
    }
#endif
    _tgjlTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadData:0];
    }];
    _tgjlTableView.mj_footer  = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self loadMoreData:0];
    }];
    _tgjlTableView.mj_footer.hidden = YES;//默认隐藏
#ifdef __IPHONE_11_0
    if ([_hbTableView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
        if (@available(iOS 11.0, *)) {
            _hbTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
        }
    }
#endif
    _hbTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadData:1];
    }];
    _hbTableView.mj_footer  = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self loadMoreData:1];
    }];
    _hbTableView.mj_footer.hidden = YES;//默认隐藏

}
- (void)initSecondView: (int)i {
    if (i == 0) {
        
        _tgjlTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, kWidth,kHeight - 60-_NavHeight) style:UITableViewStylePlain];
        _tgjlTableView.backgroundColor = [UIColor colorWithRed:242.0 / 255 green:242.0 / 255 blue:242.0 / 255 alpha:1];
        _tgjlTableView.tag = 0;
        //注册
        [_tgjlTableView registerNib:[UINib nibWithNibName:@"TGJLCell" bundle:nil]  forCellReuseIdentifier:@"tgjlcell"];
        _tgjlTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tgjlTableView.delegate = self;
        _tgjlTableView.dataSource = self;
        _tgjlTableView.rowHeight = 120;
        _tgjlTableView.estimatedRowHeight = 0;
        
        _emptytgjlLabel = [[UILabel alloc]init];
        _emptytgjlLabel.frame = CGRectMake(_tgjlTableView.frame.origin.x, 200, _tgjlTableView.frame.size.width, 40);
        _emptytgjlLabel.hidden = YES;
        _emptytgjlLabel.textAlignment = NSTextAlignmentCenter;
        _emptytgjlLabel.text = @"没有推广记录!";
        _emptytgjlLabel.textColor = [UIColor lightGrayColor];
        _emptytgjlLabel.font = [UIFont fontWithName:@"PingFang" size:13];
        [_tgjlTableView addSubview:_emptytgjlLabel];
        [_tgjlTableView bringSubviewToFront:_emptytgjlLabel];
        
        // [view addSubview:_usedTableView];
        [self.bigScrollerView addSubview:_tgjlTableView];
        
    }else if(i == 1){
        
        //TZGGTableViewController *tzgg = [[TZGGTableViewController alloc]init];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(kWidth * i, 0, kWidth, kHeight-48-_NavHeight)];
        _hbTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width,view.frame.size.height-10) style:UITableViewStylePlain];
        _hbTableView.backgroundColor = [UIColor colorWithRed:242.0 / 255 green:242.0 / 255 blue:242.0 / 255 alpha:1];
        _hbTableView.tag = 1;
        //注册
        [_hbTableView registerNib:[UINib nibWithNibName:@"HBTableViewCell" bundle:nil]  forCellReuseIdentifier:@"ncell"];
        _hbTableView.delegate = self;
        _hbTableView.dataSource = self;
        _hbTableView.rowHeight = 120;
        _hbTableView.estimatedRowHeight = 0;
        _hbTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        //_emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,view.frame.size.width, 40)];
        
        _emptyhbLabel = [[UILabel alloc]init];
        _emptyhbLabel.hidden = YES;
        _emptyhbLabel.frame = CGRectMake(_hbTableView.frame.origin.x, 200, _hbTableView.frame.size.width, 40);
        _emptyhbLabel.textAlignment = NSTextAlignmentCenter;
        _emptyhbLabel.text = @"没有红包记录!";
        _emptyhbLabel.textColor = [UIColor lightGrayColor];
        _emptyhbLabel.font = [UIFont fontWithName:@"PingFang" size:13];
        [_hbTableView addSubview:_emptyhbLabel];
        [_hbTableView bringSubviewToFront:_emptyhbLabel];
        
        [view addSubview:_hbTableView];
        [self.bigScrollerView addSubview:view];
    }
}

- (void)buttonAction:(UIButton *)button
{
    self.selectIndex = button.tag;
    //滑动刷新
    if (self.selectIndex == 1 ) {
        if ( dataSourceHB.count == 0) {
            [self loadData:1];
        }else {
            [_hbTableView reloadData];
        }
        
    }else if (self.selectIndex == 0 ) {
        if ( dataSourceTGJL.count == 0) {
            [self loadData:0];
        }else {
            [_tgjlTableView reloadData];
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
            if ( dataSourceHB.count == 0) {
                [self loadData:1];
            }else {
                [_hbTableView reloadData];
            }
            
        }else if (self.selectIndex == 0 ) {
            if ( dataSourceTGJL.count == 0) {
                [self loadData:0];
            }else {
                [_tgjlTableView reloadData];
            }
            
        }
        
    } else if (endContentOffsetX > willEndContentOffsetX && willEndContentOffsetX > startContentOffsetX) {//画面从左往右移动，后一页
        CGFloat x = scrollView.contentOffset.x;
        self.selectIndex = x / kWidth;
        [self changeLinePlaceWithIndex:self.selectIndex];
        [self changeButtonTextColor];
        
        
        //滑动刷新
        if (self.selectIndex == 1 ) {
            if ( dataSourceHB.count == 0) {
                [self loadData:1];
            }else {
                [_hbTableView reloadData];
            }
            
        }else if (self.selectIndex == 0 ) {
            if ( dataSourceTGJL.count == 0) {
                [self loadData:0];
            }else {
                [_tgjlTableView reloadData];
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
        return dataSourceTGJL.count;
    }else {
        return dataSourceHB.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 1) {//
        
        HBTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ncell" forIndexPath:indexPath];
        if (!cell) {
            cell = [[HBTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ncell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.money.text = [NSString stringWithFormat:@"%.1f", [dataSourceHB[indexPath.row][@"voucherValue"] doubleValue] / 100];
        NSString *begin = [FuncPublic getTime:dataSourceHB[indexPath.row][@"beginTime"]];
        NSString *end = [FuncPublic getTime:dataSourceHB[indexPath.row][@"expiredTime"]];
        cell.label4.text = [NSString stringWithFormat:@"%@至%@", [begin substringToIndex:10], [end substringToIndex:10]];
        cell.label1.text = dataSourceHB[indexPath.row][@"name"];
        //        cell.label2.text = [NSString stringWithFormat:@"投资金额≥%d元", [dataSourceHB[indexPath.row][@"voucherCondition"] intValue] / 100];
        //        cell.label3.text = [NSString stringWithFormat:@"%@天及以上标的使用", dataSourceHB[indexPath.row][@"restricta"]];
        cell.label2.text = dataSourceHB[indexPath.row][@"moneyCondition"];
        cell.label3.text= dataSourceHB[indexPath.row][@"dayCondition"];
        int type = [dataSourceHB[indexPath.row][@"status"] intValue];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        switch (type) {
            case 0: //未使用
                [self HBHideComponent:cell];
                cell.ygqIimageView.hidden = true;
                [self HBNormal:cell];
                break;
            case 1: //已过期
                [self HBHideComponent:cell];
                cell.ygqIimageView.hidden = false;
                [self HBYGQ:cell];
                
                break;
            case 2: //已使用
                [self HBHideComponent:cell];
                cell.ygqIimageView.hidden = true;
                [self HBOverUse:cell];
                break;
            default:
                break;
        }
       
        return cell;
        
    }else  {
        TGJLCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tgjlcell"];
        if (!cell) {
            cell = [[TGJLCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tgjlcell"];
        }
        int verified = [dataSourceTGJL[indexPath.row][@"verified"] intValue];
        if (verified == 1){
            cell.isIden.text = @"已认证";
            cell.isIden.textColor = [UIColor redColor];
        }else {
            cell.isIden.text = @"未认证";
            cell.isIden.textColor = [UIColor darkGrayColor];
        }
        cell.time.text = [NSString stringWithFormat:@"注册时间：%@", [FuncPublic getTime:dataSourceTGJL[indexPath.row][@"createdTime"]]];
        cell.username.text = dataSourceTGJL[indexPath.row][@"phone"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
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


