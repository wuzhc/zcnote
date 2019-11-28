TCP 内部的很多算法机制让他保持连接的过程中是很可靠的。比如：TCP 的超时重传、错误重传、TCP 的流量控制、阻塞控制、慢热启动算法、拥塞避免算法、快速恢复算法 等等



### 数据打包
出输层    网络层   链路层
段       包       帧
segment->packet->frame




### 阻塞

套接字对象内部有两个重要的缓冲结构,读缓冲和写缓冲;数据通过缓冲区再到网卡硬件
- 当writer buffer写满时,写会阻塞
- 当reader buffer为空时,读会阻塞
- 当写缓冲的内容拷贝到网卡后，是不会立即从写缓冲中将这些拷贝的内容移除的，而要等待对方的ack过来之后才会移除。如果网络状况不好，ack迟迟不过来，写缓冲很快就会满的



### tcp协议头格式 
![](http://www.52im.net/data/attachment/forum/201609/01/134217wuckuyvvcsuygnds.jpg)  
- Sequence Number：是包的序号，用来解决网络包乱序（reordering）问题。
- Acknowledgement Number：就是ACK——用于确认收到，用来解决不丢包的问题。
- Window：又叫Advertised-Window，也就是著名的滑动窗口（Sliding Window），用于解决流控的。
- TCP Flag ：也就是包的类型，主要是用于操控TCP的状态机的。



### 三次握手  
![](https://img2018.cnblogs.com/blog/184881/201809/184881-20180925181810810-423396758.png)  
- 客户端主动发送连接请求报文段，将SYN标识位置为1，Sequence Number置为x（TCP规定SYN=1时不能携带数据，x为随机产生的一个值），然后进入SYN_SEND状态
- 服务端收到SYN报文段进行确认，将SYN标识位置为1，ACK置为1，Sequence Number置为y，Acknowledgment Number置为x+1，然后进入SYN_RECV状态，这个状态被称为半连接状态
- 客户端再进行一次确认，将ACK置为1（此时不用SYN），Sequence Number置为x+1，Acknowledgment Number置为y+1发向服务器，最后客户端与服务器都进入ESTABLISHED状态



### seq序列号和ack确认号
seq是序列号，这是为了连接以后传送数据用的，ack是对收到的数据包的确认，值是等待接收的数据包的序列号。  
在第一次消息发送中，A随机选取一个序列号作为自己的初始序号发送给B；第二次消息B使用ack对A的数据包进行确认，因为已经收到了序列号为x的数据包，准备接收序列号为x+1的包，所以ack=x+1，同时B告诉A自己的初始序列号，就是seq=y；第三条消息A告诉B收到了B的确认消息并准备建立连接，A自己此条消息的序列号是x+1，所以seq=x+1，而ack=y+1是表示A正准备接收B序列号为y+1的数据包。  
seq是数据包本身的序列号；ack是期望对方继续发送的那个数据包的序列号。  



### 四次挥手
https://blog.csdn.net/yu876876/article/details/81560122
![](http://www.52im.net/data/attachment/forum/201604/26/142520px6qkzx886895jn8.png)  
- Client发送一个FIN，用来关闭Client到Server的数据传送，Client进入FIN_WAIT_1状态。
- Server收到FIN后，发送一个ACK给Client，确认序号为收到序号+1（与SYN相同，一个FIN占用一个序号），Server进入CLOSE_WAIT状态。而客户端得到服务端ack后进入FIN_WAIT_2状态
- Server发送一个FIN，用来关闭Server到Client的数据传送，Server进入LAST_ACK状态。
- Client收到FIN后，Client进入TIME_WAIT状态，接着发送一个ACK给Server，确认序号为收到序号+1，Server进入CLOSED状态，完成四次挥手。

  


### TIME_WAIT
为什么要这有TIME_WAIT？为什么不直接给转成CLOSED状态呢？主要有两个原因：
- 1）TIME_WAIT确保发送方最后一次能够发送ACK，如果接收方没有收到Ack，
就会触发被动端重发`Fin+ack`，一来一去正好2个MSL(即报文段生成时间)
- 2）有足够的时间让这个连接不会跟后面的连接混在一起,因为一个报文段最大生存时间为MSL    



### TIME_WAIT重用
从上面的描述我们可以知道，TIME_WAIT是个很重要的状态，但是如果在大并发的短链接下，TIME_WAIT 就会太多，这也会消耗很多系统资源  
- 1）新连接SYN告知的初始序列号比TIME_WAIT老连接的末序列号大；
- 2）如果开启了tcp_timestamps，并且新到来的连接的时间戳比老连接的时间戳大。
  要同时开启tcp_tw_reuse选项和tcp_timestamps 选项才可以开启TIME_WAIT重用



### 为什么要四次挥手
第二次握手的时候确认和请求回复可以合并为一步,但是挥手不可以
挥手的时候,接收到客户端的FIN报文后,先进行确认,但是不能请求回复,因为这个时候服务端可能还有数据没有发送完成,只有当服务端发送完数据之后才会发送FIN给客户端,请求客户端回复,所以服务端的确认和请求回复是分开的



### 为什么要三次握手
主要问题是第三次握手有没有必要,其实是为了防止已失效的连接请求报文段突然又传送到了服务端，因而产生错误,例如如果没有第三次握手,服务端接收到失效的连接请求后就建立连接,然后等待客户端发送数据,实际上客户端已经退出了,客户端不会发送任何东西给服务端,所以服务端完全没有必要建立连接,所以需要第三次握手,只有得到客户端的确认后才建立连接



### 如果已经建立了连接，但是客户端突然出现故障了怎么办？
TCP还设有一个保活计时器，显然，客户端如果出现故障，服务器不能一直等下去，白白浪费资源。服务器每收到一次客户端的请求后都会重新复位这个计时器，时间通常是设置为2小时，若两小时还没有收到客户端的任何数据，服务器就会发送一个探测报文段，以后每隔75分钟发送一次。若一连发送10个探测报文仍然没反应，服务器就认为客户端出了故障，接着就关闭连接。 



### TCP如何保证可靠性
- 超时重传机制
- 流量控制
- 数据包检验



### RRT和RTO
RTT——Round Trip Time，也就是一个数据包从发出去到回来的时间。这样发送端就大约知道需要多少的时间，从而可以方便地设置Timeout——RTO超时重传时间（Retransmission TimeOut）




### tcp重传机制
https://blog.csdn.net/zgege/article/details/80445324
发送方发送一个数据包给接收方后,需要得到接收方的`ACK`,如果超过`RTO`时间后还没得到接收方的`ACK`,发送方会进行重传数据包
![https://images2018.cnblogs.com/blog/1233668/201806/1233668-20180613233505890-1600510236.png](https://images2018.cnblogs.com/blog/1233668/201806/1233668-20180613233505890-1600510236.png)



### 流量控制
发送方会根据接收方的接收能力来决定发送方的发送速度。这个机制叫做流控制,大概流程如下:
![https://img-blog.csdn.net/20180605190737615?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3pnZWdl/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70](https://img-blog.csdn.net/20180605190737615?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3pnZWdl/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

- 接收方将自己可以接收的缓冲区大小放入 TCP 首部中的 “窗口大小” 字段,通过ack回传发送方,窗口大小越大,说明网络的吞吐量越高
- 发送方根据窗口大小来控制发送速度
- 如果接收方缓冲区满了,窗口设置为0,这个时候发送方不会在发送数据给接收方,但是需要发送方定时探测目前接收端的窗口大小,从而调整发送方的发送速度



### TCP滑动窗口
TCP通过Sliding Window来做流控（Flow Control）  

TCP必需要解决的可靠传输以及包乱序（reordering）的问题，所以，TCP必需要知道网络实际的数据处理带宽或是数据处理速度，这样才不会引起网络拥塞，导致丢包。  

TCP头里有一个字段叫Window，又叫Advertised-Window，这个字段是接收端告诉发送端自己还有多少缓冲区可以接收数据。于是发送端就可以根据这个接收端的处理能力来发送数据，而不会导致接收端处理不过来。  
- Silly Window Syndrome
- Zero Window



### TCP滑动窗口流程  

![](http://www.52im.net/data/attachment/forum/201708/30/150023u8ygkcocfga8pnac.jpg)  
- [1]-已经发送并得到接收端ACK的;
- [2]-已经发送但还未收到接收端ACK的;
- [3]-未发送但允许发送的(接收方还有空间);
- [4]-未发送且不允许发送(接收方没空间了)。  
![](http://www.52im.net/data/attachment/forum/201708/30/150115j6d96mozon09nn9n.jpg)  


### tcp拥塞控制
流量控制可以解决根据接收方接收能力来决定发送方的发送速度,但是无法知道网络情况,假设接收方的接收能力很好,发送方会根据接收方接受能力发了大量的数据包,如果每一个链接都这样,会导致网络很快出现拥塞的情况,所以我们需要拥塞控制

有一个拥塞窗口,接收到`ack`,拥塞窗口加1,每次发送方会根据拥塞窗口和表示接收方接收能力窗口做比较,取最小值作为发送数据窗口大小

#### 如何调整拥塞窗口
拥塞窗口,接收到`ack`,拥塞窗口加1,呈指数级增长, 慢启动阈值等于窗口最大值;在每次超时重发的时候, 慢启动阈值会变成原来的一半, 同时拥塞窗口置回1;少量的丢包, 我们仅仅是触发超时重传; 大量的丢包, 我们就认为网络拥塞;




### SYN攻击

SYN攻击就是Client在短时间内伪造大量不存在的IP地址，并向Server不断地发送SYN包，Server回复确认包，并等待Client的确认，由于源地址是不存在的，因此，Server需要不断重发直至超时，这些伪造的SYN包将长时间占用未连接队列，导致正常的SYN请求因为队列满而被丢弃，从而引起网络堵塞甚至系统瘫痪

SYN攻击是一种典型的DDOS攻击，检测SYN攻击的方式非常简单，即当Server上有大量半连接状态且源IP地址是随机的，则可以断定遭到SYN攻击了;总的来说就是攻击者就可以把服务器的syn连接的队列耗尽，让正常的连接请求不能处理

```bash
netstat -nap | grep SYN_RECV
```



### SYN超时
如果server端接到了clien发的SYN后回了SYN-ACK后client掉线了，server端没有收到client回来的ACK，那么，这个连接处于一个中间状态，即没成功，也没失败。于是，server端如果在一定时间内没有收到的TCP会重发SYN-ACK。在Linux下，默认重试次数为5次，重试的间隔时间从1s开始每次都翻售，5次的重试时间间隔为1s, 2s,4s, 8s, 16s，总共31s，第5次发出后还要等32s都知道第5次也超时了，所以，总共需要 1s + 2s + 4s+ 8s+ 16s + 32s = 2^6 -1 = 63s，TCP才会把断开这个连接。



### 其他问题

- 客户端发了很多数据包后不关闭socket,直接退出进程
这种情况下服务器程序能够收到部分TCP消息，然后收到“104: Connection reset by peer”（Linux下）或“10054: An existing connection was
 forcibly closed by the remote host”（Windows下）错误。  
因为server接收数据之后,需要回复ACK,此时client已经异常退出,链接也就失效了


