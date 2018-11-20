# 待同步库
db_user=
password=
host=
# 待更新库
bake_db_user=
bake_password=
bake_host=
# 库名
database=
表名
tb=

mysql -h$bake_host -u$bake_db_user -p$bake_password $database -e "DROP TABLE IF EXISTS $tb" 2>/dev/null
mysqldump -h$host -u$db_user -p$password --databases $database --tables $tb  --opt --default-character-set=utf8 --set-gtid-purged=off --hex-blob  --single-transaction --compact --compress 2>/dev/null|
mysql -h$bake_host -u$bake_db_user -p$bake_password $database 2>/var/log/mysql_report_rsync.error.log
