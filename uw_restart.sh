#!/bin/sh
###############################
#Author : ss
#date   : 2016年10月20日14:54:37
ps -ef |grep /var/log/uwsgilog/uwsgi-server.log  |awk '{print $2}' |xargs kill
sleep 5
/usr/local/bin/uwsgi --emperor /var/www/config -d /var/log/uwsgilog/uwsgi-server.log
if [ $? -eq 0 ];then
        echo  "uwsgi 强制重启成功 !!!"
else
        echo  "uwsgi 启动失败，请联系沈硕"
fi
