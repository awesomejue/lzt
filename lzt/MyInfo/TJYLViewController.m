//
//  TJYLViewController.m
//  lzt
//
//  Created by hwq on 2018/3/6.
//  Copyright © 2018年 hwq. All rights reserved.
//

#import "TJYLViewController.h"
#import <CoreImage/CoreImage.h>
#import "htmlViewController.h"
#import "TGJLViewController.h"

@interface TJYLViewController ()



@property (weak, nonatomic) IBOutlet UIButton *rightBtn;
@property (weak, nonatomic) IBOutlet UILabel *headTitle;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavHeight;
@property (weak, nonatomic) IBOutlet UILabel *successPeople;
@property (weak, nonatomic) IBOutlet UILabel *successGetMoney;
@property (weak, nonatomic) IBOutlet UIImageView *qrColde;
@property (weak, nonatomic) IBOutlet UILabel *myCode;

@property (weak, nonatomic) IBOutlet UIButton *ljyqBtn;

@end

@implementation TJYLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (iPhoneX) {
        _NavHeight.constant += 20;
    }
    [self createUI];
    [self loadData];
}
- (void)createUI {
    _ljyqBtn.layer.cornerRadius = 5;
}

- (void) loadData {
    NSDictionary *userInfo = [FuncPublic GetDefaultInfo:mUserInfo];
    //载入数据
    NSString *url =[NSString stringWithFormat:@"%@%@%@%@", [FuncPublic SharedFuncPublic].rootserver ,@"user/account/", userInfo[@"userId"], @"/recommend/url"];
  //  url = [NSString stringWithFormat:@"%@?from=%@&version=%@", url, @"iOS", InnerVersion];
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setValue:@"iOS" forKey:@"from"];
    [param setValue:InnerVersion forKey:@"version"];
    [param setValue:userInfo[@"token"] forKey:@"token"];
    [NetManager GetRequestWithUrlString:url andDic:param finished:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *result = [FuncPublic dictionaryWithJsonData:responseObject];
        if ([result[@"resultCode"] boolValue]) {
            [self showHint:result[@"resultMsg"] yOffset:0];
        }else {
            NSDictionary *dic = result[@"resultData"];
            _successPeople.text = [NSString stringWithFormat:@"%d", [dic[@"inviteUser"] intValue]];
            _successGetMoney.text = [NSString stringWithFormat:@"%.2f", [dic[@"inviteMoney"] doubleValue] / 100];
            _myCode.text = dic[@"recommendCode"];
            [self createQRCode: dic[@"url"]];
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


/**
 * 根据CIImage生成指定大小的UIImage
 *
 * @param image CIImage
 * @param size 图片宽度
 */
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}
- (void)createQRCode : (NSString *)url{
    // 1. 实例化二维码滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 2. 恢复滤镜的默认属性
    [filter setDefaults];
    
    // 3. 将字符串转换成NSData
    
    NSData *data = [url dataUsingEncoding:NSUTF8StringEncoding];
    // 4. 通过KVO设置滤镜inputMessage数据
    [filter setValue:data forKey:@"inputMessage"];
    
    // 5. 获得滤镜输出的图像
    CIImage *outputImage = [filter outputImage];
    
    // 6. 将CIImage转换成UIImage，并放大显示 (此时获取到的二维码比较模糊,所以需要用下面的createNonInterpolatedUIImageFormCIImage方法重绘二维码)
    //    UIImage *codeImage = [UIImage imageWithCIImage:outputImage scale:1.0 orientation:UIImageOrientationUp];
    
    _qrColde.image = [self createNonInterpolatedUIImageFormCIImage:outputImage withSize:200];//重绘二维码,使其显示清晰
    
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)ljyqClicked:(id)sender {
    UIStoryboard *s = [UIStoryboard storyboardWithName:@"HTML" bundle:nil];
    htmlViewController *html = [s instantiateViewControllerWithIdentifier:@"htmlViewController"];
    html.name = @"邀请有礼";
    [self.navigationController pushViewController:html animated:true];
}
- (IBAction)ckxqClicked:(id)sender {
    TGJLViewController *tgjl = [self.storyboard instantiateViewControllerWithIdentifier:@"TGJLViewController"];
    [self.navigationController pushViewController:tgjl animated:true];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
