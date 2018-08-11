//
//  DEFINE.h
//  
//
//  Created by MrFeng on 14-11-6.
//  Copyright (c) 2014年 金鼎. All rights reserved.
//

#ifndef _____DEFINE_h
#define _____DEFINE_h

//程序标题
#define Main_Name @"信融投资"
//分享内容
#define Share_Message @"我在在使用最安全的理财产品APP信融投资，现在注册还送60元大礼包！ https://appsto.re/cn/i9zF8.i"
//屏幕宽度
#define Screen_Width [UIScreen mainScreen].bounds.size.width
//屏幕高度
#define Screen_Height [UIScreen mainScreen].bounds.size.height
//主颜色
#define Main_Color [UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"color_model" ofType:@"png"]]]
//logo图片
#define Logo_Image [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"login_logo" ofType:@"png"]];
//#define Logo_Image [UIImage imageNamed:@"login_logo@2x"]
//进度条颜色
#define Progress_Color [UIColor redColor]
//小的tag边框图片
#define Small_Tag_Bounds_Image [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"组-225@2x" ofType:@"png"]]
//cell前面的小图片
#define Small_Tag_Bounds_image [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"组-225@2x" ofType:@"png"]]
//大的表格中按钮点击的边框图片
#define Big_More_Bounds_image [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"homePage_moreBtn" ofType:@"png"]]
//注册等按钮背景图片
#define Big_Rect_Bounds_Image [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"login_btn" ofType:@"png"]]
//注册等按钮背景图片 --灰色
#define Big_Rect_Bounds_Image_Grey [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"login_btn_grey" ofType:@"png"]]
//导航条返回按钮图片名称
#define Nav_Back_Btn_Image_Name @"return_btn"
//多数背景颜色
#define Custom_Background_Color [UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"lock_color" ofType:@"png"]]]

#define IPhone4_5_6_6P(a,b,c,d) (CGSizeEqualToSize(CGSizeMake(320, 480), [[UIScreen mainScreen] bounds].size) ?(a) :(CGSizeEqualToSize(CGSizeMake(320, 568), [[UIScreen mainScreen] bounds].size) ? (b) : (CGSizeEqualToSize(CGSizeMake(375, 667), [[UIScreen mainScreen] bounds].size) ?(c) : (CGSizeEqualToSize(CGSizeMake(414, 736), [[UIScreen mainScreen] bounds].size) ?(d) : 0))))
//导航栏按钮
#define NavBtn_Tag 10
//标签栏按钮
#define TabBar_Btn_Tag 100
//首页广告滚动视图的图片视图
#define HomePage_Advertisement_ImageView_Tag 110
//注册页面text的tag
#define Register_TextField_Tag 120
//实名认证text的tag
#define MyInfo_Attestation_TextField_Tag 130
//银行卡btn的tag
#define MyInfo_BankCard_Btn_Tag 140
//投资标题btn 的tag
#define MyInfo_Invest_Title_Btn_Tag 200
//rgb调色
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

//url地址http://124.205.229.26:7005/ 正式：http://www.xrtzp2p.com 镜像：
#define Main_URL @"http://www.xrtz.org/app/publicRequest"
//www.zhongxiangdai.com
#define Help_URL @"http://www.xrtz.org"
//图片URL
#define Image_URL @"http://www.xrtz.org"
//115.28.171.163:10022
//外网IP
#define Test_URL @"http://www.xrtz.org"
//本地图片URL
//#define Test_URL @"192.168.0.164:80"

//登陆的method
#define Login_Method @"loginRequestHandler"
//投资详情
#define Login_pengder @"MyInvestLoanRequestHandler"
//修改密码
#define change_pasworde @"passwordModifyRequestHandler"
//注册的method
#define Register_Method @"registRequestHandler"
//信息的method
#define Get_Message_Method @"smsRequestHandler"
//banner广告页method
#define Banner_Method @"bannerRequestHandler"
//项目列表method
#define Project_List_Method @"loanRequestHandler"
//项目详情method
#define Project_Detail_Method @"loanIdFindRequestHandler"
//红包
#define Red_message  @"userCouponRequestHandler"
//最新动态
#define New_fundation  @"activityRequestHandler"
//平台公告
#define Activit_Fundation  @"anoucementRequestHandler"
//查询个人信息
#define Personal_Information_Method @"centerHandler"
//交易记录method
#define Transaction_Record_Method @"userBillRequestHandler"
//判断是否实名认证
#define Judge_IsAttestation_Method @"investorPermissionRequestHandler"
//实名身份认证method
#define Attestation_Method @"pnrpayRegisterRequestHandler"
//银行卡查询
#define BankCard_Search_Method @"pnrpayBankCardRequestHandler"
//设置和修改支付密码
#define Send_PayPassword @"cashPasswordModifyRequestHandler"

//绑定银行卡
#define BankCard_bank_Method @"pnrpayBankCardBindRequestHandler"

#define Get_HandleCharge_Method @"calculateFeeRequestHandler"
//提现操作
#define Extract_Method @"pnrpayWithdrawRequestHandler"
//投资操作
#define Bid_Method @"pnrpayInvestRequestHandler"
//个人投资记录
#define Invest_Rect_Method @"myInvestRequestHandler"
//找回密码第一步
#define Find_Password_First_Method @"pwdFindHandler"
//找回密码第二步
#define Find_Password_Second_Method @"pwdFind2Handler"
//文章列表method
#define Article_List_Method @"nodeRequestHandler"
//充值
#define Recharge_Method @"pnrpayRechargeRequestHandler"
//我的汇付
#define my_huiFu @"pnrpayAccountRequestHandler"
//新手标
#define My_New  @"loanRequest2Handler"
//手机验证
#define ID_phone @"loginRegisterRequestHandler"
//提交反馈
#define sumbit_back @"feedbackRequestHandler"
//琅琊榜
#define Lang_ya @"langyaListRequestHandler"
#endif
