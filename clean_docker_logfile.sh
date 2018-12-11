#! /bin/bash
# 判断文件大小 超过100M 返回0
LOG_SIZE(){
f=$1 # 参数1 文件名
sz=$2 # 参数2 文件大小 M为单位 默认100
[[ -n  $sz ]] || sz=100
sz=`echo 1024*1024*$sz|bc` # 默认100M
if [ `du -b $f|awk '{print $1}'` -gt $sz ]
then return 0
else return 1
fi

}

# 清理日志文件大于100M的
LogClean(){

sz=$2 # 参数2 文件大小 M为单位 默认100
[[ -n  $sz ]] || sz=100 
limit_sz=$sz
if [ ! -n $1 ]
then echo the file is not specified
    return 1
fi

#LOG_SIZE $1 $sz && (echo > $1&& echo clenn logfile:$1) ||echo logfile:$1 less than ${sz}M
LOG_SIZE $1 $sz && (echo > $1&& echo clenn logfile:$1) ||echo logfile:$1 less than ${limit_sz}M
}


main(){


for i in `docker ps -a|grep -v rancher|grep -v "CONTAINER ID"|awk '{print $NF}'`;
do  echo clean container \"`docker ps |grep $i|awk '{printf $NF"   "}'` \" logs; 
    LOG_DIR=`docker inspect $i -f '{{.GraphDriver.Data.UpperDir}}'`/app/logs;
    if [ -d $LOG_DIR ] 
    then    for filename in `find $LOG_DIR -name "*log" |xargs -n 1`
            do LogClean $filename 
            done
   
    fi
done

}

date
main
date
