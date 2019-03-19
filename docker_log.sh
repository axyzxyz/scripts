#! /bin/bash
# 和rancher接口配套，显现用法一致。
green_echo(){
    echo -e "\033[1;32m$@ \033[0m"
}
logsits() {
    line=$2
    [[ -n $line ]] || line=200
    expr $line + 0 &>/dev/null || line=200
    green_echo 查看日志的容器为：$1,最后${line}行
    sleep 1
    cmd="cd /app/logs/&&tail -f -n $line \$(ls -t |head -1)"
    docker exec -it $1 sh -c "$cmd"
}
logs(){ num=$2;[[ ! -n $num ]]&&num=200;green_echo "测试环境(2秒后显示)查看的服务(容器为$1),最后${num}行日志";sleep 2;(logsits $1 $2) 2>/dev/null || (echo 'usege logs 参数1<容器名字(服务名),必选> 参数2<最后几行，默认200;可选>' && echo && docker ps -a|grep 192.168.0.240|awk 'BEGIN{print "测试环境服务名如下"}{print $NF}' ); }
