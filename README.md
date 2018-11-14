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

## init_install.sh
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
bash -c "`curl -ssLf https://raw.githubusercontent.com/a001189/scripts/master/init_intall.sh `" -O docker 18.06.1 k8s 1.12.2-0
# 2 同上
curl -ssLf https://raw.githubusercontent.com/a001189/scripts/master/init_intall.sh > init_intall.sh&&bash init_intall.sh docker 18.06.1 k8s 1.12.2-0
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



