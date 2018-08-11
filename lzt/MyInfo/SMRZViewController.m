//
//  SMRZViewController.m
//  lzt
//
//  Created by hwq on 2017/11/17.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "SMRZViewController.h"
#import "UIViewController+HUD.h"
#import "choosebankViewController.h"
#import "ChooseBackTableViewController.h"
#import "AddressPickerView.h"
#import "SZJYMMViewController.h"

#define SCREEN [UIScreen mainScreen].bounds.size

@interface SMRZViewController ()<UITextFieldDelegate, ChooseBackDelegate, AddressPickerViewDelegate>
{
    BOOL flag;//所在地区
}
@property (weak, nonatomic) IBOutlet UILabel *fsdxyzmLabel;
@property (weak, nonatomic) IBOutlet UIButton *qdBtn;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *identity;
@property (weak, nonatomic) IBOutlet UITextField *code;
@property (weak, nonatomic) IBOutlet UITextField *backCard;
@property (weak, nonatomic) IBOutlet UITextField *backLocation;
@property (weak, nonatomic) IBOutlet UILabel *backName;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UIButton *addressbtn;
@property (weak, nonatomic) IBOutlet UILabel *szdqLabel;
@property (weak, nonatomic) IBOutlet UITextField *khzhName;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavHeight;

@property (nonatomic ,strong) AddressPickerView * pickerView;//地区选择器
@property (nonatomic, assign) NSString *provice; //省
@property (nonatomic, assign) NSString *city;//市
@property (nonatomic, assign) NSString *area; //县区
@property (nonatomic, strong) NSString *bankCode;
@end

@implementation SMRZViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    flag = 1;
    if (iPhoneX) {
        _NavHeight.constant += 20;
    }
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    [self setTitle:@"实名认证/绑定银行卡"];
    [self createUI];
    //[self apearNav];
    //[self hideBackButtonText];
}


//显示导航栏
- (void) apearNav{
    self.navigationController.navigationBar.hidden = false;
}

- (IBAction)chooseBackTouched:(id)sender {
    [self hidekeyboard:nil];
    choosebankViewController *chooseBack = [self.storyboard instantiateViewControllerWithIdentifier:@"choosebankViewController"];
    chooseBack.delegate = self;
    [self.navigationController pushViewController:chooseBack animated:true];
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}
- (void)createUI {
    
    [self.view addSubview:self.pickerView];
    [self.view bringSubviewToFront:self.pickerView];
    _name.delegate = self;
    _identity.delegate = self;
    //_code.delegate = self;
    _backCard.delegate = self;
    // _khzhName.delegate = self;
    
    self.qdBtn.layer.cornerRadius = 5;
    //    self.fsdxyzmLabel.layer.borderColor = [UIColor redColor].CGColor;
    //    self.fsdxyzmLabel.layer.borderWidth = 0.5;
    //    self.fsdxyzmLabel.layer.cornerRadius = 5;
}- (IBAction)hidekeyboard:(id)sender {
    [_name resignFirstResponder];
    [_code resignFirstResponder];
    [_khzhName resignFirstResponder];
    [_backCard resignFirstResponder];
    [_identity resignFirstResponder];
}

- (IBAction)szdqTouched:(id)sender {
    [self hidekeyboard:nil];
    flag = !flag;
    //btn.selected = !btn.selected;
    if (flag) {
        [self.pickerView show];
    }else{
        [self.pickerView hide];
    }
}

//- (IBAction)yzm:(id)sender {
//    NSString *url =[NSString stringWithFormat:@"%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"sms/register"];
//    NSDictionary *userinfo = [FuncPublic GetDefaultInfo:mUserInfo];
//        NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
//        // [param setValue:@"6381" forKey:@"code"];
//        [param setValue:@"iOS" forKey:@"from"];
//        [param setValue:userinfo[@"telephone"] forKey:@"phone"];
//        //  [param setValue:_code.text forKey:@"code"];
//        [param setValue:InnerVersion forKey:@"version"];
//
//        //[self showHudInView:self.view hint:@"中"];
//        [NetManager requestWithUrlString:url andDic:param finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            //[self hideHud];
//            NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
//            if ([result[@"resultCode"] boolValue]) {
//                [self showHint:result[@"resultMsg"] yOffset:0];
//            }else {
//                [self showHint:result[@"resultMsg"] yOffset:0];
//            }
//
//        } failed:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//            NSLog(@"%@", error);
//            if(error.code == -1009){
//                [self showHint:@"网络连接失败，请检查网络状态。" yOffset:0];
//            }else if(error.code == -1004){
//                [self showHint:@"服务器开了个小差。" yOffset:0];
//            }else if(error.code == -1001){
//                [self showHint:@"请求超时，请检查网络状态。" yOffset:0];
//            }
//            //[self hideHud];
//        }];
//
//
//}
- (IBAction)btnClicked:(UIButton *)btn {
    [self hidekeyboard:nil];
    btn.selected = !btn.selected;
    if (btn.selected) {
        [self.pickerView show];
    }else{
        [self.pickerView hide];
    }
}
- (IBAction)okClicked:(id)sender {
    if(_name.text.length == 0) {
        [self showHint:@"姓名不能为空！" yOffset:0];
        return;
    }else if(_identity.text.length == 0){
        [self showHint:@"身份证号码不能为空！" yOffset:0];
        return;
    }else if(_backCard.text.length == 0){
        [self showHint:@"银行卡号不能为空！" yOffset:0];
        return;
    }else if([_backName.text isEqualToString:@"选择银行"]){
        [self showHint:@"请选择银行！" yOffset:0];
        return;
    }else if(_szdqLabel.text.length == 0){
        [self showHint:@"请选择所在地区！" yOffset:0];
        return;
    }else {
        NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
        NSString *url =[NSString stringWithFormat:@"%@%@%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"user/",userInfo[@"userId"],@"/account/card/binding"];
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
        [param setValue:@"iOS" forKey:@"from"];
        [param setValue:InnerVersion forKey:@"version"];
        [param setValue:userInfo[@"token"] forKey:@"token"];
        [param setValue:_name.text forKey:@"realName"];
        [param setValue:_identity.text forKey:@"idCard"];
        [param setValue:_provice forKey:@"province"];
        [param setValue:_city forKey:@"city"];
        [param setValue:_area forKey:@"district"];
        //  [param setValue:_khzhName.text forKey:@"subbranch"];
        [param setValue:@"" forKey:@"subbranch"];
        [param setValue:_backCard.text forKey:@"cardNumber"];
        [param setValue:[NSString stringWithFormat:@"%@", _bankCode] forKey:@"bankCode"];
        [self showHudInView:self.view hint:@"绑定中"];
        [NetManager requestWithUrlString:url andDic:param finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self hideHud];
            NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
            if ([result[@"resultCode"] boolValue]) {
                [self showHint:result[@"resultMsg"] yOffset:0];
            }else {
                
                NSMutableDictionary *user = [[NSMutableDictionary alloc]init];
                NSDictionary *u = [FuncPublic GetDefaultInfo:mUserInfo];
                [user setDictionary:u];
                [user setValue:[NSString stringWithFormat:@"%d", 1] forKey:@"hasCardId"];
                [user setValue:[NSString stringWithFormat:@"%d", 0]  forKey:@"hasTradePassword"];
                [FuncPublic SaveDefaultInfo:user Key:mUserInfo];
                //[self showHint:@"绑定成功"];
                //  [self.navigationController popViewControllerAnimated:true];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"实名认证成功，去设置交易密码" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    UIStoryboard *s = [UIStoryboard storyboardWithName:@"MMGL" bundle:nil];
                    SZJYMMViewController *sz = [s instantiateViewControllerWithIdentifier:@"SZJYMMViewController"];
                    sz.name = @"交易密码设置";
                    //  if (_isRegister) {
                    sz.isSMRZ = true;
                    //  }
                    [self.navigationController pushViewController:sz animated:true];
                }];
                [ok setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"先逛逛" style:UIAlertActionStyleDefault handler:nil];
                [cancel setValue:[UIColor lightGrayColor] forKey:@"_titleTextColor"];
                [alert addAction:cancel];
                [alert addAction:ok];
                [self presentViewController:alert animated:true completion:nil];
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
            [self hideHud];
        }];
    }
    
}
- (AddressPickerView *)pickerView{
    if (!_pickerView) {
         _pickerView = [[AddressPickerView alloc]initWithFrame:CGRectMake(0, SCREEN.height , SCREEN.width, 215)];
        _pickerView.delegate = self;
        // 关闭默认支持打开上次的结果
        //        _pickerView.isAutoOpenLast = NO;
    }
    return _pickerView;
}
#pragma mark-uitextfield delegate
#pragma mark-uitextfield delegate
//取消第一响应，也就是输入完毕，屏幕恢复原状
-( void )textFieldDidEndEditing:(UITextField *)textField
{
    //滑动效果
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@ "ResizeForKeyboard"  context:nil];
    [UIView setAnimationDuration:animationDuration];
    //恢复屏幕
    self.view.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    //假如多个输入，比如注册和登录，就可以根据不同的输入框来上移不同的位置，从而更加人性化
    //键盘高度216
    //滑动效果（动画）
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@ "ResizeForKeyboard"  context:nil];
    [UIView setAnimationDuration:animationDuration];
    if (textField.tag == 2) {
        //将视图的Y坐标向上移动，以使下面腾出地方用于软键盘的显示
        self.view.frame = CGRectMake(0.0f, -120.0f/*屏幕上移的高度，可以自己定*/, self.view.frame.size.width, self.view.frame.size.height);
    }else if (textField.tag == 0) {
        //将视图的Y坐标向上移动，以使下面腾出地方用于软键盘的显示
        self.view.frame = CGRectMake(0.0f, -80.0f/*屏幕上移的高度，可以自己定*/, self.view.frame.size.width, self.view.frame.size.height);
    }else if(textField.tag == 1){
        //将视图的Y坐标向上移动，以使下面腾出地方用于软键盘的显示,/*屏幕上移的高度，可以自己定*/
        self.view.frame = CGRectMake(0.0f, -100.0f, self.view.frame.size.width, self.view.frame.size.height);
    }else if(textField.tag == 3){
        //将视图的Y坐标向上移动，以使下面腾出地方用于软键盘的显示,/*屏幕上移的高度，可以自己定*/
        self.view.frame = CGRectMake(0.0f, -160.0f, self.view.frame.size.width, self.view.frame.size.height);
    }
    
    [UIView commitAnimations];
}

#pragma mark- choooseback delegate
- (void)ChooseBack:(choosebankViewController *)controller didFinish:(NSString *)backName andBackCode:(NSString *)code{
    self.backName.text = backName;
    _bankCode = code;//银行代码
}
#pragma mark - AddressPickerViewDelegate
- (void)cancelBtnClick{
    NSLog(@"点击了取消按钮");
    [self btnClicked:_addressbtn];
}
- (void)sureBtnClickReturnProvince:(NSString *)province City:(NSString *)city Area:(NSString *)area{
    _provice = province;
    _city = city;
    _area = area;
    self.szdqLabel.text = [NSString stringWithFormat:@"%@%@%@",province,city,area];
    [self btnClicked:_addressbtn];
}

@end
