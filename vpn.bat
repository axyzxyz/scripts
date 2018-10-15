@echo ###vpn自动连接脚本 by ysj ###
@echo 环境差异，导致部分系统获取管理员权限失败，请直接使用管理员权限运行（出现 “请求的操作需要提升”，即表示未使用管理员权限）
@REM @ echo 提升权限
@REM @%1 %2
@REM @ver|find "5.">nul&&goto :Admin
@REM @mshta vbscript:createobject("shell.application").shellexecute("%~s0","goto :Admin","","runas",1)(window.close)&goto :eof
@REM @:Admin
@color A
@
@
@
@
@echo ******开始执行****** 
@echo 检测vpn名称，用户名，密码是否设置
@REm vpn名字
@set vpn=fulan
@REm vpn用户名
@set user=
@REm vpn密码
@set passwd=
@color A
@
@if "%vpn%"=="" (echo 请打开脚本设置vpn名称，用户名，密码（脚本即将自动退出）&sleep 3&exit) else echo 以下操作需要请求管理员权限
@
@echo 提升权限
@
@
@color A
@echo 正在链接VPN
@rasdial %vpn% %user% %passwd%
@REM for /f "usebackq" %s in (`"ipconfig|grep -A 4 fulan|grep IPv4|awk '{print $NF}'"`) do route add 192.168.0.0 mask 255.255.255.0 %s metric 1
@
@REM for  %%s in (`"ipconfig|grep -A 4 fulan|grep IPv4|awk '{print $NF}'"`) do route add 192.168.0.0 mask 255.255.255.0 %%s metric 1
@
@REM for  %%s in (`ipconfig|grep -A 4 fulan|grep IPv4|awk '{print $NF}'`) do echo %%s
@rem ipconfig|grep -A 4 fulan|grep IPv4|awk '{print $NF}'  >ls.temptxt
@rem set /p a=<ls.temptxt
@rem del ls.temptxt
@for  /f "tokens=16"  %%i in ('ipconfig ^| find /i "192.168.25."') do set ip=%%i
@echo VPN的IP地址为：%ip% 
@echo 增加路由
@route add 192.168.0.0 mask 255.255.255.0 %ip% metric 1
@
@REM set/p a= |ipconfig|grep -A 4 fulan|grep IPv4|awk '{print $NF}'
@
@REM echo %a% 
@
@echo 执行完成脚本即将自动退出&sleep 4 
@
