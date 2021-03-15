#!/bin/sh
###########################
#Using the spool command of Oracle to export the data of the Oracle database to the file
###########################

#check up the number of parameter for the shell
if [ $# -ne 2 ];then
	echo "the number of parmeter is $#:error your need input two parmeter  one parameter input eg: order or refund or diff,  two parameter eg:NLS_LANG=AMERICAN_AMERICA.AL32UTF8
"
	exit 1
fi

#脚本所在目录
SH_WORKDIR=$(dirname $0)
cd ${SH_WORKDIR}
SH_WORKDIR=`pwd`
SYS_DATE=`date +%Y%m%d`
#读取配置文件
while read line;do  
    eval "$line"  
done < $SH_WORKDIR/export_oracle.ini

#参数: 连接串 -文件- 查询SQL- 行长度-编码格式
SQLPLUS="sqlplus ${USERNAME}/${PASSWORD}@//${HOST}/${SID}:${PORT}"

EXPORT_SQL=""
#FILE=""
if [ $1 == 'order' ]; then
	EXPORT_SQL=${SH_WORKDIR}/export_order_info.sql
#	FILE="order_info_${SYS_DATE}.txt"
elif [ $1 == 'refund' ]; then
	EXPORT_SQL=${SH_WORKDIR}/export_refund_order_info.sql
#	FILE="refund_order_info_${SYS_DATE}.txt"
else
	EXPORT_SQL=${SH_WORKDIR}/export_fullPay_diff_data.sql
#	FILE="fullpay_diff_${SYS_DATE}.txt"
fi

#sql=$3
#line_size=$4
charset=$2

#export $2
#SELECT MAX(col_len) FROM (SELECT LENGTHB(cols) AS col_len FROM (${EXPORT_SQL}));
#run sql function	
export ${charset}
LENGHT=`${SQLPLUS} <<EOF
set heading off feedback off pagesize 0 verify off echo off
SELECT MAX(col_len) FROM (SELECT LENGTHB(cols) AS col_len FROM (${EXPORT_SQL}));
exit
EOF`
#function to use spool export data to file
spool(){
echo ${SQLPLUS}
#echo '行长值为:$lineLen'
${SQLPLUS}>/dev/null<<EOF
@${EXPORT_SQL} ${START_TIME} ${END_TIME};
exit
EOF
}
#Check the oracle database connection
#lineLen=`runSql "${SQLCMD}"`
#if [ ! "${SQLOUT}" = "X" ] ; then
#	echo "error:Could not get the max length of query result for spool linesize. errorInfo:${SQLOUT}"
#	exit 2
#fi 
#run the spool function

echo "begin spool......"
spool
echo "end spool......"
