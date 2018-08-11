//
//  XQViewController.m
//  lzt
//
//  Created by hwq on 2017/12/6.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "XQViewController.h"
#import "XQTableViewCell.h"
@interface XQViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    
        NSArray *names;
    
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavHeight;

@end

@implementation XQViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (iPhoneX) {
        _NavHeight.constant += 20;
    }
    [self createTableView];
   // names = @[@"借\n款\n人\n信\n息",@"产\n品\n说\n明", @"借\n款\n详\n情", @"还\n款\n措\n施", @"风\n控\n措\n施"];
    names = @[@"借\n款\n人\n信\n息", @"借\n款\n详\n情", @"还\n款\n措\n施", @"风\n控\n措\n施"];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)createTableView {
    [self.tableView registerNib:[UINib nibWithNibName:@"XQTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    //自适应高度
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return names.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XQTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.name.text = names[indexPath.row];
    cell.name.numberOfLines = [cell.name.text length];
    int row = (int)indexPath.row;
    NSAttributedString * attrStr;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (row == 0) {
        attrStr = [[NSAttributedString alloc] initWithData:[_dataSource[@"userInfo"] dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        
        cell.content.attributedText = attrStr;
//    }else if(row == 1){
//        attrStr = [[NSAttributedString alloc] initWithData:[_dataSource[@"description"] dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
//
//        cell.content.attributedText = attrStr;
    }else if(row == 1){
        attrStr = [[NSAttributedString alloc] initWithData:[_dataSource[@"used"] dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        
        cell.content.attributedText = attrStr;
    }else if(row == 2){
        attrStr = [[NSAttributedString alloc] initWithData:[_dataSource[@"repayInfo"] dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        
        cell.content.attributedText = attrStr;
    }else if(row == 3){
        attrStr = [[NSAttributedString alloc] initWithData:[_dataSource[@"risk"] dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        
        cell.content.attributedText = attrStr;
    }
    //    switch (row) {
    //        case 0:
    //            cell.content.text = _dataSource[@"userInfo"];
    //            break;
    //        case 1:
    //            NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:__dataSource[@"description"] dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    //            cell.content.attributedText = attrStr;
    //            break;
    //        case 2:
    //            cell.content.text = _dataSource[@"used"];
    //            break;
    //        case 3:
    //            cell.content.text = _dataSource[@"repayInfo"];
    //            break;
    //        case 4:
    //            cell.content.text = _dataSource[@"risk"];
    //            break;
    //
    //        default:
    //            break;
    //    }
    
    
    return cell;
}

@end
