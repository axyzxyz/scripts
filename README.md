# scripts
一些常用软件配置

## thread.sh
Linux多进程(线程)执行脚本；
自动解析脚本或命令中的for循环，并按照指定线程并行运行，未考虑线程间的数据交换，默认线程之前想好独立；
使用方法：
```bash
#命令方法
sh thread.sh 4 'for i in {1..100};do echo $i;sleep 3;done'
#脚本方式
sh thread.sh 4 forfile.sh
```
ps:
  centos下可直接使用，
  ubantu下请将sh 改为bash 或者重新编译解释器，否则不支持 {1..100} 这种数组扩展应用
## log_to_sql.sh
使用awk解析日志记录参数，并转化为sql，然后导入数据库,使用方法请看脚本注释，需保证日志参数与数据库字段一致。实测5M日志，3000条结果导入只需1秒
```bash
sh sql_to_log.sh
```
## vpn.bat

 vpn 自动连接脚本， 使用前请去掉vpn适配器的远程网关，并设置用户名密码vpn名称
## keep_two_file.sh
  保留一批对象中最后的三个的awk脚本（参考），及查找7天前的目录
## rancher_log.sh 借助rancher api 进行日志查询功能
```bash
green_echo 使用方法：
echo '脚本名 参数1 参数2 (参数1为服务名或具体的容器名) 参数2为整数，即阻塞查询对应容器最后多少行日志。'
echo 'ex1: 脚本名 wechat 300'
echo 'ex1: 脚本名 wmy-prod-wechat-1 '
exit 0
#示例：

[root@wmy-sit prod]# log student
即将查询以下服务
服务	容器列表
请该服务student中选取一个容器查看日志
1):wmy-prod-student-1
2):wmy-prod-student-2
(默认值1,超时10秒;)请输入对应容器的编号:输入为空或超时，设定为默认值1
查看日志的容器为：wmy-prod-student-1,最后200行
	at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:166)
```
## docker_log.sh
和上述查看日志方式一样，查看容器内特定文件的读写。
## upsvc_rancher.sh
rancher api 自动更新服务的脚本，抛弃可视化操作。
## kube-short.sh
kubernetes kubectl 简化命令脚本

## init_install.sh centos系统初始化优化
* use:
```bash
# 直接执行，然后选择是否安装docker k8s
# 1
bash -c "`curl -ssLf https://raw.githubusercontent.com/a001189/scripts/master/init_intall.sh `" 
# 2 同上
curl -ssLf https://raw.githubusercontent.com/a001189/scripts/master/init_intall.sh > init_intall.sh&&bash init_intall.sh

# 直接指定docker k8s 及其版本
# 限定第一个参数必须是`docker`，(不是则跳过此步骤，不存在则等同于上述方式，输入yes|no选择),执行docker 安装， 第二个参数为对应版本，找不到版本则安装默认版本（已存在docker 将跳过安装）
# 限定第三个参数必须是`k8s`，(不是则跳过此步骤，不存在则等同于上述方式),执行k8s组件 安装， 第四个参数为对应版本，找不到版本则安装默认版本（已存在删除重装）
# 1
bash -c "`curl -ssLf https://raw.githubusercontent.com/a001189/scripts/master/init_intall.sh `" -O docker 18.06.1 k8s 1.11.4-0
# 2 同上
curl -ssLf https://raw.githubusercontent.com/a001189/scripts/master/init_intall.sh > init_intall.sh&&bash init_intall.sh docker 18.06.1 k8s 1.11.4-0
```
更多版本请使用 以下命令查看：
```bash
# docker
yum list docker-ce --showduplicates

yum install docker-ce-$version.ce
# k8s
yum --showduplicates list kubeadm

yum install -y kubeadm-$version kubelet-$version kubectl-$version
```

> docker version（默认版本17.03.3） :

-  18.06.1 
-  18.06.1 
-  18.06.0 
-  18.03.1 
-  18.03.0 
-  17.12.1 
-  17.12.0 
-  17.09.1 
-  17.09.0 
-  17.06.2 
-  17.06.1 
-  17.06.0 
-  17.03.3 
-  17.03.2 
-  17.03.1 
-  17.03.0 

> k8s 组件 版本（默认版本1.11.4-0）：

-  1.12.2-0
-  1.12.1-0
-  1.12.0-0
-  1.11.4-0
-  1.11.3-0
-  1.11.2-0
-  1.11.1-0
-  1.11.0-0
-  1.10.9-0
-  1.10.8-0
-  1.10.7-0
-  1.10.6-0
-  1.10.5-0 
-  1.10.4-0
-  1.10.3-0
-  1.10.2-0
-  1.10.1-0
-  1.10.0-0


## keepalived_install.sh

* 一键配置keepalived config
```bash
curl -sSLf https://raw.githubusercontent.com/a001189/scripts/master/keepalived_install.sh>keepalived_install.sh&& bash keepalived_install.sh IP1 IP2 IP3 VIP `网卡`
```
## mysql-rsync.sh
单表同步到另一个库的脚本

## clean_docker_logfile.sh
清理容器中特定过大的文件
```
# 检测file是否大于100M；为真返回0状态码，否则为1
LOG_SIZE file 100
# 清理 大于100M 的file 并打印文件名
LogClean file 100
``
## imagepull.sh
利用阿里云镜像自动构建功能，拉取海外镜像
参数1必填为需要拉取的镜像包含标签
```bash
# 1 方法1
bash -c "`curl -ssLf https://raw.githubusercontent.com/a001189/scripts/master/imagepull.sh `" -O  ${IMAGE:TAG}
# 2 方法2
curl -ssLf https://raw.githubusercontent.com/a001189/scripts/master/imagepull.sh > imagepull.sh&&bash imagepull.sh ${IMAGE:TAG}

```
