#绿色输出函数
green_echo(){
    echo -e "\033[1;32m$@ \033[0m"
}

# # 清楚日志配置，重构
# cat docker-compose.yml|grep -vE "logging:|options|max-size|driver" >2docker-compose.yml

# # log temp
# echo """    logging:
      # driver: json-file
      # options:
        # max-size: 100m"""> log.temp
# ## 重新生成配置
 # awk 'FS="&&" {if($0~/    tty/){print;system("cat log.temp")}else{print}}' 2docker-compose.yml > 3docker-compose.yml

 # ## 生成每个配置文件
 # cat 3docker-compose.yml |awk 'BEGIN{FS="$$"}NR<3{a=a?a"\n"$1:$1;print $1}NR>=3{if($1 ~ /^  \w/){file=substr($1,3);gsub(":","",file);print a > file".yaml"};print >>  file".yaml";}'


 # prom='urc -c /etc/rancher/cli_uat.json' # 程序
 # svc=log  # 服务
 # env=wmy-uat # 环境（服务集合）

# 更新

update_svc(){
# 环境，服务，日期
# 返回10表示镜像不存在，11，为其他错误
env=$1
svc=$2
day=$3

cat $svc.yaml|sed "s/\(image:.*$svc\).*/\1:$day/"| $prom  up  -p -d --upgrade -c --stack $env -f -
info=`$prom ps |grep $env/$svc|grep -E "error|Error|Failed"`
if [ -n "$info" ]
    then  green_echo "更新$svc:$day 失败，报错信息如下(即将回滚):"
          echo $info
          green_echo "回滚服务$svc"
          $prom up -r --stack $env -d -c -f  $svc.yaml
          imageinfo=`echo $info|grep image|grep "not found"`
          if [ -n "$imageinfo" ]
          then echo "10";return 10
          else echo "11";return 11
          fi
    else green_echo 更新$svc:$day 成功.
fi

}

upsvc(){
#环境，服务
env=$1
svc=$2
today=`date +"%Y%m%d"`
yestoday=`date -d "1 day ago" +"%Y%m%d"`
thwoday=`date -d "2 day ago" +"%Y%m%d"`
threeday=`date -d "3 day ago" +"%Y%m%d"`
count=0
for day in $today $yestoday $thwoday $threeday
do
    let count=count+1
    update_svc $env $svc $day
    code=$?
    if [ $code = 10 ]
    then  green_echo $svc:$day镜像不存在，即将尝试前一天镜像
          if [ $count = 4 ] ; then  green_echo "$svc:$day更新失败，已回滚，尝试4次，尝试使用最新镜像latest更新。";update_svc $env $svc "latest";fi
    elif [ $code = 11 ]
    then green_echo 其他原因更新失败，重试一次.
         update_svc $env $svc $day
         if [ $code != 0 ];then green_echo  "$svc:$day更新失败，已回滚，其他原因，终止。";fi
         break
    else break
    fi
done
unset code
}


# uup(){
# cd /root/rancher/uat
# svc=$1 # 服务
# prom='urc -c /etc/rancher/cli_uat.json' # 程序

# }
pup(){
cd /root/rancher/prod
svc=$1 # 服务
prom='rc -c /etc/rancher/cli.json' # 程序
env=wmy-prod
upsvc $env $svc

}


uup(){
cd /root/rancher/uat
env=wmy-uat

temp=`date +"%m月%d日"`
prom='urc -c /etc/rancher/cli_uat.json' # 程序
[[ -f "release.txt" ]] || (echo "date" >release.txt&&$prom ps|awk '{print $3}'|grep wmy|awk 'BEGIN{FS="/"}{print $2}'|sort >>release.txt)
for sv in `echo $@|awk 'BEGIN{RS=",| |\t|，|;|、"}{print}'|grep -v "^$"|awk 'BEGIN{FS="-|_" }{print $NF}'`
do  flag=false
    for svcs in `$prom ps|awk '{print $3}'|grep wmy|awk 'BEGIN{FS="/"}{print $2}'`
    do
        if [ $sv = $svcs ]
        then flag=true
        break
        fi
    done
    if [ "$flag" = "true" ]
    then
        echo $sv >> $temp
        upsvc $env $sv


    else green_echo $sv 不存在请检查
    fi
 done
}


pup(){
cd /root/rancher/prod
env=wmy-prod
temp=`date +"%m月%d日"`
prom='rc -c /etc/rancher/cli.json' # 程序
[[ -f "release.txt" ]] || (echo "date" >release.txt&&$prom ps|awk '{print $3}'|grep wmy|awk 'BEGIN{FS="/"}{print $2}'|sort >>release.txt)
for sv in `echo $@|awk 'BEGIN{RS=",| |\t|，|;|、"}{print}'|grep -v "^$"|awk 'BEGIN{FS="-|_" }{print $NF}'`
do  flag=false
    for svcs in `$prom ps|awk '{print $3}'|grep wmy|awk 'BEGIN{FS="/"}{print $2}'`
    do
        if [ $sv = $svcs ]
        then flag=true
        break
        fi
    done
    if [ "$flag" = "true" ]
    then
        echo $sv >> $temp
        upsvc $env $sv
    else green_echo $sv 不存在请检查
    fi
done
}

