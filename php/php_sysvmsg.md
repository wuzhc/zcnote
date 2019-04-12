# 进程间通信
## System V消息队列

```php
<?php
//生成一个消息队列的key
$msg_key = ftok(__FILE__, 'a');
//产生一个消息队列
$msg_queue = msg_get_queue($msg_key, 0666);
//检测一个队列是否存在 ,返回boolean值
$status = msg_queue_exists($msg_key);
//可以查看当前队列的一些详细信息
$message_queue_status =  msg_stat_queue($msg_queue);

//将一条消息加入消息队列
msg_send($msg_queue, 1, "Hello, 1");
msg_send($msg_queue, 1, 'Hello, 2');
msg_send($msg_queue, 1, "Hello, 3");

//从消息队列中读取一条消息。
msg_receive($msg_queue, 1, $message_type, 1024, $message1);
msg_receive($msg_queue, 1, $message_type, 1024, $message2);
msg_receive($msg_queue, 1, $message_type, 1024, $message3);

//移除消息队列
msg_remove_queue($msg_queue);
echo $message1.PHP_EOL;
echo $message2.PHP_EOL;
echo $message3.PHP_EOL;
```
## 进程间通信
```php
<?php
/**
 * 这段代码模拟了一个日常的任务。
 * 第一个父进程产生了一个子进程。子进程又作为父进程，产生10个子进程。
 * 可以简化为A -> B -> c,d,e... 等进程。
 * 作为A来说，只需要生产任务，然后交给B 来处理。B 则会将任务分配给10个子进程来进行处理。
 * 
 */
 
//设定脚本永不超时
set_time_limit(0);
$ftok = ftok(__FILE__, 'a');
$msg_queue = msg_get_queue($ftok);
$pidarr = [];
 
//产生子进程
$pid = pcntl_fork();
if ($pid) {
    //父进程模拟生成一个特大的数组。
    $arr = range(1,100000);
 
    //将任务放进队里，让多个子进程并行处理
    foreach ($arr as $val) {
        $status = msg_send($msg_queue,1, $val);
        usleep(1000);
    }
    $pidarr[] = $pid;
    msg_remove_queue($msg_queue);
} else {
    //子进程收到任务后，fork10个子进程来处理任务。
    for ($i =0; $i<10; $i++) {
        $childpid = pcntl_fork();
        if ($childpid) {
            $pidarr[] = $childpid; //收集子进程processid
        } else {
            while (true) {
                msg_receive($msg_queue, 0, $msg_type, 1024, $message);
                if (!$message) exit(0);
                echo $message.PHP_EOL;
                usleep(1000);
            }
        }
    }
}
 
//防止主进程先于子进程退出，形成僵尸进程
while (count($pidarr) > 0) {
    foreach ($pidarr as $key => $pid) {
        $status = pcntl_waitpid($pid, $status);
        if ($status == -1 || $status > 0) {
            unset($pidarr[$key]);
        }
    }
    sleep(1);
}
?>
```
## 参考
[https://blog.csdn.net/weixin_42075590/article/details/81380755](https://blog.csdn.net/weixin_42075590/article/details/81380755)


SELECT t.id,t.fdIsSyncMongo FROM `wkwke`.`tbAnswerExam` `t` force index(appid) WHERE (t.fdIsSyncMongo=1) AND (t.fdAppID IN (16, 17, 46)) LIMIT 1;

SELECT t.id,t.fdIsSyncMongo FROM `wkwke`.`tbAnswerExam` `t` inner join wksvc.tbUser b on t.fdUserID = b.id WHERE (t.fdIsSyncMongo=1) AND b.fdIsXuetang = 1 LIMIT 1



exam->content->integer->integer->schoolMap


```sql
EXPLAIN SELECT COUNT( DISTINCT  `t`.`id` ) 
FROM  `wkwke`.`tbExam`  `t` 
INNER JOIN  `wkctn`.`tbContent`  `content` ON ( t.fdContentID = content.id ) 
INNER JOIN  `wkctn`.`tbInteger`  `schoolType` ON (  `schoolType`.`fdContentID` =  `content`.`id` ) 
AND (
schoolType.fdAttributeID =257
)
INNER JOIN  `wkctn`.`tbInteger`  `subtype` ON (  `subtype`.`fdContentID` =  `content`.`id` ) 
AND (
subtype.fdAttributeID =36
)
LEFT OUTER JOIN  `wkwke`.`tbSchoolMap`  `schoolMap` ON ( t.fdUserID = schoolMap.fdUserID ) 
WHERE (
(
(
(
(
t.fdDraft =2
)
AND (
schoolType.fdValue =2
)
)
AND (
subtype.fdValue =  '14'
)
)
AND (
schoolMap.fdSchoolID =204096
)
)
AND (
content.fdDisabled =3
)
)
AND (
content.fdTypeID =7
)
```

```sql
SELECT COUNT(DISTINCT `t`.`id`) FROM `wkwke`.`tbExam` `t`  INNER JOIN `wkctn`.`tbContent` `content` ON (t.fdContentID=content.id)  LEFT OUTER JOIN `wkwke`.`tbSchoolMap` `schoolMap` ON (t.fdUserID=schoolMap.fdUserID)  WHERE (((((t.fdDraft=2) AND (content.fdSchoolTypeID=2)) AND (content.fdSubjectID='14')) AND (schoolMap.fdSchoolID=204096)) AND (content.fdDisabled=3)) AND (content.fdTypeID=7);
```

