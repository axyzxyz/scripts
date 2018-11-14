#! /bin/bash
# 绿色输出函数
green_echo(){
    echo -e "\033[1;32m$@ \033[0m"
}
green_echo "#1: keepalived config "

if [[ -n "$1" ]] 
then
    if [ $1 = 'docker' ]
    then check=yes
    else
        check=no
    fi
fi

if [[ -n "$3" ]] 
then 
    if [ $3 = 'k8s' ]
    then check2=yes
    else
        check2=no
    fi
fi

green_echo 备份原yum文件，并安装阿里源，epel源
if [ ! -f /etc/yum.repos.d/Centos-7.repo ] 
then
    mkdir -p /etc/yum.repos.d/bake && \mv  /etc/yum.repos.d/*repo /etc/yum.repos.d/bake
    curl  -sSLf http://mirrors.aliyun.com/repo/Centos-7.repo >/etc/yum.repos.d/Centos-7.repo
    sed -i 's/$releasever/7/g'  /etc/yum.repos.d/Centos-7.repo
else
    green_echo aliyun yum file Centos-7.repo is exited
fi
yum -y install epel-release
yum clean all 
yum makecache
green_echo 'yum install -y lsof vim telnet lrzsz ntpdate '
yum install -y lsof vim telnet lrzsz ntpdate 
green_echo '内核参数优化'
base_url='https://raw.githubusercontent.com/a001189/scripts/master/centos_init_update'
if [ `tail /etc/sysctl.conf|grep 'fs.file-max = 6553560'|wc -l` -ge 1 ]
then
    green_echo 内核参数已优化，无需重复执行
else
    
    curl  -sSLf $base_url/sysctl.conf >>  /etc/sysctl.conf
    sysctl -p  /etc/sysctl.conf
    curl  -sSLf $base_url/limits.conf >> /etc/security/limits.conf
fi
green_echo "are you sure install the docker?"

while true
do
    [[ -n $check ]] ||read -p "yes|no[defalut:no]: " check
    [[ -n $check ]] ||check=no
    if [ $check = 'yes' ]
    then green_echo '已选择安装docker'
        if which docker &> /dev/null
        then green_echo docker 已存在，升降级安装可能不可预知问题，自动跳过
        else
            green_echo 安装docker-ce yum源，并缓存
            curl -sSLf https://download.docker.com/linux/centos/docker-ce.repo > /etc/yum.repos.d/docker-ce.repo
            yum makecache
            green_echo "请选择安装的docker版本"
            yum list docker-ce --showduplicates | sort -r|awk '{print $2}'|grep ce|awk -F'.ce' '{print $1}' |tee /tmp/.docker.version
            version=$2
            [[ -n $version ]] ||read -p 'version[defalut:17.03.3]:' -t 10 version 
            [[ -n $version ]] ||version=17.03.3
            if [ `grep $version /tmp/.docker.version|wc -l` -eq 1 ] && [ $version = `grep $version /tmp/.docker.version|tail -1` ]; 
            then green_echo 已选择版本：$version
            else
                version=17.03.3
            fi
            yum install docker-ce-$version.ce
        fi
    break
    fi

    if [ $check = 'no' ]
    then green_echo '已选择不安装docker' 
    break
    fi
done




# kubenetes 部分
green_echo "are you sure install the kubenetes components?"

while true
do
    [[ -n $check2 ]] ||read -p "yes|no[defalut:no]: " check2
    [[ -n $check2 ]] ||check2=no
    if [ $check2 = 'yes' ]
    then green_echo '已选择安装the kubenetes components'
        curl -sSLf $base_url/kubernetes.repo > /etc/yum.repos.d/kubernetes.repo
        yum makecache
        green_echo "请选择安装的k8s组件的版本，推荐1.11.4-0版本"
        version=$4
        yum --showduplicates list kubeadm|grep kubeadm.x86_64|awk '{print $2, $3}'|sort |head -20|tac|tee /tmp/.k8s.version
        [[ -n $version ]] ||read -p"version[defalut:1.11.4-0](仅一次选择机会，错误则为默认版本):" -t 120 version 
        [[ -n $version ]] ||version=1.11.4-0
        if [ `grep $version /tmp/.k8s.version|wc -l` -eq 1 ] && [ $version = `grep $version /tmp/.k8s.version|tail -1|awk '{print $1}'` ]
        then 
            green_echo "k8s components version: $version"
        else 
            green_echo "k8s components version is wrong ,use the version:$version"
            version=1.11.4-0
        fi

        yum remove -y kubeadm kubelet kubectl
        yum install -y kubeadm-$version kubelet-$version kubectl-$version
        systemctl enable kubelet

        break
    fi
    if [ $check2 = 'no' ]
    
    then green_echo '已选择不安装k8s；脚本结束，直接退出' 
    exit 0
    fi
done

green_echo 'finished !!!!!!'
