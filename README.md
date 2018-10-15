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
