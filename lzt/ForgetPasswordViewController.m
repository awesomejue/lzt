//
//  ForgetPasswordViewController.m
//  lzt
//
//  Created by hwq on 2017/11/17.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "ForgetPasswordViewController.h"
#import "UIButton+CornerRadium.h"
#import "RegisterViewController.h"
#import "NetManager.h"


#define FONT  [UIFont fontWithName:@"PingFang SC" size:16]
@interface ForgetPasswordViewController ()
@property (weak, nonatomic) IBOutlet UILabel *ljzcLabel;
@property (weak, nonatomic) IBOutlet UIButton *zhmmBtn;
@property (weak, nonatomic) IBOutlet UITextField *telephone;
@property (weak, nonatomic) IBOutlet UITextField *code;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *againPassword;
@property (weak, nonatomic) IBOutlet UILabel *hqyzmLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavHeight;

@end

@implementation ForgetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"忘记密码"];
    if (iPhoneX) {
        _NavHeight.constant += 20;
    }
   // [self apearNav];
    [self createUI];
    
}
- (void)createUI {
    [_zhmmBtn setCornerRadium];
    _hqyzmLabel.layer.borderWidth = 1;
    _hqyzmLabel.layer.borderColor = [UIColor redColor].CGColor;
    _hqyzmLabel.layer.cornerRadius = 5;
    _telephone.font = FONT;
    _code.font = FONT;
     _password.font = FONT;
     _againPassword.font = FONT;
}
- (IBAction)hidekeyboard:(id)sender {
    [_telephone resignFirstResponder];
    [_code resignFirstResponder];
    [_password resignFirstResponder];
    [_againPassword resignFirstResponder];
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}
- (void)viewWillAppear:(BOOL)animated {
   // self.navigationController.navigationBar.hidden = false;
   // [self.navigationController setNavigationBarHidden:false animated:YES];
}
//显示导航栏
- (void) apearNav{
     [self.navigationController setNavigationBarHidden:NO animated:YES];
    //self.navigationController.navigationBar.hidden = false;
}
- (void)addBottomLine {
   // UILabel *underlineLabel = [[UILabel alloc] initWithFrame:(CGRectMake(10, 10, 50, 30))];
    NSString *textStr = @"立即注册";
    // 下划线
    NSDictionary *attribtDic = @{NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
    NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:textStr attributes:attribtDic];
    //赋值
    _ljzcLabel.attributedText = attribtStr;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)fsyzm:(id)sender {
    
}
- (IBAction)ljzcTouched:(id)sender {
    [self hidekeyboard:sender];
    RegisterViewController *reg = [self.storyboard instantiateViewControllerWithIdentifier:@"RegisterViewController"];
    reg.forget = self;
    [self presentViewController:reg animated:true completion:nil];
}
- (IBAction)hqyzmTouched:(id)sender {
     [self hidekeyboard:sender];
    if(_telephone.text.length == 0) {
        [self showHint:@"手机号码不能为空！" yOffset:0];
        return;
    }else {
        NSString *url =[NSString stringWithFormat:@"%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"sms/findpwd"];
        NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
        // [param setValue:@"6381" forKey:@"code"];
        [param setValue:@"iOS" forKey:@"from"];
        [param setValue:_telephone.text forKey:@"phone"];
        //  [param setValue:_code.text forKey:@"code"];
        [param setValue:InnerVersion forKey:@"version"];
        
        //[self showHudInView:self.view hint:@"中"];
        [NetManager requestWithUrlString:url andDic:param finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //[self hideHud];
            NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
            if ([result[@"resultCode"] boolValue]) {
                [self showHint:result[@"resultMsg"] yOffset:0];
            }else {
                [self openCountdown];
                [self showHint:result[@"resultMsg"] yOffset:0];
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
            //[self hideHud];
        }];
        
        
    }
}
// 开启倒计时效果
-(void)openCountdown{
    
    __block NSInteger time = 59; //倒计时时间
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    
    dispatch_source_set_event_handler(_timer, ^{
        
        if(time <= 0){ //倒计时结束，关闭
            
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //设置按钮的样式
                [self.hqyzmLabel setText:@"重新发送"];
                //[self.yzmLabel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                self.hqyzmLabel.userInteractionEnabled = YES;
            });
            
        }else{
            
            int seconds = time % 60;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //设置按钮显示读秒效果
                [self.hqyzmLabel setText:[NSString stringWithFormat:@"%.2ds", seconds]];
                //[self.yzmLabel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                self.hqyzmLabel.userInteractionEnabled = NO;
            });
            time--;
        }
    });
    dispatch_resume(_timer);
}

- (IBAction)findPasswordClicked:(id)sender {
    [self hidekeyboard:nil];
    if(_telephone.text.length == 0) {
        [self showHint:@"手机号码不能为空！" yOffset:0];
        return;
    }
    if(_code.text.length == 0) {
        [self showHint:@"验证码不能为空！" yOffset:0];
        return;
    }
    if(_password.text.length == 0) {
        [self showHint:@"新的登陆密码不能为空！" yOffset:0];
        return;
    }
   
    
    if([FuncPublic isRightLoginPassword:_password.text]){
        if (_password.text.length < 6) {
            [self showHint:@"登陆密码长度大于6位" yOffset:0];
            return;
        }
        if (_password.text.length > 16) {
            [self showHint:@"登陆密码长度小于16位" yOffset:0];
            return;
        }
    }else{
        [self showHint:@"登陆密码只能为6～16位字母和数字组合" yOffset:0];
        return;
    }
    if(_againPassword.text.length == 0) {
        [self showHint:@"再次确认的登陆密码不能为空！" yOffset:0];
        return;
    }
    if([FuncPublic isRightLoginPassword:_againPassword.text]){
        if (_againPassword.text.length < 6) {
            [self showHint:@"再次确认密码长度大于6位" yOffset:0];
            return;
        }
        if (_againPassword.text.length > 16) {
            [self showHint:@"再次确认密码长度小于16位" yOffset:0];
            return;
        }
    }else{
        [self showHint:@"再次确认密码只能为6～16位字母和数字组合" yOffset:0];
        return;
    }
    if(![_againPassword.text isEqualToString:_password.text]) {
        [self showHint:@"两次输入的登陆密码不一致，请重新输入" yOffset:0];
        _againPassword.text = @"";
        return;
    }
        NSString *url =[NSString stringWithFormat:@"%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"user/findpwd"];
        NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
        // [param setValue:@"6381" forKey:@"code"];
        [param setValue:@"iOS" forKey:@"from"];
        [param setValue:_telephone.text forKey:@"phone"];
          [param setValue:_code.text forKey:@"code"];
        [param setValue:InnerVersion forKey:@"version"];
        [param setValue:_password.text forKey:@"pwd"];
    
        
        //[self showHudInView:self.view hint:@"中"];
        [NetManager requestWithUrlString:url andDic:param finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //[self hideHud];
            NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
            if ([result[@"resultCode"] boolValue]) {
                [self showHint:result[@"resultMsg"] yOffset:0];
            }else { //成功
                [self showHint:result[@"resultMsg"] yOffset:0];
                [self.navigationController popViewControllerAnimated:true];
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
            //[self hideHud];
        }];
        
        
    //}
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
