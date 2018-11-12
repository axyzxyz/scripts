echo 备份原yum文件，并安装阿里源，epel源
mkdir /etc/yum.repos.d/bake && mv /etc/yum.repos.d/*repo /etc/yum.repos.d/bake
curl  -sSLf http://mirrors.aliyun.com/repo/Centos-7.repo >/etc/yum.repos.d/Centos-7.repo
sed -i 's/$releasever/7/g'  /etc/yum.repos.d/Centos-7.repo
yum -y install epel-release
yum clean all 
yum makecache

echo 'yum install -y lsof vim telnet lrzsz'
yum install -y lsof vim telnet lrzsz
echo '内核参数优化'
