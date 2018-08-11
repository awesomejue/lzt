//
//  ProjectHBTableViewController.m
//  lzt
//
//  Created by hwq on 2017/11/29.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "ProjectHBTableViewController.h"
#import "HBTableViewCell.h"

@interface ProjectHBTableViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *dataSource;
    int page;
    int row;
    
    UIView *emptyView;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavHeight;
@property (weak, nonatomic) IBOutlet UILabel *headTitle;

@end

@implementation ProjectHBTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (iPhoneX) {
        _NavHeight.constant += 20;
    }
    page = 1;
    row = 15;
    self.headTitle.text = _hborjxq;
    dataSource = [[NSMutableArray alloc]init];
    [self createTableView];
    [self loadData:page andRows:row];
    [self tableHeaderDidTriggerRefresh];
    
}

- (void)loadData: (int)pages andRows:(int)row {
    NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
    NSString *url =[NSString stringWithFormat:@"%@%@/%@%@/%d", [FuncPublic SharedFuncPublic].rootserver ,@"user",userInfo[@"userId"],@"/account/canusevouchers", _cycle];
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setValue:@"iOS" forKey:@"from"];
    [param setValue:InnerVersion forKey:@"version"];
    [param setValue:userInfo[@"token"] forKey:@"token"];
    [param setValue:[NSString stringWithFormat:@"%d", _type] forKey:@"type"];
    [param setValue:[NSString stringWithFormat:@"%d", (int)_amount * 100] forKey:@"amount"];
    // [param setValue:[NSString stringWithFormat:@"%d", _cycle] forKey:@"cycle"];
    [param setValue:[NSString stringWithFormat:@"%d", pages] forKey:@"page"];
    [param setValue:[NSString stringWithFormat:@"%d", row] forKey:@"limit"];
    
    [NetManager GetRequestWithUrlString:url andDic:param finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
      //  [self showHudInView:self.view hint:@"加载中"];
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        if ([result[@"resultCode"] boolValue]) {
            [self showHint:result[@"resultMsg"] yOffset:0];
        }else {
                dataSource = result[@"resultData"];
                if (dataSource.count > 0) {
                    [self.tableView reloadData];
                }else {
                    emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 40)];
                    
                    UILabel *label = [[UILabel alloc]init];
                    label.frame = CGRectMake(0, Screen_Height/6, Screen_Width, 40);
                    label.textAlignment = NSTextAlignmentCenter;
                    if([_hborjxq isEqualToString:@"红包"]){
                         label.text = @"没有可用红包!";
                    }else {
                         label.text = @"没有可用加息券!";
                    }
                   
                    label.textColor = [UIColor lightGrayColor];
                    label.font = [UIFont fontWithName:@"PingFang" size:13];

                    [emptyView addSubview:label];
                    [self.tableView addSubview:emptyView];
                    [self.tableView bringSubviewToFront:emptyView];
                }
                
            }
        [self hideHud];
    } failed:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        if(error.code == -1009){
            [self showHint:@"网络连接失败，请检查网络状态。" yOffset:0];
        }else if(error.code == -1004){
            [self showHint:@"服务器开了个小差。" yOffset:0];
        }else if(error.code == -1001){
            [self showHint:@"请求超时，请检查网络状态。" yOffset:0];
        }
        [self hideHud];
    }];
    
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}
- (void)viewWillAppear:(BOOL)animated {
    // [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)createTableView {
    [self.tableView registerNib:[UINib nibWithNibName:@"HBTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithRed:242.0 / 255 green:242.0 / 255 blue:242.0 / 255 alpha:1];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 120;
    self.tableView.estimatedRowHeight = 100;
}
- (void)tableHeaderDidTriggerRefresh {
//#ifdef __IPHONE_11_0
    if ([self.tableView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
        if (@available(iOS 11.0, *)) {
            self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
        }
    }else {
        _tableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
    }
//#endif
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        row += 10;
        [self loadData:page andRows:row ];
        [self.tableView.mj_header endRefreshing];
    }];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HBTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[HBTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ncell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([_hborjxq isEqualToString:@"红包"]) {
        cell.money.text = [NSString stringWithFormat:@"%d", [dataSource[indexPath.row][@"voucherValue"] intValue] / 100];
    }else{
     //   double test = [dataSource[indexPath.row][@"voucherValue"] doubleValue] / 100;
        cell.money.text = [NSString stringWithFormat:@"%.1f", [dataSource[indexPath.row][@"voucherValue"] doubleValue] / 10];
    }
    
    NSString *begin = [FuncPublic getTime:dataSource[indexPath.row][@"beginTime"]];
    NSString *end = [FuncPublic getTime:dataSource[indexPath.row][@"expiredTime"]];
    cell.label4.text = [NSString stringWithFormat:@"%@至%@", [begin substringToIndex:10], [end substringToIndex:10]];
    cell.label1.text = dataSource[indexPath.row][@"name"];
//    cell.label2.text = [NSString stringWithFormat:@"投资金额≥%d元", [dataSource[indexPath.row][@"voucherCondition"] intValue] / 100];
//    cell.label3.text = [NSString stringWithFormat:@"%d天及以上标的使用", [dataSource[indexPath.row][@"restricta"] intValue] ];
    cell.label2.text = dataSource[indexPath.row][@"moneyCondition"];
    cell.label3.text= dataSource[indexPath.row][@"dayCondition"];
    
    if ([_hborjxq isEqualToString:@"红包"]) {
        [self HBHideComponent:cell];
        cell.ygqIimageView.hidden = YES;
    }else {
        [self JXQHideComponent:cell];
        cell.ygqIimageView.hidden = YES;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *pocket;
    if ([_hborjxq isEqualToString:@"红包"]) {
        pocket = [NSString stringWithFormat:@"%d", [dataSource[indexPath.row][@"voucherValue"] intValue] / 100];
    }else{
        pocket = [NSString stringWithFormat:@"%d", [dataSource[indexPath.row][@"voucherValue"] intValue]];
    }
    
    
    [self.delegate ChooseBack:self didFinish:pocket andPocketI:dataSource[indexPath.row][@"id"]];
    [self.navigationController popViewControllerAnimated:true];
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

@end
