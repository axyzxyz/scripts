#! /bin/bash

SERVER_NUM=3 # keepalived 集群个数
if [ -f 'cluster_info.sh' ] 
then 
    echo 'are you sure use the cluster info?'
    cat cluster_info.sh
    echo
    read -p '[yes|no]' -t 60 check
    [[ -n $check ]] || check=no
    if [ $check != 'yes' ]
        then
        echo 已选择取消，自动退出。
        exit 0
    else
        source cluster_info.sh
    fi
else 
    CP0_IP=$1
    CP1_IP=$2
    CP1_IP=$3
    LOAD_BALANCER_DNS=$4
    interface=$5
    if [[ ! -n interface ]]  
        then 
        echo 无配置文件，请依次指定 集群 IP1 IP2 IP3 VIP 网卡 五个参数
        echo 或者使用配置 配置文件内容如下：
        curl -sSLf https://raw.githubusercontent.com/a001189/scripts/master/keepalived_config/cluster_info.sh > cluster_info.sh
        请自行修改'cluster_info.sh' 各项配置
        exit 0 
    fi

fi
IPS=(${CP0_IP} ${CP1_IP} ${CP2_IP})
green_echo(){
    echo -e "\033[1;32m$@ \033[0m"
}
green_echo "#1: keepalived config "

index=0
keepalived_config
curl -sSLf https://raw.githubusercontent.com/a001189/scripts/master/keepalived_config/keepalived.conf.sed > keepalived.conf.sed 
while ((index<$SERVER_NUM));  
do 
let priority=100-$index*10;
    NodeIP=${IPS[${index}]};
    NodeIP=${NodeIPS[${index}]};
    ID=10;   
    sed  "s@#ID@$ID@;s@#priority@$priority@;s@#NodeIP@$NodeIP@;s@CP0_IP@$CP0_IP@;s@CP1_IP@$CP1_IP@;s@CP2_IP@$CP2_IP@;s@##$NodeIP@#$NodeIP@;s@##@@;s@LOAD_BALANCER_DNS@$LOAD_BALANCER_DNS@;s@#interface@$interface@;s/#.*//" keepalived.conf.sed > $NodeIP.keepalived.conf;
    scp $NodeIP.keepalived.conf $NodeIP:/etc/keepalived/keepalived.conf ; 
    checkScript='/etc/keepalived/keepalived-k8s.sh'
    if [ -f '/etc/keepalived/keepalived-k8s.sh' ]
        then echo 存活检测脚本'/etc/keepalived/keepalived-k8s.sh'已存在，使用该检测脚本的使用
    else
        echo 存活检测脚本'/etc/keepalived/keepalived-k8s.sh'不存在，自定义脚本请自行修改此文件，重新执行该脚本
        curl -sSLf https://raw.githubusercontent.com/a001189/scripts/master/keepalived_config/keepalived-k8s.sh >$checkScript 
    fi
    chmod +x $checkScript
    scp $checkScript $NodeIP:$checkScript
    # 修改keepalived日志位置
    ssh $NodeIP "cp -n /etc/sysconfig/keepalived /etc/sysconfig/keepalived-bake"
    sed -i 's/KEEPALIVED_OPTIONS.*/KEEPALIVED_OPTIONS="-D -d -S 0"/' /etc/sysconfig/keepalived
    scp /etc/sysconfig/keepalived $NodeIP:/etc/sysconfig/keepalived
    ssh $NodeIP "test  `grep 'local0\.\*' /etc/rsyslog.conf |wc -l ` -gt 0 ||  && echo 'local0.*       /var/log/keepalived.log' >> /etc/rsyslog.conf "
    echo "添加keepalived日志路径：/var/log/keepalived.log"
    ssh $NodeIP "systemctl restart rsyslog && systemctl restart keepalived"; 
    let index=index+1; 
done