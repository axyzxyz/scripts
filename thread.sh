#!/bin/bash
echo '直接执行for循环命令时，如果有调用$变量，请用单引号包含整个命令语句作为第二个参数'
([[ -n "$1" ]]&&[[ -n "$2" ]]) ||( echo """usage: sh thread.sh n<threadnum> filename.sh<bash for sh file>
ps: thread 指定线程数
note:本脚本自动多进程for循环,命令请用''包裹作为第二个参数
两个参数为必填参数
""")
if [[ ! -n $2 ]] ;then echo '缺少参数程序退出'&&exit;fi
num="$1"
echo "线程数$num, 开始组装多线程版本中间脚本文件"
start_time=`date +%s`  #定义脚本运行的开始时间
[[ -n $num ]] || num=5
sh_file="$2"
echo "$sh_file"
temp_file=`cat /dev/urandom |tr -dc '0-9a-zA-Z'|head -c 20 `.sh
echo """
[ -e /tmp/tmp_tmp_fd1 ] && rm -rf /tmp/tmp_tmp_fd1 && mkfifo /tmp/tmp_tmp_fd1 || mkfifo /tmp/tmp_tmp_fd1 #创建有名管道
exec 3<>/tmp/tmp_tmp_fd1                   #创建文件描述符，以可读（<）可写（>）的方式关联管道文件，这时候文件描述符3就有了有名管道文件的所有特性
rm -rf /tmp/tmp_tmp_fd1                    #关联后的文件描述符拥有管道文件的所有特性,所以这时候管道文件可以删除，我们留下文件描述符来用就可以了
for ((i=1;i<=$num;i++))
do
        echo >&3                   #&3代表引用文件描述符3，这条命令代表往管道里面放入了一个"令牌"
done
 """ > $temp_file
if [[ -f $sh_file ]]
 then
    sed  's/do\($\| \)/do read -u3 ;{ /g' $sh_file|sed 's/done/echo >\&3\n}\&\ndone\nwait/g' >> $temp_file
else
    echo "$sh_file" |sed  's/do\($\| \)/do read -u3 ;{ /g'|sed 's/done/echo >\&3\n}\&\ndone\nwait/g' >> $temp_file
fi
echo """
exec 3<&-                       #关闭文件描述符的读
exec 3>&-                       #关闭文件描述符的写
""" >> $temp_file
echo "组装完成，开始执行"
bash $temp_file
#rm -rf $temp_file
stop_time=`date +%s`  #定义脚本运行的结束时间
echo "总用时-TIME:`expr $stop_time - $start_time`"
echo "删除中间脚本文件，执行完成"
