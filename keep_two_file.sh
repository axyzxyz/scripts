# 参考，保留一批文件中最新三个文件
cd /var/www/backup&&ls|sort -r|awk '{split($1, x, /\.[0-9]{8}_/);y=x[1];num[y]++;b[y,num[y]]=$1;c[y,num[y]]=num[y]}END{for(i in c){if(c[i]<3){continue};print b[i]}}'|xargs rm -rf
# 查找七天前的文件，并删除
find /var/log/nginx/heart_check/ -mtime +7 -name "*log" -or -name "*sql" -mtime +7