//
//  ChooseBackTableViewController.m
//  lzt
//
//  Created by hwq on 2017/11/24.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "ChooseBackTableViewController.h"
#import "NetManager.h"
@interface ChooseBackTableViewController ()
{
    NSArray *images;
    NSArray *imageNames;
    NSMutableArray *dataSource;
}

@end

@implementation ChooseBackTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"选择银行"];
    dataSource = [[NSMutableArray alloc]init];
    [self loadBank];
    imageNames = @[@"工商银行", @"农业银行", @"中国银行",@"建设银行",@"邮政储蓄银行",@"平安银行",@"民生银行",@"光大银行",@"广发银行", @"中信银行",@"兴业银行",@"华夏银行",@"招商银行",@"浦发银行",@"交通银行",@"北京银行",@"上海银行"];
    images = @[@"ICBC", @"ABC农业银行", @"Bank_Of_China",@"建设银行",@"中国邮政储蓄",@"平安银行",@"民生银行",@"光大银行",@"广发", @"China_Citic_Back",@"兴业银行",@"华夏银行",@"招商",@"浦发",@"Bank_Of_Communications",@"北京银行",@"上海银行(1)"];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) loadBank {
    //载入数据
    NSString *url =[NSString stringWithFormat:@"%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"user/bankcode/list"];
    url = [NSString stringWithFormat:@"%@?from=%@&version=%@", url, @"iOS", InnerVersion];
    [NetManager GetRequestWithUrlString:url finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        if ([result[@"resultCode"] boolValue]) {
            [self showHint:result[@"resultMsg"] yOffset:0];
        }else {
            dataSource = result[@"resultData"];
            [self.tableView reloadData];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" ];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.imageView.image = [UIImage imageNamed:dataSource[indexPath.row][@"bankName"]];
    cell.textLabel.text = dataSource[indexPath.row][@"bankName"];
    cell.textLabel.font = [UIFont fontWithName:@"PingFang SC" size:16];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.navigationController popViewControllerAnimated:true];
    [self.delegate ChooseBack:self didFinish:dataSource[indexPath.row][@"bankName"] andBackCode:dataSource[indexPath.row][@"bankCode"]];
}


@end
