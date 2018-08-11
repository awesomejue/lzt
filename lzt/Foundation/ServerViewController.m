//
//  ServerViewController.m
//  lzt
//
//  Created by hwq on 2017/12/25.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "ServerViewController.h"

@interface ServerViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIAlertController *alert;

@property (nonatomic, strong)NSArray *servers;

@end

@implementation ServerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _servers = @[@{@"rootserver":@"https://www.futoulc.com/api/", @"root":@"https://www.futoulc.com/"},
               @{@"rootserver":@"http://192.168.1.16:8086/", @"root":@"http://192.168.1.16:8086/"}];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}




#pragma mark - uitableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _servers.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = _servers[indexPath.row][@"rootserver"];
    return cell;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    _alert = [UIAlertController alertControllerWithTitle:@"服务器" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [_alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = weakSelf.servers[indexPath.row][@"rootserver"];
        // 可以在这里对textfield进行定制，例如改变背景色
        //textField.backgroundColor = [UIColor orangeColor];
    }];
   // [_alert.textFields[0] setText: [FuncPublic SharedFuncPublic].rootserver];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [FuncPublic SharedFuncPublic].rootserver = _alert.textFields[0].text;
        [self showHint:@"设置完成" yOffset:-Screen_Height / 3];
        [self.navigationController popViewControllerAnimated:true];
        //NSString *s = [FuncPublic SharedFuncPublic].rootserver;
       // NSLog(@" == %@", s);
    }];
     UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
//    [_alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
//       // textField.placeholder = @"请输入验证码";
//       // textField.keyboardType = UIKeyboardTypeNumberPad;
//    }];
    [_alert addAction:action1];
    [_alert addAction:action2];
    [self presentViewController:_alert animated:true completion:nil];

}


@end
