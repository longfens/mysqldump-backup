#!/bin/bash

# Function : mysqldump 定时备份
# Author   : wanglonnglong
# Date     : 2020/6/10

#保存备份个数，备份7天数据
number=7
#备份保存路径
backup_dir=/data/mysqlbackup
#日期
dd=`date +%Y-%m-%d-%H-%M-%S`
#备份工具
tool=mysqldump
#用户名
username=root
#密码
password=root
#将要备份的数据库
database_name=root
#host
host_name=127.0.0.1

#如果文件夹不存在则创建
if [ ! -d $backup_dir ]; 
then     
    mkdir -p $backup_dir; 
fi


a=1
#核心函数，防止中途链接中断，retry 3次
while [ $a -lt 4 ]
do
	start_time=$(date "+%Y-%m-%d %H:%M:%S")
	echo "====开始备份第$a $start_time===="
	#  mysqldump -u root -p123456 users > /root/mysqlbackup/users-$filename.sql
	$tool -h$host_name -u $username -p$password $database_name > $backup_dir/$database_name-$dd.sql
	RC=$?
    if [ $RC -eq "0" ]
    then
       echo "备份成功"
       break
    else
	   #每次失败间隔60s*次数
	   sleep_sum=$(( a * 60 ))
	   sleep $sleep_sum
    fi


    a=`expr $a + 1`
done



end_time=$(date "+%Y-%m-%d %H:%M:%S")

#写创建备份日志
echo "create $backup_dir/$database_name-$dd.sql $start_time->$end_time" >> $backup_dir/log.txt

#找出需要删除的备份
delfile=`ls -l -crt  $backup_dir/*.sql | awk '{print $9 }' | head -1`

#判断现在的备份数量是否大于$number
count=`ls -l -crt  $backup_dir/*.sql | awk '{print $9 }' | wc -l`

if [ $count -gt $number ]
then
  #删除最早生成的备份，只保留number数量的备份
  rm $delfile
  #写删除文件日志
  echo "delete $delfile" >> $backup_dir/log.txt
fi