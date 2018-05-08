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
