# 绿色输出函数
green_echo(){
    echo -e "\033[1;32m$@ \033[0m"
}

# 1.请配置 git-repo地址,http协议请带用户名密码，ssh协议请在仓库加入认证秘钥
#并在阿里云镜像仓库库服务配置了自动构建镜像
git_repo="https://yuesjgo:123qazBNM@github.com/yuesjgo/dockerfiles.git" # 与镜像构建相关的代码仓库https
# git_repo="git@github.com:a001189/dockerfile-bulid.git"   # 与镜像构建相关的代码仓库（阿里云的代码仓库不稳定，勿用）
docker_repo="registry.cn-shanghai.aliyuncs.com/ysj/googleimages" # 阿里自动构想镜像仓库
# 修改上述两个变量为自己私有的仓库，即可实现私有化。


# 检查软件依赖
which git &>/dev/null || { green_echo "无法找到git，退出" && exit 1; }
which docker &>/dev/null || { green_echo "无法找到docker，退出" && exit 1; }
{ which base64 &>/dev/null || which md5sum &>/dev/null ;} || { green_echo "无法找到base64或md5sum，退出" && exit 1; }


image=$1
if [ "$image" = "" ]; then green_echo 请指定要下载的镜像，包含标签;exit 1;fi
green_echo 开始构建并拉取镜像 $image
#编码image
if { base64 --version &>/dev/null && base64 --version|head -n 1;} 
then 
    image_id=`echo -n $image|base64 |sed 's/=//g'`
else
    green_echo warning:依赖base64,无该命令,使用MD5
    image_id=`echo -n $image|md5sum|cut -f 1 -d ' '`
fi
image_id=$image_id`date +_%Y%m%d_%H%M%S`
BASEDIR=`pwd`
tmpdir=tmp`date +_%Y%m%d_%H%M%S`
green_echo "创建临时目录$tmpdir "
mkdir $tmpdir && cd $tmpdir
git_dir=`basename $git_repo|awk -F. '{print $1}'`
git clone $git_repo
cd $git_dir
git config --local user.name "a001189"
git config --local user.email "479100885@qq.com"

echo "From $image" > Dockerfile
echo "Maintainer 479100885@qq.com" >> Dockerfile


git add .
git commit -m "image_id:$image_id"
git tag -f release-v$image_id
git push --tags -u origin master
green_echo 删除项目及临时目录
cd $BASEDIR && rm -rf $tmpdir
green_echo 探测临时构建镜像是否成功
count=1
while true
do 
let times=count*7
let count=count+1
# 超过半小时退出
if [[ $times -gt 1800 ]] ;then green_echo 构建时间已超过半小时，请检查原因， 或在等待一段时间，执行以下命令
    green_echo ------------------------
    echo docker pull $docker_repo:$image_id 
    echo docker tag $docker_repo:$image_id $image
    echo docker rmi $docker_repo:$image_id
    green_echo ------------------------
    break

fi
# 检测
docker pull $docker_repo:$image_id || { green_echo 临时镜像未构建成功，等待$times 秒;sleep $times;continue;}
green_echo 还原镜像标签
docker tag $docker_repo:$image_id $image
docker rmi $docker_repo:$image_id
green_echo $image' pull success!!!'
break
done
