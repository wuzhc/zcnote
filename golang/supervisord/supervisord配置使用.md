```conf
[supervisord]
identifier=supervisor
logfile=supervisord.log
logfile_maxbytes=50*1024*1024
logfile_backups=10
loglevel=info
pidfile=supervisord.pid

[eventlistener:xxx]
restartpause=0 # 重启之前延迟时间


```

## 进程状态
- STOPPED 开始创建进程时的状态
- STARTING 开启启动命令
- BACKOFF 启动命令后报错后继续执行
- EXITED 退出

## sync.Cond的使用