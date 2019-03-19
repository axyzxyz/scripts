#! /bin/bash
# 配置
log_file=access.log  #解析日志
bake_logfile=`date '+%y-%m-%d'`"."$log_file #备份日志
sqlfile=`date '+%y-%m-%d-%H%M%S'`".sql" #中间sql
sqlerror=sqlerror.txt #错误信息
run_log=sqlrun.txt #脚本运行日志
# sql用户名 studyuser 无密码 只对该ip该库有权限； 更换地址请重新添加用户
sqluser=studyuser
sqlhost=192.168.0.230
sqlport=3306
start_time=`date +%s`
echo `date`"----------------开始----------------" >> $run_log
echo `date` "日志分析，生成sql" >> $run_log


# 第一步逐行输入日志文件到当天日志备份文件（例：accsess_log --->> 2018-04-28.accsess_log) 与之同时匹配请求参数交由管道下一步操作;读取结束后,清空当前文件
# 第二步排除上一步未匹配的空行交由管道下一步操作
# 第三步对参数解析并生成sql文件
awk '{print >> "'$bake_logfile'"; match($0,/.*GET \/heart_check\?(.*session_id.*) HTTP/, a);print a[1]}END{system("echo -n  >"FILENAME)}' $log_file|grep -v "^$"|awk '{printf "INSERT INTO cloud_study.study_log";split($1,a,"&");for(i in a){split(a[i],b,"=");c[b[1]]=b[2]};for(i in c){if(i!="abcabcacbsad"){key=key?key","i:i;c[i]=c[i]?"'\''"c[i]"'\''":"0";value=value?value","c[i]:c[i]}};print "("key") VALUES(" value ");";key=value=None}' |sed "s/'\+/'/g"|sort |uniq > $sqlfile

# 逐行插入sql，并保存错误信息,(因此未整个导入sql文件)

# sql用户名 studyuser 无密码 只对该ip该库有权限； 更换地址请重新添加用户

# 读取文件太大，占用太多内存，改为逐行读取
echo `date` "sql逐行入库" >> $run_loggit
sqlline=`wc -l $sqlfile|awk '{print $1}'`
			# 逐行读取太慢，改为导入文件
			# sqlline=`wc -l $sqlfile|awk '{print $1}'`
			# num=1
			# error_count=0
			# while (( $num <= $sqlline ))
			# do line=` awk 'NR=="'$num'"{print}' $sqlfile`
			# result=`mysql -h$sqlhost -P$sqlport -u$sqluser -e "$line" 2>&1`
				# if [[ $? != 0  ]]
				# then echo  `date`"  error line file $num $sqlfile" >> $sqlerror

					# echo $num $result >> $sqlerror
					# echo $line >> $sqlerror
					# let error_count+=1
				# fi
			# #echo $line
			# let num+=1
			# done
# 导入文件
temperrorlogfile=`cat /dev/urandom |tr -dc '0-9a-zA-Z'|head -c 20`
error_count=`mysql -h$sqlhost -P$sqlport -u$sqluser -f < $sqlfile 2>&1 | tee -a $temperrorlogfile |wc -l|awk '{print $1}'`
if [[ error_count != 0 ]]
	then echo -----------`date`-------------- >> $sqlerror
	echo `date` errorsqlfile info $sqlfile >> $sqlerror
	cat $temperrorlogfile >> $sqlerror
	echo end >> $sqlerror
fi
rm -rf $temperrorlogfile
# 结束
echo `date` "分析完成" >> $run_log
let use_time=`date +%s`-start_time
echo `date` "脚本执行用时${use_time}秒,共计${sqlline}条日志,入库失败条数${error_count}条。" >> $run_log