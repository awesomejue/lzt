/**
 * 判断是否是指定的页面
 * @param {Object} pageName
 */
function isPage(pageName) {
    var uri = window.location.pathname;
    // 计算出点的位置
    var pos = uri.lastIndexOf("/");
    return pageName === uri.substring(pos + 1);
}

/**
 * 对银行卡号加*
 */
function formatCardNo(cardTemp) {
    var card = cardTemp + "";
    if (card.length >= 15 || card.length <= 19) {
        return card.replace(card.substring(6, card.length - 4), '******');
    }
    return card;
}

/**
 * 把以分为单位的类似200000元的金额 格式成2000.00
 *
 * @param yuan
 * @returns
 */
function yuan2Fen(yuan) {
    if (yuan === '0') {
        return '0';
    }
    if(yuan.length <= 2)
    {
        return '0.'+ ((yuan.length >1) ? yuan : (+'0'+yuan));
    }
    return yuan.substring(0, yuan.length - 2) + "." + yuan.substring(yuan.length - 2, yuan.length);
}

function formatDate(datestr) {
    return datestr.substring(0, 4) + "-" + datestr.substring(4, 6) + "-" + datestr.substring(6, 8);
}

var PageManager = {
orderConfirmPage: 'orderConfirmPage',
orderPayPage: 'orderPayPage',
payResultPage: 'payResultPage',
cardMgrPage: 'cardMgrPage',
currentPage: '',
back: function() {
    switch (PageManager.currentPage) {
        case PageManager.orderConfirmPage:
            window.fypay.giveUpPay();
            break;
        case PageManager.orderPayPage:
            orderConfirm.render(orderConfirm.orderInfo, true);
            break;
        case PageManager.payResultPage:
            window.fypay.paySuccess("failure",{"Rcd":"-2","RDesc":"放弃支付"});
            break;
        case PageManager.cardMgrPage:
            window.fypay.exit();
            break;
        default:
            history.back();
            break;
    }
},
setCurrentPage: function(page) {
    PageManager.currentPage = page;
    $("#top_left_back_div").bind("click", function() {
                                 PageManager.back();
                                 });
}
};

//获取短信验证码
var VCODE = {
second: 180,
timer: null,
getVCode: function(phoneNo, mSuccess, mFail) {
    $.httpPost("m12.do", {
               Lid: orderConfirm.mobileNo,
               Mno: phoneNo,
               Status: '1'
               }, true, function(msg) {
               mSuccess(msg);
               }, function(msg) {
               alert(msg);
               });
},
beginTimer: function() {
    VCODE.second--;
    $("#btn_vcode").attr('disabled', true);
    $("#btn_vcode").html(VCODE.second );
    if (VCODE.second === 0) {
        clearInterval(VCODE.timer);
        $("#btn_vcode").html("获取验证码");
        VCODE.second = 180;
        $("#btn_vcode").attr('disabled', false);
    }
}
};

// ################### IDCARD util begin ############################

var Wi = [ 7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2, 1 ];    // 加权因子
var ValideCode = [ 1, 0, 10, 9, 8, 7, 6, 5, 4, 3, 2 ];            // 身份证验证位值.10代表X
function IdCardValidate(idCard) {
    idCard = trim(idCard.replace(/ /g, ""));               // 去掉字符串头尾空格
    if (idCard.length === 15) {
        return isValidityBrithBy15IdCard(idCard);       // 进行15位身份证的验证
    } else if (idCard.length === 18) {
        var a_idCard = idCard.split("");                // 得到身份证数组
        if(isValidityBrithBy18IdCard(idCard)&&isTrueValidateCodeBy18IdCard(a_idCard)){   // 进行18位身份证的基本验证和第18位的验证
            return true;
        }else {
            return false;
        }
    } else {
        return false;
    }
}
/**
 * 判断身份证号码为18位时最后的验证位是否正确
 *
 * @param a_idCard
 *            身份证号码数组
 * @return
 */
function isTrueValidateCodeBy18IdCard(a_idCard) {
    var sum = 0;                             // 声明加权求和变量
    if (a_idCard[17].toLowerCase() == 'x') {
        a_idCard[17] = 10;                    // 将最后位为x的验证码替换为10方便后续操作
    }
    for ( var i = 0; i < 17; i++) {
        sum += Wi[i] * a_idCard[i];            // 加权求和
    }
    valCodePosition = sum % 11;                // 得到验证码所位置
    if (a_idCard[17] == ValideCode[valCodePosition]) {
        return true;
    } else {
        return false;
    }
}
/**
 * 验证18位数身份证号码中的生日是否是有效生日
 *
 * @param idCard
 *            18位书身份证字符串
 * @return
 */
function isValidityBrithBy18IdCard(idCard18){
    var year =  idCard18.substring(6,10);
    var month = idCard18.substring(10,12);
    var day = idCard18.substring(12,14);
    var temp_date = new Date(year,parseFloat(month)-1,parseFloat(day));
    // 这里用getFullYear()获取年份，避免千年虫问题
    if(temp_date.getFullYear()!==parseFloat(year) || temp_date.getMonth()!==parseFloat(month)-1 || temp_date.getDate()!==parseFloat(day)){
        return false;
    }else{
        return true;
    }
}
/**
 * 验证15位数身份证号码中的生日是否是有效生日
 *
 * @param idCard15
 *            15位书身份证字符串
 * @return
 */
function isValidityBrithBy15IdCard(idCard15){
    var year =  idCard15.substring(6,8);
    var month = idCard15.substring(8,10);
    var day = idCard15.substring(10,12);
    var temp_date = new Date(year,parseFloat(month)-1,parseFloat(day));
    // 对于老身份证中的你年龄则不需考虑千年虫问题而使用getYear()方法
    if(temp_date.getYear()!==parseFloat(year) ||temp_date.getMonth()!==parseFloat(month)-1 ||temp_date.getDate()!==parseFloat(day)){
        return false;
    }else{
        return true;
    }
}

// 去掉字符串头尾空格
function trim(str) {
    return str.replace(/(^\s*)|(\s*$)/g, "");
}