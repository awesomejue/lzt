if (/(iPad|iPhone|iPod)/g.test(window.navigator.userAgent)) {
    
    document.write("<script src='js/ios/cordova.js'></script>");
    //evil("<script src='js/ios/cordova.js'></script>");
    // var e = document.createElement("script");
    // e.setAttribute("src","js/ios/cordova.js");
    // document.body.appendChild(e);
    
    var cordovaFailed = function(){
        console.log("cordovaFailed");
    };
    
    window.fypay = {
    backToApp:function(success,payData){
        cordova.exec(function(data){
                     success(JSON.parse(JSON.stringify(data)));
                     },cordovaFailed, "FuApp", "backToApp",[payData]);
    },
    goBack:function(success){
        cordova.exec(function(data){
                     success(JSON.parse(JSON.stringify(data)));
                     }, cordovaFailed, "FuApp", "goBack",[]);
    },
    getOrderBaseInfo:function(success){
        cordova.exec(function(data){
                     //success(JSON.parse(JSON.stringify(data)));
                     eval("javascript:"+success+"("+JSON.stringify(data)+");");
                     },cordovaFailed, "FuApp", "getOrderInfo",[]);
    },
    getRSA:function(success,pwd){
        cordova.exec(function(data){
                     //success(JSON.parse(JSON.stringify(data)));
                                              var a = JSON.stringify(data);
                                              console.log(a);
                                              eval("javascript:"+success+"("+a+");");
                     },cordovaFailed, "FuApp", "getRSA",[pwd]);
    },
    getMD5QueryCardInfo:function(success,md5Dic){
        cordova.exec(function(data){
                                  var a = JSON.stringify(data);
                                  console.log(a);
                                  eval("javascript:"+success+"("+a+");");
                     //success(JSON.parse(JSON.stringify(data)));
                     },cordovaFailed, "FuApp", "getMD5QueryCardInfo",[md5Dic]);
    },
    getMD5Sign:function(success,md5Dic){
        cordova.exec(function(data){
                     var a = JSON.stringify(data);
                     console.log(a);
                     eval("javascript:"+success+"("+a+");");
                     //success(JSON.parse(JSON.stringify(data)));
                     },cordovaFailed, "FuApp", "getMD5Sign",[md5Dic]);
    },
    addSign_RSA:function(success,md5Dic){
        cordova.exec(function(data){
                     var a = JSON.stringify(data);
                     console.log(a);
                     eval("javascript:"+success+"("+a+");");
                     //success(JSON.parse(JSON.stringify(data)));
                     },cordovaFailed, "FuApp", "addSign_RSA",[md5Dic]);
    },
    getDeviceInfo:function(success,md5Dic){
        cordova.exec(function(data){
                                     var a = JSON.stringify(data);
                                     console.log(a);
                                     eval("javascript:"+success+"("+a+");");
                     //success(JSON.parse(JSON.stringify(data)));
                     },cordovaFailed, "FuApp", "getDeviceInfo",[md5Dic]);
    },
    giveUpPay:function(){
        cordova.exec(function(data){
                     },cordovaFailed, "FuApp", "giveUpPay",[]);
    },
    paySuccess:function(success,payData){
        cordova.exec(function(data){
                     },cordovaFailed, "FuApp", "paySuccess",[payData]);
    },
    showKeyBoard:function(success)
        {
            cordova.exec(function(data){
                                                  var a = JSON.stringify(data);
                                                  console.log(a);
                                                  eval("javascript:"+success+"("+a+");");
                         //success(JSON.parse(JSON.stringify(data)));
                         },cordovaFailed,"FuApp","showKeyBoard",[]);
        },
    showKeyBoardNew:function(success)
        {
            cordova.exec(function(data){
                         var a = JSON.stringify(data);
                         console.log(a);
                         eval("javascript:"+success+"("+a+");");
                         //success(JSON.parse(JSON.stringify(data)));
                         },cordovaFailed,"FuApp","showKeyBoardNew",[]);
        },
    showAlert:function(msg)
        {
            cordova.exec(function(){},cordovaFailed,"FuApp","showJSAlert",[msg]);
        },
        
    showNewAlert:function(success,msg)
        {
            cordova.exec(function(data){
                         var a = JSON.stringify(data);
                         console.log(a);
                         eval("javascript:"+success+"("+a+");");
                         //success(JSON.parse(JSON.stringify(data)));
                         },cordovaFailed, "FuApp", "showJSNewAlert",[msg]);
        }
    };
}

//因接口变动较大，以前的绑定卡等接口可能不再适用
//不过参数及步骤等仍可供参考

//通过jsbridge加载订单基本信息成功后的回调
var loadOrderBaseInfoSuccess = function(orderInfo) {
    //  eval("var order = " + orderInfo);
//    alert(JSON.stringify(orderInfo)) ;
    $("#order_amt").val(yuan2Fen(orderInfo.orderAmt + ""));
    $("#card_type").val(orderInfo.cnm+"    "+"借记卡") ;
    $("#card_no").val(orderInfo.bankCard) ;
    $("#user_name").val(orderInfo.name) ;
    $("#id_no").val(orderInfo.idNo) ;
    $.testAssign(orderInfo.test) ;
    orderConfirm.init(orderInfo);
//    orderConfirm.qryOrderDetailInfo();
};

var checkboxFn=function(){
    $(this).each(function() {
        $(this).click(function(event) {
            if (!$(this).children().is(':checked'))
            {
                $(this).addClass("on");
                $(this).children()[0].checked = true;
            }
            else
            {
                $(this).removeClass('on');
                $(this).children()[0].checked = false;
            }
            event.stopPropagation();
        })
    }).children().hide();
} ;

var encryptCreditSuccess = function(enCvn) {
    window.fypay.showAlert("encryptCreditSuccess");
    bindCard.submitCreditCard(enCvn);
};

var sendSms = function(mobileNo){
    if(!bindCard.checkCreditUser(true)){
        return;
    }
    
    var postData = {
    VERSION:"2.0" ,
    TYPE:"02" ,
    MCHNTCD:orderConfirm.mchntCd ,
    ORDERID:orderConfirm.orderNo ,
    MCHNTORDERID:orderConfirm.mchntOrderId ,
    USERID:orderConfirm.userId ,
    BANKCARD:orderConfirm.bankCard ,
    VERCD:"0000" ,
    MOBILE:$("#mobile_no").val() ,
    CVN:'' ,
    SIGNTP:"MD5",
    VER:"sdk2.1" ,
    REM1:orderConfirm.sdkVersion
    }
    
    window.fypay.getMD5Sign("sendMesRSA",postData) ;
    
};
var addSign = function(sign)
{
    var mobileNo = $("#mobile_no").val();
    var version = "2.0" ;
    var type = "02" ;
    var mchntCd = orderConfirm.mchntCd ;
    var orderNo = orderConfirm.orderNo ;
    var signTP = "MD5" ;
    var postData = {VERSION:version,TYPE:type,MCHNTCD:mchntCd,ORDERID:orderNo,MOBILE:mobileNo,SIGNTP:signTP,SIGN:sign};
    window.fypay.getRSA("sendMesRSA",$.createXML(postData));

}

var sendMesRSA = function(postData)
{
    console.log("postData:"+postData);

    $.httpPost("sdkpay/messageSdkAction.pay", postData, true, function (fm) {
               if (fm.RESPONSECODE === '0000') {
               
               var SDKKey = hex_md5('02') ;
               SDKKey = hex_md5(SDKKey) ;
               var dateSign = fm.RESPONSECODE+'|'+fm.SIGNPAY+'|'+SDKKey ;
               if(fm.SIGN != hex_md5(dateSign))
               {
               window.fypay.showAlert("验证码数据被篡改");
               window.fypay.giveUpPay();
               return ;
               }
               
               
               $("#btn_vcode").attr('disabled', true);
               window.fypay.showAlert("发送短信验证码成功");
               orderConfirm.signPay = fm.SIGNPAY ;
               VCODE.timer = self.setInterval("VCODE.beginTimer()",1000);
               
               setTimeout(function(){
                          $("#btn_vcode").attr('disabled', false);
                          },60000);
               }
               }, function (desc) {
               console.log("sendMesRSA:"+desc.RESPONSEMSG);
               window.fypay.showAlert(desc.RESPONSEMSG);
               });
};

var keyDown = {
    click_id : '',
inputClick: function(clickId){
    console.log("click");
    click_id = clickId;
    window.fypay.showKeyBoard(clickId);
}
};

var keyDownNew = {
        click_id : '',
    inputClick: function(clickId){
        console.log("click");
        click_id = clickId;
        window.fypay.showKeyBoardNew(clickId);
    }
};



//首页 银行卡信息透传
var orderConfirm = {
    mchntCd: '', //商户号
    orderNo: '', //订单号
    bankCard: '', //银行卡号
    cnm : '' , // 银行名称
    ctp : '',   //卡类型（信用卡 借记卡）
    idNo : '' ,  //身份证号
    mchntOrderId : '' , //商户订单号
    name : '',   //卡属姓名
    orderAmt : '', //订单金额
    userId : '' ,  //用户ID
    signPay : '' ,  //获取验证码后返回字段
    
    mobileNo: '', //用户手机号
    ast: '', //是否需要短信验证码1-需要，0-不需要
    orderInfo: {},
        
    init: function(order) {
        orderConfirm.mchntCd = order.mchntCd;
        orderConfirm.orderNo = order.orderNo;
        orderConfirm.bankCard = order.bankCard ;
        orderConfirm.cnm = order.cnm ;
        orderConfirm.ctp = order.ctp ;
        orderConfirm.idNo = order.idNo ;
        orderConfirm.mchntOrderId = order.mchntOrderId ;
        orderConfirm.name = order.name ;
        orderConfirm.orderAmt = order.orderAmt ;
        orderConfirm.userId = order.userId ;
        orderConfirm.sdkVersion = order.sdkVersion ;
        //orderConfim  作为储存数据对象 在此处赋值
        
        spinner.spin();
    },
        //查询订单详情   //更换订单查询接口接口
    qryOrderDetailInfo: function() {
        console.log(orderConfirm.mobileNo);
        //url, data, hud, success, failed
        var postData = {
        Lid: orderConfirm.mobileNo,
        OrderNo: orderConfirm.orderNo,
        
//        goodsNm: orderConfirm.goodsNm,

        Action: 'orderDetail'
        };
        window.fypay.getRSA("orderConfirm.qryOrderDetailInfoWithRSA",$.createXML(postData));
        //orderConfirm.qryOrderDetailInfoWithRSA($.createXML(postData));
    },
    qryOrderDetailInfoWithRSA: function(data)
        {
            $.httpPost("fmp/doPay.pay", data, true, function(data) {
                       orderConfirm.setAst(data.Ast);
                       data.amt_fen = yuan2Fen(data.Amt + "");
                       data.format_date = formatDate(data.Date + "");
                       
//                       data.TranName = data.goodsNm ;
                       data.TranName = data.GoodsNm ;
//                       alert(data.GoodsNm);
//                       alert(data.MchntCd);
                       orderConfirm.orderInfo = data;
                       orderConfirm.render(orderConfirm.orderInfo, true);
                       orderConfirm.mchntCd = data.MchntCd ;
                       }, function(msg) {
                       window.fypay.showAlert(msg);
                       window.fypay.giveUpPay();
                       });
        },
    render: function(data, isIndex) {
        var template = $('#tmpl_order_info').html();
        Mustache.parse(template); // optional, speeds up future uses
        data.title = isIndex ? '订单信息确认' : '支付结果';
        var rendered = Mustache.render(template, orderConfirm.orderInfo);
        $('#div_body').html(rendered);
        if (isIndex) {
            PageManager.setCurrentPage(PageManager.orderConfirmPage);
            $("#div_result").hide();
            //银行卡支付
            $("#btn_bank_pay").bind("click", function() {//chenadd2
                                    payOrder.queryMyBank2();
                                    });
            
//            //快捷支付(银行绑定)
//            $("#btn_to_bank_list").bind("click", function() {
//                                        payOrder.queryMyBank();
//                                        });
            
        }
        else {
            PageManager.setCurrentPage(PageManager.payResultPage);
            $("#btn_to_bank_list").html("返回应用");
            $("#div_result").show();
            $("#btn_to_bank_list").bind("click", function() {
                                        window.fypay.backToApp("",data);
                                        });
        }
    },
    queryMchntInfo: function()
    {
        
    },
    needVCode: function() {
        return 1 === orderConfirm.ast;
    },
    setAst: function(ast) {
        orderConfirm.ast = ast;
    }
    };

    var bindCard = {
    mobileNo: '', //用户手机号
    getVerCode: '0', //是否获取过手机验证码
    bst: '',//判断显示CLPP
    validData : '',   //用来接收卡信息传给支付接口
        
    //查询绑定的卡类型2
queryCard2: function()
    {//chenadd5
        bindCard.mobileNo = $.urlParam("mobileNo");
        bindCard.bst = $.urlParam("bst");
        var cardName = $("#card_name").val();
        if (cardName.length < 12 || cardName.length >= 20) {
            window.fypay.showAlert("请输入正确的银行卡");
            return;
        }
        var postData = {Ono: cardName,OrderId:$.urlParam("orderNo"),MchntCd:$.urlParam("MchntCd"), Lid: bindCard.mobileNo, Action:'queryCardBin2'};
        window.fypay.getRSA("bindCard.queryCard2WithRSA",$.createXML(postData));
    },
    queryCard2WithRSA: function(postData)
    {
        $.httpPost("fmp/doPay.pay", postData, true, function (fm)
            {
                   if (fm.Ctp === '05') {
                   window.fypay.showAlert("该银行卡暂不支持银行卡支付");//CLPP银行卡支付
                   return;
                   } else if (fm.Ctp === '06') {
                   window.fypay.showAlert("该卡暂不支持，您可以先绑定信用卡");
                   return;
                   }
                   var params = {
                   cardType:fm.Ctp,
                   cardNm:fm.Cnm,
                   cardNo:$("#card_name").val(),
                   insCd:fm.InsCd,
                   mobileNo:bindCard.mobileNo,
                   isOpenNoPay:fm.IsOpenNoPay,
                   isUpdPwd:fm.IsUpdPwd,
                   orderNo:$.urlParam("orderNo"),
                   bst:bindCard.bst//CLPP
                   };
                   if (fm.Ctp === '01') { //借记卡
                   
//                   alert(params);
                   window.location.href = "card_setup_debit.html?"+$.param( params);

                   
                   } else if (fm.Ctp === '02') { //信用卡
                   
                   window.location.href = "card_setup_credit.html?"+$.param( params);
//                   
                   
                   } else if (fm.Ctp === '04') { // 富友卡
                   window.location.href = "card_setup_fucard.html?"+$.param( params);
                   }
        }, function (desc) {
                   window.fypay.showAlert(desc);
                   });
    },
    
    //查询绑定的卡类型1
    queryCard: function(){
        bindCard.mobileNo = $.urlParam("mobileNo");
        var cardName = $("#card_name").val();
        if (cardName.length < 12 || cardName.length >= 20) {
            window.fypay.showAlert("请输入正确的银行卡");
            return;
        }
        var postData = {Ono: cardName, Lid: bindCard.mobileNo, Ptp: '1'};
        window.fypay.getRSA("bindCard.queryMyCardBin",$.createXML(postData));
      },
      
         queryMyCardBin: function(data){
             var cardName = $("#card_name").val();

             $.httpPost("nocardPay/queryCardBin.pay",data,  true, function (fm) {
                        if (fm.Ctp === '05') {
                        window.fypay.showAlert("该银行卡暂不支持快捷支付");
                        return;
                        } else if (fm.Ctp === '06') {
                        window.fypay.showAlert("该卡暂不支持，您可以先绑定信用卡");
                        return;
                        }
                        var params = {cardType:fm.Ctp,
                        cardNm:fm.Cnm,
                        cardNo:cardName,
                        insCd:fm.InsCd,
                        mobileNo:bindCard.mobileNo,
                        isOpenNoPay:fm.IsOpenNoPay,
                        isUpdPwd:fm.IsUpdPwd
                        };
                        
                        if (fm.Ctp === '01') { //借记卡
                        window.location.href = "card_setup_debit_fast.html?"+$.param( params);
                        }
                        else if (fm.Ctp === '02') { //信用卡
                        window.location.href = "card_setup_credit_fast.html?"+$.param( params);
                        }
                        else{
                        window.fypay.showAlert("该卡暂不支持");
                        }
                        //                   else if (fm.Ctp === '04') { // 富友卡
                        //                        window.location.href = "card_setup_fucard.html?"+$.param( params);
                        //                   }
                        }, function (desc) {
                        window.fypay.showAlert(desc);
                        });
             
             
             
             
         },
             //进入卡片信息界面初始化
         bindCardPageInit:function(){
             var cardType = $.urlParam("cardType");
             if (cardType === 1 || cardType === 2) { //借记卡 或者信用卡
                 if($.urlParam("isOpenNoPay") !== 0){  //当无卡支付未开通，输入实名认证信息
                     $("#id_card_no").attr('disabled', false);
                     $("#user_name").attr('disabled', false);
                 }
             } else if (cardType === 4) { // 富友卡
                 
             }
             
         },
        
        

    
    //校验卡用户的基本信息
    checkCardUser :function(isNeedUserInfo){
        if(isNeedUserInfo){
            if(!IdCardValidate($("#id_card_no").val())){
                window.fypay.showAlert("身份证格式错误");
                $("#submit_btn").attr('disabled', false);
                return false;
            }
            if($("#user_name").val().length < 2){
                window.fypay.showAlert("请输入正确的持卡人姓名");
                $("#submit_btn").attr('disabled', false);
                return false;
            }
            if($("#mobile_no").val().length !== 11){
                window.fypay.showAlert("手机号码格式错误");
                $("#submit_btn").attr('disabled', false);
                return false;
            }
            return true;
        }
    },
        checkCreditUser :function(isNeedUserInfo){
            if(isNeedUserInfo){
                
                if($("#mobile_no").val().length !== 11){
                    window.fypay.showAlert("手机号码格式错误");
                    $("#submit_btn").attr('disabled', false);
                    return false;
                }
                return true;
            }
        },
   
    
    //绑定借记卡
    bindDebitCard :function(){
        if(!bindCard.checkCardUser(true)){
            return;
        }
        bindCard.mobileNo = $.urlParam("mobileNo");
        var cardNo = $("#card_no").val();
        var idNo = $("#id_card_no").val();
        var userName = $("#user_name").val();
        var mobileNO = $("#mobile_no").val();
        var postData = {Lid:bindCard.mobileNo,Status:"1",Ono:cardNo,OCerTp:'0',Onm:userName,OCerNo:idNo,O23:'',Okey:'',OkTp:'2',OkFmt:'13',Cvn:'',Mno:mobileNO};
        
        var bst = $.urlParam("bst");
        
        console.log(bst);
        if(bst === '1')//验证借记卡
        {
//            alert("借记卡");
//            var postData2 = {Lid:bindCard.mobileNo,Status:"1",Action:'valid',Ono:cardNo,Onm:userName,OCerTp:'0',OCerNo:idNo,Mno:mobileNO,Cvn:'',System:'JZH',BusiCd:'CZ'};
            var postData2 = {Lid:bindCard.mobileNo,Status:"1",Ono:cardNo,Onm:userName,OCerTp:'0',OrderId:$.urlParam("orderNo"), OCerNo:idNo,Mno:mobileNO,Cvn:''};
            bindCard.queryCardDetail(postData2);
        }
        else{
//            alert("绑借记卡");
            window.fypay.getRSA("bindCard.sumitBindCardRSA",$.createXML(postData));

//            bindCard.sumitBindCard(postData);
        }
    },
        
    
    //绑定信用卡→加密cvn
    bindCreditCard :function(){
        var cardCvn = $("#card_cvn").val();
        
        if (cardCvn.length !== 3 || cardCvn == "XXX") {
            window.fypay.showAlert("请输入正确的CVN号码");
            return;
        }
        var cardDate = $("#card_date").val();
        if (cardDate.length < 1) {
            window.fypay.showAlert("请输入正确的信用卡有效期");
            return;
        }
        cardDate =  cardDate.substring(2,cardDate.length).replace("-","");
        if(!bindCard.checkCardUser(true)){
            return;
        }
        window.fypay.getRSA("bindCard.submitCreditCard", cardCvn+cardDate);
    },
    
    //绑定富友卡
    bindFuCard :function(){
        var cardNo = $("#card_no").val();
        bindCard.mobileNo = $.urlParam("mobileNo");
        var postData = {Lid:bindCard.mobileNo,Ono:cardNo,OCerTp:'0',Onm:'',OCerNo:'',O23:'',Okey:'',OkTp:'2',OkFmt:'13',Cvn:'',Mno:bindCard.mobileNo};
        bindCard.sumitBindCard(postData);
    },
    
    //提交信用卡信息
    submitCreditCard :function(enCvn){
        var cardNo = $("#card_no").val();
        var idNo = $("#id_card_no").val();
        var userName = $("#user_name").val();
        var mobileNO = $("#mobile_no").val();
        bindCard.mobileNo = $.urlParam("mobileNo");
        
        var bst = $.urlParam("bst");
        console.log(bst);
        var postData = {};
        //去验证实名
        if(bst === '1')
        {
//            alert("信用卡");

//            postData  = {Lid:bindCard.mobileNo,Status:"1",Action:'valid',Ono:cardNo,Onm:userName,OCerTp:'0',OCerNo:idNo,Mno:mobileNO,Cvn:enCvn,System:'JZH',BusiCd:'CZ'};
            postData  = {Lid:bindCard.mobileNo,Status:"1",Ono:cardNo,Onm:userName,OCerTp:'0',OCerNo:idNo, OrderId:$.urlParam("orderNo"), Mno:mobileNO,Cvn:enCvn};
            bindCard.queryCardDetail(postData);
        }
        //去绑卡
        else{
//            alert("绑信用卡");

            postData = {Lid:bindCard.mobileNo,Ono:cardNo,OCerTp:'0',Onm:userName,OCerNo:idNo,O23:'',Okey:'',OkTp:'2',OkFmt:'13',Cvn:enCvn,Mno:mobileNO};
            window.fypay.getRSA("bindCard.sumitBindCardRSA",$.createXML(postData));
        }
    },
    
    queryCardDetail:function(data)
        {
//            alert(JSON.stringify(location.href));
            bindCard.validData = data;
            window.fypay.getMD5QueryCardInfo("bindCard.sumitQuerCardReal",data);
        },
        //请求服务器提交查询实名卡信息
    sumitQuerCardReal:function(postData){
        //bindCard.mobileNo = $.urlParam("mobileNo");
        bindCard.mobileNo = $("#mobile_no").val();
        $.httpPost("mbPay/sdkCheck.pay",postData,true,function(msg){
                   var params = {mobileNo:bindCard.mobileNo ,cardType:$.urlParam("cardType"),isUpdPwd:$.urlParam("isUpdPwd"),isBackPwd:"0",title_name:"确认绑定", bst:$.urlParam("bst"),orderNo:$.urlParam("orderNo")};
                   
                   window.location.href="pay_pwd_setup.html?"+$.param(params)+'&'+$.param(bindCard.validData);
                   },function(msg){
                   window.fypay.showAlert(msg);
                   });
    },
    
    //请求服务器提交绑定卡信息
         sumitBindCardRSA :function(postData){
             bindCard.sumitBindCard(postData);
         },
    sumitBindCard :function(postData){
        bindCard.mobileNo = $.urlParam("mobileNo");
        $.httpPost("nocardPay/bindCard.pay",postData,true,function(msg){
                   var params = {mobileNo:bindCard.mobileNo ,cardType:$.urlParam("cardType"),isUpdPwd:$.urlParam("isUpdPwd"),isBackPwd:"0",title_name:"确认绑定", bst:$.urlParam("bst")};
                   
                   window.location.href="pay_pwd_setup.html?"+$.param(params);
                   },function(msg){
                   window.fypay.showAlert(msg);
                   });
    },
    
    //进入卡片信息界面初始化
    pwdPageInit:function(){
        $("#title_name").html($.urlParam("title_name"));
        var isUpdPwd = $.urlParam("isUpdPwd");
        var cardType = $.urlParam("cardType");
//        alert("isbackpwd:"+$.urlParam("isBackPwd"));
        if($.urlParam("isBackPwd") == 1){
            $("#id_card_no").show();
        }else{
            $("#id_card_no").hide();
            if (cardType === 1 || cardType === 2 ) { //借记卡 或者信用卡
                if(isUpdPwd !== 0){  //当无卡支付未开通，输入实名认证信息
                    $("#re_pay_pwd").show();
                }
            } else if (cardType === 4) { // 富友卡
                $("#re_pay_pwd").hide();
                $("#div_bank_vcode").hide();
            }
        }
        
        $("#btn_vcode").click(function(){
                              var mob1  = $.urlParam("mobileNo");
                                 var mob2  = $.urlParam("Mno");

                              sendSms(mob1);
                              
                              bindCard.getVerCode = "1";
                              });
        
        
    },
    
    //设置 支付密码
    setPayPwd :function(){
        var payPwd = $("#pay_pwd").val();
        var rePayPwd = $("#re_pay_pwd").val();
        
        var isUpdPwd = $.urlParam("isUpdPwd");
        var cardType = $.urlParam("cardType");
        if (cardType === 1 || cardType === 2) { //借记卡 或者信用卡
            if(bindCard.getVerCode === 0){
                window.fypay.showAlert("请先获取手机验证码");
                return false;
            }
            if($("#input_vcode").val().length !== 4){
                window.fypay.showAlert("请输入手机验证码");
                return false;
            }
            if($.urlParam("isBackPwd") === 1){
                if(!IdCardValidate($("#id_card_no").val())){
                    window.fypay.showAlert("身份证格式错误");
                    return false;
                }
            }
            if(payPwd.length < 6){
                window.fypay.showAlert("请输入支付密码");
                return false;
            }
            if(isUpdPwd !== 1){  //未设置过，校验确认支付密码
                if(rePayPwd.length < 6){
                    window.fypay.showAlert("请输入确认支付密码");
                    return false;
                }
                if(payPwd !== rePayPwd){
                    window.fypay.showAlert("两次密码输入不一致");
                    return false;
                }
            }
        } else if (cardType === 4) { // 富友卡
            if(payPwd.length < 6){
                window.fypay.showAlert("请输入支付密码");
                return false;
            }
        }
        window.fypay.getRSA("bindCard.submitBindPayPwd", payPwd);
        return true;
    },
    
    //提交绑定的支付密码
    submitBindPayPwd :function(encrptPwd){
        var postData = {Lid:$.urlParam("mobileNo"),Status:"1"};
        postData.VerCd = $("#input_vcode").val();
        var action;
        if($.urlParam("isBackPwd") == 1){ //找回密码
        
//            action = "nocardPay/pwdUpdCheck.pay";
//            postData.OCerNo = $("#id_card_no").val();
//            postData.NPkey = encrptPwd;
//            postData.NLkey = "";
//            postData.Ctp = "1";
            
            
            action = "nocardPay/findPwd.pay";
            postData.OCerNo = $("#id_card_no").val();
//            postData.NPkey = encrptPwd;
            postData.Pkey = encrptPwd;
            postData.NLkey = "";
            postData.Ctp = "1";
            window.fypay.getDeviceInfo("bindCard.findMyPwd",postData);
 

        }
        else{ //绑定卡

            postData.NLkey = "";
            postData.OLkey = "";
            if($.param("isUpdPwd") == 1){  //1 修改 2 校验

                postData.OPkey=encrptPwd;
                postData.NPkey = "";
                postData.Ctp = "2";
            }else{

                postData.NPkey = encrptPwd;  //修改密码
                postData.OPkey = "";
                postData.Ctp = "1";
            }
            
            window.fypay.getRSA("bindCard.bindCardPwdRSA",$.createXML(postData));

            
        }
        
        
    },
        
        
    bindCardPwdRSA:function(postData)
        {
            action = "nocardPay/pwdUpdCheck.pay";

            $.httpPost(action,postData,true,function(msg){
                       if($.urlParam("isBackPwd") == 1){
                       window.fypay.showAlert("找回支付密码成功");
                       //exec("javascript:history.go(-1);");
                       history.go(-1);
                       }else{
                       
                       if ($.urlParam("isCardManager") == '1') {
                       window.location.href = "card_manager.html";
                       } else {
                       window.fypay.showAlert("绑定成功");
                       window.location.href="index.html";
                       }
                       
                       }
                       
                       },function(msg){
                       window.fypay.showAlert(msg);
                       });
        },
        
    findMyPwd:function(postData) {
       var action = "nocardPay/findPwd.pay";

        $.httpPost(action,postData,true,function(msg){
                   if($.urlParam("isBackPwd") == 1){
                   window.fypay.showAlert("找回支付密码成功");
                   //exec("javascript:history.go(-1);");
                   history.go(-1);
                   }else{
                   
                   if ($.urlParam("isCardManager") == '1') {
                   window.location.href = "card_manager.html";
                   } else {
                   window.fypay.showAlert("绑定成功");
                   window.location.href="index.html";
                   }
                   
                   }
                   
                   },function(msg){
                   window.fypay.showAlert(msg);
                   });
    }

        
        
};

// 进入银行卡填写页面||选择银行，支付订单页面
var payOrder = {//var 自定义
    //先调用新的订单确认接口，查看订单状态
queryMyOrder:function()
    {
        var postData = {MchntCd:orderConfirm.mchntCd ,OrderId:orderConfirm.orderNo ,Action:'queryOrderId'};
        window.fypay.getRSA("payOrder.queryMyOrderWithRSA",$.createXML(postData));
    },
queryMyOrderWithRSA:function(data)
    {
        $.httpPost("fmp/doPay.pay", data, true, function(data){
                   alert(msg.RDesc);
                   
                   },function(msg){
                   window.fypay.showAlert(msg);
                   if(msg=='您的订单尚未完成付款')
                        payOrder.queryMyBank2();
                   
                 
                   
                   });
    },
    
    
    
    //进入银行卡填写界面
    queryMyBank2: function()//->填写银行卡页面 //chenadd3
        {
            var postData = {Lid:orderConfirm.mobileNo,Action:'MchntDesp2',OrderId:orderConfirm.orderNo};
            window.fypay.getRSA("payOrder.queryMyBank2WithRSA",$.createXML(postData));
            //orderConfirm.qryOrderDetailInfoWithRSA($.createXML(postData));
        },
    queryMyBank2WithRSA: function(data)
        {
            $.httpPost("fmp/doPay.pay", data, true, function(data){
                       var params = {mobileNo:orderConfirm.mobileNo,bst:'1',orderNo:orderConfirm.orderNo,MchntCd:orderConfirm.mchntCd,MchntDesp:data.MchntDesp,Dbeits:data.Dbeits,Dbeitm:data.Dbeitm,Credits:data.Credits,Creditm:data.Creditm};
                       window.location.href = "card_setup_two.html?"+$.param(params);
                       }, function(msg) {
                       window.fypay.showAlert(msg);
                       });
        },
        
    checkedCard: '', //选中的银行卡号
    mobil: '', //该卡对应的手机号
    pkey: '', //支付密码
        Onm : '', //户名
    OCerTp: '',  //证件类型 0为身份证
    OCerNo:'',   //证件号码
    Mno:'',      //银行预留手机号
    Cvn:'',      //信用卡cvn
    ValidDate:'', //信用卡有效期
    

    
    queryMyBank: function() {
        var postData = {Lid:orderConfirm.mobileNo};
        window.fypay.getRSA("payOrder.queryMyBankWithRSA",$.createXML(postData));

        //查询用户绑定的银行卡
     },
    
     queryMyBankWithRSA: function(data) {
         
         $.httpPost("nocardPay/queryBindCard2.pay",
                    data, true, function(data) {
                    if (!data.List || data.List.length === 0) {
                    var params = {mobileNo:orderConfirm.mobileNo,bst:'0'};
                    window.location.href = "card_setup.html?"+$.param(params);
                    } else {
                    data.title = '选择银行';
                    payOrder.initBankList(data);
                    }
                    }, function(msg) {
                    window.fypay.showAlert(msg);
                    });

     },
    
    initBankList: function(data) {
        for (var o in data.List) {
            data.List[o].cardNm = payOrder.getCardType(data.List[o].CardType);
        }
        var template = $('#tmpl_bank_list').html();
        Mustache.parse(template); // optional, speeds up future uses
        var rendered = Mustache.render(template, data);
        $('#div_body').html(rendered);
        PageManager.setCurrentPage(PageManager.orderPayPage);
        //设置默认选中
        if (data.length == 0) {
            $("#card_no_" + data.List.CardNo + "").html(formatCardNo(data.List.CardNo));
            $(".card_no").val(data.List.CardNo);
            $("#check_card_" + data.List.CardNo + "").attr("checked", data.List.PayCard == 1);
            if (data.list.PayCard == 1) {
                payOrder.setSelectCard(data.List.CardNo, data.List.BankPhone);
            }
        } else {

            for (var o in data.List) {

                $("#card_no_" + data.List[o].CardNo + "").html(formatCardNo(data.List[o].CardNo));
                $("#check_card_" + data.List[o].CardNo + "").attr("checked", data.List[o].PayCard == 1);
                if (data.List[o].PayCard == 1) {
                    payOrder.setSelectCard(data.List[o].CardNo, data.List[o].BankPhone);
                }
                $(".bank_list_item:last-child .bank_list_left").css('border-bottom', 'none');

            }
        }
        
        

        
        if (orderConfirm.needVCode()) {
            $("#div_bank_vcode").show();
        } else {
            $("#div_bank_vcode").hide();
        }
        
        //获取验证码
        $("#btn_vcode").click(function() {
                              sendSms(orderConfirm.mobileNo);
                              });
        
        $("#btn_pay").click(function() {
                            if (payOrder.verify()) {
                            payOrder.signPkey();
                            }
                            });
        
        
        $("#btn_setdefault").click(function() {
                                   CardManager.setDefaultPayCard();
                                   });
        
        $(".bank_list_item").swipe({
                                   swipeLeft: function(event, phase, direction, distance, duration, fingerCount) {
                                   $('.div_delete').hide();
                                   $(this).find('.div_delete').show();
                                   var cardNo = $(".card_no").val();
//                                   $(this).find('.div_delete').click(function() {
//                                                                     alert("del");
//
//                                                                     var del = window.confirm("确认删除？");
//                                                                     if (del) {
//                                                                     
//                                                                     var postData ={
//                                                                     Lid: orderConfirm.mobileNo,
//                                                                     Ono: cardNo
//                                                                     };
//                                                                     window.fypay.getDeviceInfo("CardManager.deleteCard",postData);
//
//                                                                     } else {
//                                                                     alert("hide left");
//
//                                                                     $('.div_delete').hide();
//                                                                     }
//                                                                     });
                                   //$(this).text("你用" + fingerCount + "个手指以" + duration + "秒的速度向" + direction + "滑动了" + distance + "像素 " + "你在" + phase + "中");
                                   },
                                   swipeRight: function(event, phase, direction, distance, duration, fingerCount) {

                                   $('.div_delete').hide();
                                   }
                                   });
        
        
        
        
        $("#btn_add_card").click(function() {
                                 var params = {mobileNo:orderConfirm.mobileNo};
                                 window.location.href = "card_setup.html?"+$.param(params);
                                 });
        $(".back_btn").bind("click",function() {
                            var template = $('#tmpl_order_info').html();
                            Mustache.parse(template); // optional, speeds up future uses
                            var rendered = Mustache.render(template, data);
                            $('#div_body').html(rendered);
                            orderConfirm.qryOrderDetailInfo();
                            });
        //#是id选择器 .是class选择器
        $("#btn_back_pwd").bind("click", function() {
                                var backPwdParams = {mobileNo:orderConfirm.mobileNo,isBackPwd:"1",cardType:1,title_name:"找回密码"};
                                window.location.href = "pay_pwd_setup.html?"+$.param(backPwdParams);
                                });

        
//
//        $("#bank_list_item").swipe("click", function(){
//                                   swipeLeft: function(event, phase, direction, distance, duration, fingerCount) {
//                                   $('.div_delete').hide();
//                                   $(this).find('.div_delete').show();
//                                   var cardNo = $(this).find(".card_no").val();
//                                   $(this).find('.div_delete').click(function() {
//                                                                     var del = window.confirm("确认删除？");
//                                                                     if (del) {
//                                                                     CardManager.deleteCard(cardNo);
//                                                                     } else {
//                                                                     $('.div_delete').hide();
//                                                                     }
//                                                                     });
//                                   //$(this).text("你用" + fingerCount + "个手指以" + duration + "秒的速度向" + direction + "滑动了" + distance + "像素 " + "你在" + phase + "中");
//                                   },
//                                   swipeRight: function(event, phase, direction, distance, duration, fingerCount) {
//                                   $('.div_delete').hide();
//                                   }
//                                   });
        
        
    },
    
   
    
    getCardType: function(Ctp) {
        switch (Ctp) {
            case 1:
                return "借记卡";
            case 2:
                return "信用卡";
            case 4:
                return "富友卡";
        }
        return "";
    },
        //设置选中的银行卡
    setSelectCard: function(card, mobile) {
//        payOrder.checkedCard = "6227001215050462742";
        payOrder.checkedCard = card;

        payOrder.mobil = mobile;
    },
    signPkey: function() {
        var password = $("#password").val();
        window.fypay.getRSA("payOrder.setPkey", password);
    },
        //设置支付密码--加密后
    setPkey: function(signKey) {
        payOrder.pkey = signKey;
        payOrder.pay();
    },
        //切换选中银行卡
    onBankSelected: function(obj,card, bankphone) {
        var checkId = $(obj).attr("id");
        $(".checkbox_card").each(function() {
                                 if (checkId !== $(this).attr("id")) {
                                 $(this).attr("checked", false);
                                 } else {
                                 $(this).attr("checked", true);
                                 }
                                 });
        payOrder.setSelectCard(card, bankphone);
    },
onBankDelete: function(obj,card, bankphone) {
    
    var del = window.confirm("确认删除？");
    if (del) {
        var postData ={
        Lid: orderConfirm.mobileNo,
        Ono: card
        };
        window.fypay.getDeviceInfo("CardManager.deleteCard",postData);
    } else {
        $('.div_delete').hide();
    }

    
//    val dele = "确认删除？";
//    window.fypay.showNewAlert("payOrder.delCard", dele);


    
},
    
   delCard:function(del)
    {
        
        if (del) {
            var postData ={
            Lid: orderConfirm.mobileNo,
            Ono: card
            };
            window.fypay.getDeviceInfo("CardManager.deleteCard",postData);
        } else {
            $('.div_delete').hide();
        }
        
    },
    verify: function() {
        if(payOrder.checkedCard.length < 1){
            window.fypay.showAlert('请选择支付的卡号');
            return false;
        }
        var password = $("#password").val().trim();
        if (password === '') {
            window.fypay.showAlert('请输入支付密码');
            return false;
        }
        if (password.length < 6) {
            window.fypay.showAlert('支付密码不正确');
            return false;
        }
        if (orderConfirm.needVCode()) {
            var vcode = $("#input_vcode").val().trim();
            if (vcode === '') {
                window.fypay.showAlert('请输入短信验证码');
                return false;
            }
            if (vcode.length < 4) {
                window.fypay.showAlert('短信验证码不正确');
                return false;
            }
        }
        
        return true;
    },
        //支付方法
    pay: function() {
        var postData = {
        Action:'payOrder',
        Lid: orderConfirm.mobileNo,
        OrderId: orderConfirm.orderNo,
        Ono: payOrder.checkedCard,
//        Ono:'6227001215050462742',
        Mno: payOrder.mobil,
        Pkey: payOrder.pkey,
        VerCd : $("#input_vcode").val().trim(),
        TxnTp: '3',
        OkTp: '0',
        OkIdx: '1',
        OkFmt: '1'
        };
        window.fypay.getDeviceInfo("payOrder.fastPay",postData);

//        $.httpPost("fmp/doPay.pay", $.createXML(postData), true, function(data) {
//                   orderConfirm.render(data, false);
//                   }, function(msg) {
//                   window.fypay.showAlert(msg);
//                   });
    },
    
  fastPay:function(postData)
    {
        $.httpPost("fmp/doPay.pay", postData, true, function(data) {
                   orderConfirm.render(data, false);
                   }, function(msg) {
                   window.fypay.showAlert(msg);
                   });
    },
    
    verifyCardPay: function()
    {
        if($.urlParam("Ono").length < 1)
        {
            window.fypay.showAlert('请重新选择支付的卡号');
            return false;
        }
        
        if (orderConfirm.needVCode())
        {
            var vcode = $("#input_vcode").val().trim();
            if (vcode === '') {
                window.fypay.showAlert('请输入短信验证码');
                return false;
            }
            if (vcode.length < 4) {
                window.fypay.showAlert('短信验证码不正确');
                return false;
            }
        }
        
        return true;
    },
        //支付方法
    payWithBankCard: function() {
        
        var postData = {
        VERSION:"2.0" ,
        TYPE:"02" ,
        MCHNTCD:orderConfirm.mchntCd ,
        ORDERID:orderConfirm.orderNo ,
        MCHNTORDERID:orderConfirm.mchntOrderId ,
        USERID:orderConfirm.userId ,
        BANKCARD:orderConfirm.bankCard ,
        VERCD:$("#input_vcode").val() ,
        MOBILE:$("#mobile_no").val() ,
        CVN:'' ,
        SIGNTP:"MD5",
        SIGNPAY:orderConfirm.signPay ,
        VER:"sdk2.1" ,
        REM1:orderConfirm.sdkVersion
        }
//        window.fypay.getDeviceInfo("payOrder.payDataPostRSA",postData);
        payOrder.payDataPostRSA(postData);
    },
    
    
    payDataPostRSA:function(data){

   // window.fypay.getRSA("payOrder.payDataPost",$.createXML(data));
        if(orderConfirm.ctp == "01")
        {
            data.CVN = "" ;
            if(!bindCard.checkCreditUser(true)){
                return;
            }
            window.fypay.addSign_RSA("payOrder.payDataPost",data) ;
        }else if(orderConfirm.ctp == "02")
        {
            data.CVN = $("#card_cvn").val()+$("#card_date").val();
            var cardcvn = $("#card_cvn").val() ;
            if (cardcvn.length !== 3 || cardcvn == "XXX") {
                window.fypay.showAlert("请输入正确的CVN号码");
                return;
            }
            var cardDate = $("#card_date").val();
            if (cardDate.length != 4) {
                window.fypay.showAlert("请输入正确的信用卡有效期");
                return;
            }
            
            if(!bindCard.checkCreditUser(true)){
                return;
            }
            window.fypay.getRSA("payOrder.addCVN", data.CVN);
        }
        
    

},
    
    addCVN:function(eCVN)
    {
        var postData = {
        VERSION:"2.0" ,
        TYPE:"02" ,
        MCHNTCD:orderConfirm.mchntCd ,
        ORDERID:orderConfirm.orderNo ,
        MCHNTORDERID:orderConfirm.mchntOrderId ,
        USERID:orderConfirm.userId ,
        BANKCARD:orderConfirm.bankCard ,
        VERCD:$("#input_vcode").val() ,
        MOBILE:$("#mobile_no").val() ,
        CVN:eCVN,
        SIGNTP:"MD5" ,
        }
        window.fypay.addSign_RSA("payOrder.payDataPost",postData) ;
    },
    payDataPost:function(data){
        
    
        var vcode = $("#input_vcode").val().trim();
        if (vcode.length == 0) {
            window.fypay.showAlert('请输入短信验证码');
            $("#submit_btn").attr('disabled', false);
            return false;
        }
        
        $.httpPost("sdkpay/payAction.pay", data, true, function(dataSuccess) {

                   
                   window.fypay.paySuccess("",dataSuccess);
                   
                   
                   }, function(msg) {
                   
                   $("#submit_btn").attr('disabled', false);
                   
                   if(!msg)
                   {
                   msg = "支付失败！无错误描述";
                   }
                   if(msg.RESPONSECODE=='8143')
                   {
                   window.fypay.showAlert(msg.RESPONSEMSG);
                   }
                   if(msg.RESPONSECODE=='51B3')
                   {
                   window.fypay.showAlert(msg.RESPONSEMSG) ;
                   }
                   else
                   {
                   window.fypay.paySuccess("",msg);
                   }
                   });
    }
    
    
    
    
    
};


var CardManager = {
setDefaultPayCard: function() {
    //设置默认支付接口
    $.httpPost("nocardPay/setDefaultPayCard.pay", {
               Lid: orderConfirm.mobileNo,
               Ono: payOrder.checkedCard
               }, true, function(data) {
               alert('设置成功');
               }, function(msg) {
               alert(msg);
               $("#loading").hide();
               });
},
deleteCard: function(postData) {
    //删除绑定卡
    $.httpPost("nocardPay/delBindCard.pay", postData, true, function(data) {
               payOrder.queryMyBank();
               }, function(msg) {
               window.fypay.showAlert(msg);
               $("#loading").hide();
               });
}
};







