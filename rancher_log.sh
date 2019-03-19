if [ $(basename $0) = 'logu' ]
then rancher='rancher -c /etc/rancher/cli_uat.json'
else
rancher='rancher -c /etc/rancher/cli.json'
fi
# 绿色输出函数
green_echo(){
    echo -e "\033[1;32m$@ \033[0m"
}

# 获得所有服务及对应容器列表
get_svc(){
$rancher  ps -c|tail -n +2|sort -k2|awk '{split($2,a,"-");s=length(a)-1;c=a[s];b[c]=b[c]?b[c]"\033[1;34m|\033[0m"$2:$2;}END{print "服务\t容器列表";for(i in b){print "\033[1;32m"i"\033[0m""\t"b[i]}}'|column -t;
}

get_svc_no_color(){
$rancher  ps -c|tail -n +2|sort -k2|awk '{split($2,a,"-");s=length(a)-1;c=a[s];b[c]=b[c]?b[c]"|"$2:$2;}END{print "服务\t容器列表";for(i in b){print "\033[1;32m"i"\033[0m""\t"b[i]}}'|column -t;
}

# 获得容器列表
get_container(){
    $rancher  ps -c |tail -n +2|sort -k2|awk 'NR>1{print $2}';
}
# 查看日志函数
# 参数1 容器名字
# 参数2 指定查看对应容器日志的最后num行。默认值200
log() {
    line=$2
    [[ -n $line ]] || line=200
    expr $line + 0 &>/dev/null || line=200
    green_echo 查看日志的容器为：$1,最后${line}行
    sleep 1
    cmd="cd /app/logs/&&tail -f -n $line \$(ls -t |head -1)"
    $rancher exec -it $1 sh -c "$cmd"
}

#帮助函数
helps() {
if [ $1 = '-h' ] || [ $1 = '--help' ]
then

green_echo 使用方法：
echo '脚本名 参数1 参数2 (参数1为服务名或具体的容器名) 参数2为整数，即阻塞查询对应容器最后多少行日志。'
echo 'ex1: 脚本名 wechat 300'
echo 'ex1: 脚本名 wmy-prod-wechat-1 '
exit 0
fi

}
# 模糊搜索函数

# 主函数
main(){

name=$1
[[ -n $name ]] && helps $name
[[ -n $name ]] || name='$$$$$^^^^$$$$$'

line=$2
# 直接指定容器时
if [ $(get_container|grep $name |wc -l) -eq 1 ]
then name=$(get_container|grep $name)
     green_echo 指定参数只有一个容器,全名为$name,直接显示日志。
     log $name $line
    exit 0
fi
# 模糊查找
if [ $(get_svc|grep $name|wc -l) -eq 1 ]
then green_echo 即将查询以下服务
     echo -e "服务\t容器列表"
     get_svc_no_color |grep $name|awk  'BEGIN{RS="[|\t ]"}{print}'|grep -v '^$'|awk 'NR==1{print "请该服务"$1"中选取一个容器查看日志";line=0}NR>1{line=line+1;print line"):"$1;system("limit="line)}'
     limit=$(get_container|grep $name|wc -l)
     # 只有一个容器时直接显示
     if [[ $limit = 1 ]]
     then green_echo 该服务对应一个容器，即将查看日志。
          name=$(get_container|grep $name)
     else
        # 多个容器时
        count=1
        while (( count <= 3))
        do ((count=count+1))
            read -p "(默认值1,超时10秒;)请输入对应容器的编号:" -t 10 num
            [[ -n $num ]] || green_echo 输入为空或超时，设定为默认值1
            [[ -n $num ]] || num=1
            if expr $num + 0 &>/dev/null
            then
                if [ $num -ge 1 ] && [  $num -le $limit ]
                then break
                else
                    green_echo 输入编号不在可选范围内,请重新输入。
                fi
            else
                 green_echo 无法识别输入编号，请重新输入
            fi
        done
        # 检测三次输入终止
        [[ -n $num ]] || num=100000
        if [ $num -ge 1 ] && [  $num -le $limit ]
        then name=$(get_container|grep $name|awk 'NR=="'$num'"')
        else
            green_echo '输入错误次数过多(>=3),自动退出'
            exit 1
        fi
    fi
    # 查看日志
    log $name $line

else
    if [ $(get_svc|grep $name|wc -l) -ge 1 ]
    then echo "你查询的是否以下服务或容器(请指定具体的容器名字)"
     get_svc|grep $name
    else echo "未找到相关服务或容器(请指定具体的容器名字)"
        get_svc
    fi
fi
}

main $1 $2