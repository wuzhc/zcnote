五个星号代表**分、时、日、月、周**

**/var/spool/cron/ 这个目录下存放的是每个用户包括root的crontab任务**



## 管理命令

```bash
systemctl start crond    //启动服务
systemctl stop crond     //关闭服务
systemctl restart crond  //重启服务
systemctl reload crond   //重新载入配置
systemctl status crond   //查看服务状态 
```

```bash
crontab -l  //查看root用户的crontab任务
crontab -r  //删除root用户所有crontab任务
crontab -u  //使用者名称
```



## 实例

### 实例1：每1分钟执行一次myCommand

```
* * * * * myCommand
```

### 实例2：每小时的第3和第15分钟执行

```
3,15 * * * * myCommand
```

### 实例3：在上午8点到11点的第3和第15分钟执行

```
3,15 8-11 * * * myCommand
```

### 实例4：每隔两天的上午8点到11点的第3和第15分钟执行

```
3,15 8-11 */2  *  * myCommand
```

### 实例5：每周一上午8点到11点的第3和第15分钟执行

```
3,15 8-11 * * 1 myCommand
```

### 实例6：每晚的21:30重启smb

```
30 21 * * * /etc/init.d/smb restart
```

### 实例7：每月1、10、22日的4 : 45重启smb

```
45 4 1,10,22 * * /etc/init.d/smb restart
```

### 实例8：每周六、周日的1 : 10重启smb

```
10 1 * * 6,0 /etc/init.d/smb restart
```

### 实例9：每天18 : 00至23 : 00之间每隔30分钟重启smb

```
0,30 18-23 * * * /etc/init.d/smb restart
```

### 实例10：每星期六的晚上11 : 00 pm重启smb

```
0 23 * * 6 /etc/init.d/smb restart
```

### 实例11：每一小时重启smb

```
0 */1 * * * /etc/init.d/smb restart
```

### 实例12：晚上11点到早上7点之间，每隔一小时重启smb

```
0 23-7/1 * * * /etc/init.d/smb restart
```



## 参考

<https://www.runoob.com/w3cnote/linux-crontab-tasks.html>