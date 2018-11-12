echo 备份原yum文件，并安装阿里源，epel源
mkdir -p /etc/yum.repos.d/bake && mv -rf /etc/yum.repos.d/*repo /etc/yum.repos.d/bake
if [ ! -f etc/yum.repos.d/Centos-7.repo ] 
then
	curl  -sSLf http://mirrors.aliyun.com/repo/Centos-7.repo >/etc/yum.repos.d/Centos-7.repo
	sed -i 's/$releasever/7/g'  /etc/yum.repos.d/Centos-7.repo
	yum -y install epel-release
	yum clean all 
	yum makecache
else
	echo aliyun yum file Centos-7.repo is exited
fi

echo 'yum install -y lsof vim telnet lrzsz ntpdate '
yum install -y lsof vim telnet lrzsz ntpdate 
echo '内核参数优化'
base_url='https://raw.githubusercontent.com/a001189/scripts/master/centos_init_update'
if [ `tail /etc/sysctl.conf|grep 'fs.file-max = 6553560'|wc -l` -ge 1 ]
then
	curl  -sSLf $base_url/sysctl.conf >>  /etc/sysctl.conf
	sysctl -p  /etc/sysctl.conf
	curl  -sSLf $base_url/limits.conf >> /etc/security/limits.conf
else
    echo 内核参数已优化，无需重复执行
fi
echo "are you sure install the docker and kubenetes?"
while true
do
	read -p "yes|no[defalut:no]: " check
	[[ -n $check ]] ||check=no
	if [ $check = 'yes' ] || [ $check = 'no' ]
	then break
	fi
done
# docker k8s 部分
if [ $check = 'no' ]
then echo '已选择不安装docker 和k8s；脚本结束，直接退出'
exit 0
fi

if which docker &> /dev/null
then echo docker 已存在无需安装
else
	echo 安装docker-ce yum源，并缓存
	curl -sSLf https://download.docker.com/linux/centos/docker-ce.repo > /etc/yum.repos.d/docker-ce.repo
	yum makecache
	echo "请选择安装的docker版本"
	yum list docker-ce --showduplicates | sort -r|awk '{print $2}'|grep ce|awk -F'.ce' '{print $1}' |tee /tmp/.docker.version
	while true
	do read -p 'version[defalut:17.03.3]:' -t 10 version 
	   [[ -n $version ]] ||version=17.03.3
	   if [ `grep $version /tmp/.docker.version|wc -l` -ge 1 ] && [ $version = `grep $version /tmp/.docker.version|tail -1` ]; 
	   then echo 已选择版本17.03.3
	   break
	   fi
	done
	yum install docker-ce-$version.ce
fi

# kubenetes 部分
curl -sSLf $base_url/kubernetes.repo > /etc/yum.repos.d/kubernetes.repo
yum makecache
echo "请选择安装的k8s组件的版本，推荐1.12.1版本"
yum --showduplicates list kubeadm|grep kubeadm.x86_64|awk '{print $2, $3}'|sort |head -20|tac|tee /tmp/.k8s.version
read -p"version[defalut:1.12.1](仅一次选择机会，错误则为指定版本):" -t 10 version 

