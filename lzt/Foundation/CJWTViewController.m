//
//  CJWTViewController.m
//  lzt
//
//  Created by hwq on 2017/12/2.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "CJWTViewController.h"
#import "QuestionTableViewCell.h"
@interface CJWTViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    int page;
    int row;
    BOOL status[6];//记录一级菜单状态 默认no闭合
    NSMutableArray *firstName;//一级菜单名
    NSMutableArray *secondName;//二级菜单
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavHeight;

@end

@implementation CJWTViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self hideBackButtonText];
    [self createTableView];
    if (iPhoneX) {
        _NavHeight.constant += 20;
    }
    page = 1;
    row = 20;
    firstName = [[NSMutableArray alloc]init];
    secondName = [[NSMutableArray alloc]init];
    [self loadData:page andRow:row];
    [self tableHeaderDidTriggerRefresh];
    //这里菜单可以根据自己需要设定或从后台载入数据
  //  firstName = [[NSMutableArray alloc]initWithObjects:@"关于注册与登陆",@"关于存管银行开户",@"关于充值与提现 ",@"关于红包",@"关于投资",@"关于回款", nil];
    
   // secondName = [[NSMutableArray alloc]initWithObjects:@"question1.png",@"question2.png",@"question3.png",@"question4.png",@"question5.png",@"question6.png",nil];
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (void)hideBackButtonText{
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:nil];
}
- (void)loadData:(int )page andRow:(int )rows {
    NSString *url =[NSString stringWithFormat:@"%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"help/list?"];
    url = [NSString stringWithFormat:@"%@page=%d&limit=%d&from=%@&version=%@", url, page,rows,@"iOS", InnerVersion];
    [NetManager GetRequestWithUrlString:url finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        if ([result[@"resultCode"] boolValue]) {
            [self showHint:result[@"resultMsg"] yOffset:0];
        }else {
            NSArray *array = result[@"resultData"];
            if (array.count > 0) {
                for(NSDictionary *d in array){
                    [firstName addObject:d[@"title"]];
                    [secondName addObject:d[@"content"]];
                }
                [self.tableView reloadData];
            }else {
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 40)];
                UILabel *label = [[UILabel alloc]init];
                label.frame = CGRectMake(0, Screen_Height/6, Screen_Width, 40);
                label.textAlignment = NSTextAlignmentCenter;
                label.text = @"没有更多了!";
                label.textColor = [UIColor lightGrayColor];
                label.font = [UIFont fontWithName:@"PingFang" size:13];
                
                [view addSubview:label];
                [self.tableView addSubview:view];
                [self.tableView bringSubviewToFront:view];
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
    }];
}
- (void)createTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"QuestionTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 200;
    //
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1];
    // self.tableView  = UITableViewStyleGrouped;
}
//下拉刷新
- (void)tableHeaderDidTriggerRefresh {
    
#ifdef __IPHONE_11_0
    if ([self.tableView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
        if (@available(iOS 11.0, *)) {
            self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
        }
    }else {
        self.automaticallyAdjustsScrollViewInsets = false;
    }
#endif
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [self.tableView.mj_header endRefreshing];
    }];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //节数即为一级菜单个数
    return firstName.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //现实项目中可以根据每节设定单元数
    BOOL closeOrOpen = status[section] ;
    //关闭显示为0行
    if (closeOrOpen == NO) {
        return 0;
    }else {
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QuestionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" ];
    if (!cell) {
        cell = [[QuestionTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.content.text = secondName[indexPath.section];
  //  cell.content.text = @"sdfjskajfksajkfjksadjfkasjkdfjsakjfkasjdkfjaskdfjksajkdfjaksdjfksjdkfjsdkfjskdjfksdjfk";
   // cell.questionImageView.image = [UIImage imageNamed:secondName[indexPath.section]];
    return cell;
}

//自定义节
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor colorWithRed:239.0/255 green:239.0/255 blue:239.0/255 alpha:1];
    UIControl *sectionView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 49)];
    sectionView.tag = section;
    sectionView.backgroundColor = [UIColor whiteColor];
    [sectionView addTarget:self action:@selector(sectionAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:sectionView];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, 100, 30)];
    title.backgroundColor = [UIColor clearColor];
    title.textColor = [UIColor blackColor];
    title.font = [UIFont fontWithName:@"PingFang SC" size:16];
    title.text = [NSString stringWithFormat:@"%@", firstName[section]];
    [title sizeToFit];
    [sectionView addSubview:title];
    
    UIImageView *ImageView = [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width * 0.9 , 15, 10, 15)];
    // firstImageView.backgroundColor = [UIColor redColor];
    if (!status[section]) {
        ImageView.image = [UIImage imageNamed:@"向右拷贝2.png"];
        ImageView.frame = CGRectMake(ImageView.frame.origin.x, ImageView.frame.origin.y, 10, 15);
    }else {
        ImageView.image = [UIImage imageNamed:@"向上.png"];
        ImageView.frame = CGRectMake(ImageView.frame.origin.x, ImageView.frame.origin.y, 15, 10);
    }
    
    [sectionView addSubview:ImageView];
    
    return view;
    
}
//
- (void)sectionAction:(UIControl *)control {
    
    NSInteger section = control.tag;
    if (!status[section]){
        status[section] = true;
        
    }else {
        status[section] = false;
    }
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:section];
    //刷新指定单元格
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    
    
}
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return Screen_Height * 0.4;
//}
//section的header view的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 50;
}



@end
