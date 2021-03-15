#!/bin/sh


#--------------------------------------------
# 功能：启动核心项目batch-refund.jar
#--------------------------------------------


#输入参数判断
if [ ! -n "$1" ] ;then
    echo "you have not input a script param! you can input such as:'sh start.sh prod' or 'sh start.sh test' or 'sh start.sh dev'"
    exit
fi

#------------------变量设置--------------------------#
#项目jar
PROJECT_NAME="batch-refund.jar"
#springboot applications文件名
APPLOCATION_PROPERTIES="application-$1.properties"
#start.sh脚本所在目录
SH_WORKDIR=$(dirname $0)
cd ${SH_WORKDIR}
SH_WORKDIR=`pwd`
#owncharge.jar路径
PROJECT_JAR_PATH="${SH_WORKDIR}/lib/${PROJECT_NAME}"
#conf路径
PROJECT_CONF_PATH="${SH_WORKDIR}/conf/${APPLOCATION_PROPERTIES}"
#启动log
START_APPEND_LOG="${SH_WORKDIR}/start_out.log"


#------------------启动--------------------------#
#------------ -判断文件是否存在------------------#
if [ ! -f "$PROJECT_CONF_PATH" ]; then
 echo "${APPLOCATION_PROPERTIES} dont't exist! "
 exit
fi

echo "you will start server with properties file:'application-$1.properties'"
echo "please waiting ...."

#stop server关闭进程
PIDS=(`ps -ef|grep ${PROJECT_NAME}|grep -v grep|awk {'print $2'}`)
if [[ ${PIDS} ]] ;then
   for s in ${PIDS[@]}
   do
      kill -9 $s
   done
fi


#启动项目
nohup nice java -d64 -server -Xms256m -Xmx2048m -XX:-DisableExplicitGC -XX:+UseG1GC -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:logs/gc.log -XX:+HeapDumpOnOutOfMemoryError -XX:CompileThreshold=1500 -jar -Dspring.config.location=${PROJECT_CONF_PATH}  ${PROJECT_JAR_PATH} > ${START_APPEND_LOG} 2>&1 &

#等待server启动时间
sleep 20

echo "batch-refund server's process:"
echo `ps -ef | grep ${PROJECT_NAME} |grep -v grep`

if [ $? -ne 0 ] ;then
  echo "batch-refund  server start fail....."
  exit 3
else
  echo "batch-refund  server start success....."
fi
