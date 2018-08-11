var TEST ;
var URL_PREFIX ;

$.extend({
	urlParam: function(name) {
		name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
		var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
			results = regex.exec(location.search);
		return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
	},
	createLoadingTip: function() {
		var opts = {
			lines: 9,
			length: 0,
			width: 6,
			radius: 12,
			corners: 1,
			rotate: 0,
			direction: 1,
			color: '#4c4a4a',
			speed: 1,
			trail: 85,
			shadow: false,
			hwaccel: false,
			className: 'spinner',
			zIndex: 29,
			top: '50%',
			left: '50%'
		};
		var spinner = new Spinner(opts); //实例化loading图案
		var target = $("#loading").get(0);
		spinner.spin(target);
		return spinner;
	},
	createXML: function(data) {
		var xmlStr = "";
		for (var propertyName in data) {
			if (data.hasOwnProperty(propertyName)) {
				if (typeof propertyName !== 'function') {
                              xmlStr += ("<" + propertyName + ">" + data[propertyName] + "</" + propertyName + ">");
				}
			}
		}
        console.info(xmlStr);
		return "<REQUEST>" + xmlStr + "</REQUEST>";
	},
	testAssign : function(test){
		TEST = test ;
                              //商户测试和生产环境
		URL_PREFIX = TEST ? "http://www-1.fuiou.com:18670/mobile_pay/" : "https://mpay.fuiou.com:16128/";
                              //内网测试和生产环境
//        URL_PREFIX = TEST ? "http://192.168.8.29:29024/mobile_pay/" : "https://mpay.fuiou.com:16128/";
	} ,
	httpPost: function httpPost(url, data, hud, success, failed) {
		var spinner = $.createLoadingTip();
		//console.info(this.createXML(data));
		return $.ajax({
			url: URL_PREFIX + url,
			contentType: "application/x-www-form-urlencoded;charset=utf-8",
			type: "POST",
			data: {

				FMS: data,
//                FM: data
                //FM: this.(data)
			},
			dataType: "text",
			async: true,
			crossDomain: true,
			xhrFields: {
				withCredentials: false
			},
			success: function(msg){
                console.log(msg);
				var myJsonObject = $.xml2json(msg);
				console.info(JSON.stringify(myJsonObject));
				if (myJsonObject.RESPONSE.RESPONSECODE === '0000') {
					success(myJsonObject.RESPONSE);
				} else {
					failed(myJsonObject.RESPONSE);
				}
			},
			timeout: 60000,
			error: function(XMLHttpRequest, textStatus, errorThrown) {
				failed("请求失败,网络不给力!");
				console.log("XMLHttpRequest:" + XMLHttpRequest.status + "||XMLHttpRequest.readyState:" + XMLHttpRequest.readyState + "||textStatus:" + textStatus + "||errorThrown:" + errorThrown);
			},
			beforeSend: function(xhr) {
				if (hud) {
					var target = $("#loading").get(0);
					spinner.spin(target);
				}
			},
			complete: function() {
				if (hud) {
					spinner.spin();
					$('.loading').hide();
				}
			}
		});
	}
});
