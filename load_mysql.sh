#!/bin/sh
#--------------------------------------------
# 功能：批量导入
#--------------------------------------------
#输入参数判断
#if [ $# != 2 ] ;then
#    echo "you need input two parameter,  first parameter:  input 'message' load message data  input 'alarm' load alarm data two: input time eg:2018-12-25"
#    exit
#fi

#------------------变量设置--------------------------#
#start.sh脚本所在目录
SH_WORKDIR=$(dirname $0)
cd ${SH_WORKDIR}
SH_WORKDIR=`pwd`

#------------------启动--------------------------#
#------------ -判断文件是否存在------------------#
fileNames=""
#判断文件名后缀
for file in $SH_WORKDIR/*; do
	if [ "${file##*.}"x = "txt"x ];then
		fileNames=$file,$fileNames
	fi
done
echo $fileNames
if [ -z $fileNames ] ;then
    echo "$SH_WORKDIR not found txt file"
    exit
fi
filelist=$(echo $fileNames|tr "," "\n")

#组装mysql命令
order_sqlcommand=""
refund_sqlcommand=""
diff_sqlcommand=""
for file in ${filelist[@]}; do
	if [[ $file == *refund_order_info* ]];then
		refund_sqlcommand="load data local infile \"$file\" into table refund_order_info_0074(ACTIVITY_CODE,REQ_SYS,REQ_DATE,REQ_TRANS_ID,REQ_DATE_TIME,UPAY_DATE,UPAY_TRANS_ID,UPAY_DATE_TIME,ORDER_NO,REFUND_FEE,REFUND_REASON,NOTIFY_URL,ORI_ORDER_NO,ORI_REQ_DATE,CUSTOM_PARAM,SETTLE_DATE,RESULT_CODE,RESULT_DESC,PAYMENT_TYPE,ORI_PAY_ORG_TRANS_ID,LAST_UPD_TIME,ACC_NO,APPROVE_STATUS,PAY_TRANS,REFUND_DATE_TIME)"
	fi
	if [[ $file == *order_info* ]];then
		order_sqlcommand="load data local infile \"$file\"  into table order_info(ACTIVITY_CODE,REQ_SYS,REQ_DATE,REQ_DATE_TIME,UPAY_DATE,UPAY_DATE_TIME,UPAY_TRANS_ID,ORDER_NO,BUYER_ID,ID_TYPE,ID_VALUE,HOME_PROV,ORDER_MONEY,PAYMENT,GIFT,MER_ACTIVITY_ID,PAYMENT_TYPE,PAYMENT_LIMIT,PRODUCT_ID,PRODUCT_NAME,PRODUCT_DESC,PRODUCT_URL,NOTIFY_URL,RETURN_URL,CLIENT_IP,CUSTOM_PARAM,WEIXIN_APPID,WEIXIN_OPENID,RESULT_CODE,RESULT_DESC,SETTLE_DATE,LAST_UPD_TIME,REQ_TRANS_ID,PAY_ORG_TRANS_ID,ACC_NO,DEFAULT_BANK,PRODUCT_TYPE,AUTH_CODE,REQ_CHANNEL,BUSINESS_TYPE,CONTRACT_CODE,AREA_BUSINESS_HALL_CODE,BUSINESS_HALL_CODE,BUSINESS_HALL_WINDOW_CODE,TERMINAL_CODE,CLERK_CODE,PAY_TRANS,PAY_DATE_TIME)"
	fi
	if [[ $file == *fullPay_diff* ]];then
		diff_sqlcommand="load data local infile \"$file\" into table fullPay_diff_data(ORDER_NO,BUYER_ID,ORDER_MONEY,PAYMENT,GIFT,REQCHANNEL,PAYMENT_TYPE,PAYMENT_LIMIT,ID_TYPE,ID_VALUE,DIFF_TYPE,SETTLE_DATE,IS_REFUND,RESERVE1,RESERVE2,THIRDPAY_SERVICE_CHARGE_RATE,TRANSACTION_TYPE,SIGNING_PRODUCT,MERCHANT_TYPE,PRODUCTID,PRODUCTNAME,CUSTOMPARAM,ORISETTLEDATE,THEAREACODEFORTHEBUSINESSHALL,THECODEOFTHEBUSINESSHALL,THECODEOFTHEBUSINESSHALLWINDOW,THECODEOFTERMINAL,THECODEOFCLERK,BUSI_TYPE)"
	fi
done

#读取配置文件
while read line;do  
    eval "$line"  
done < $SH_WORKDIR/load_mysql.ini

echo "mysql -h${HOST} -u${USERNAME} -p${PASSWORD} -P${PORT} -${DATEBASE}"
#运行mysql命令
echo "load data start......"
MYSQL="mysql -h${HOST} -u${USERNAME} -p${PASSWORD} -P${PORT}"

${MYSQL}>/dev/null<<EOF
use ${DATEBASE}
${refund_sqlcommand};
${order_sqlcommand};
${diff_sqlcommand};
\q;
EOF
echo "load data finish......"
