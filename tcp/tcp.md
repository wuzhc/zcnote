TCP 内部的很多算法机制让他保持连接的过程中是很可靠的。比如：TCP 的超时重传、错误重传、TCP 的流量控制、阻塞控制、慢热启动算法、拥塞避免算法、快速恢复算法 等等

### nio
非阻塞IO

### 阻塞
套接字对象内部有两个重要的缓冲结构,读缓冲和写缓冲;数据通过缓冲区再到网卡硬件
- 当writer buffer写满时,写会阻塞
- 当reader buffer为空时,读会阻塞
- 当写缓冲的内容拷贝到网卡后，是不会立即从写缓冲中将这些拷贝的内容移除的，而要等待对方的ack过来之后才会移除。如果网络状况不好，ack迟迟不过来，写缓冲很快就会满的

### 三次握手  
![](http://www.52im.net/data/attachment/forum/201604/26/141753hc3p885th8e6z55n.png)  
- 标志位ACK和确认需要ack不要搞混
- Client将标志位SYN置为1，随机产生一个值seq=J，并将该数据包发送给Server，Client进入SYN_SENT状态，等待Server确认。
- Server收到数据包后由标志位SYN=1知道Client请求建立连接，Server将标志位SYN和ACK都置为1，ack=J+1，随机产生一个值seq=K，并将该数据包发送给Client
以确认连接请求，Server进入SYN_RCVD状态。
- Client收到确认后，检查ack是否为J+1，ACK是否为1，如果正确则将标志位ACK置为1，ack=K+1，并将该数据包发送给Server，Server检查ack是否为K+1，ACK
是否为1，如果正确则连接建立成功，Client和Server进入ESTABLISHED状态，完成三次握手，随后Client与Server之间可以开始传输数据了。


### SYN攻击
SYN攻击就是Client在短时间内伪造大量不存在的IP地址，并向Server不断地发送SYN包，Server回复确认包，并等待Client的确认，由于源地址是不存在的，
因此，Server需要不断重发直至超时，这些伪造的SYN包将产时间占用未连接队列，导致正常的SYN请求因为队列满而被丢弃，从而引起网络堵塞甚至系统瘫痪SYN攻击时一
种典型的DDOS攻击，检测SYN攻击的方式非常简单，即当Server上有大量半连接状态且源IP地址是随机的，则可以断定遭到SYN攻击了;总的来说就是攻击者就可以把服务器的syn连接的队列耗尽，让正常的连接请求不能处理
```bash
netstat -nap | grep SYN_RECV
```

### SYN超时
如果server端接到了clien发的SYN后回了SYN-ACK后client掉线了，server端没有收到client回来的ACK，那么，这个连接处于一个中间状态，即没成功，也没失败。
于是，server端如果在一定时间内没有收到的TCP会重发SYN-ACK。在Linux下，默认重试次数为5次，重试的间隔时间从1s开始每次都翻售，5次的重试时间间隔为1s, 2s,
 4s, 8s, 16s，总共31s，第5次发出后还要等32s都知道第5次也超时了，所以，总共需要 1s + 2s + 4s+ 8s+ 16s + 32s = 2^6 -1 = 63s，TCP才会把断开
 这个连接。

### tcp重传机制
为了保证数据包可以达到  
接收端给发送端的Ack确认只会确认最后一个连续的包，比如，发送端发了1,2,3,4,5一共五份数据，接收端收到了1，2，于是回ack 3，然后收到了4（注意此时3没收到），
此时的TCP会怎么办？我们要知道，因为正如前面所说的，SeqNum和Ack是以字节数为单位，所以ack的时候，不能跳着确认，只能确认最大的连续收到的包，不然，发送端就以
为之前的都收到了。  
如果，包没有连续到达，就ack最后那个可能被丢了的包，如果发送方连续收到3次相同的ack，就重传

### RRT算法
RTT——Round Trip Time，也就是一个数据包从发出去到回来的时间。这样发送端就大约知道需要多少的时间，从而可以方便地设置Timeout——RTO（Retransmission TimeOut）

### TCP滑动窗口
TCP通过Sliding Window来做流控（Flow Control）  
TCP必需要解决的可靠传输以及包乱序（reordering）的问题，所以，TCP必需要知道网络实际的数据处理带宽或是数据处理速度，这样才不会引起网络拥塞，导致丢包。  
TCP头里有一个字段叫Window，又叫Advertised-Window，这个字段是接收端告诉发送端自己还有多少缓冲区可以接收数据。于是发送端就可以根据这个接收端的处理能力
来发送数据，而不会导致接收端处理不过来。  
- Silly Window Syndrome
- Zero Window

### TCP滑动窗口流程  
![](http://www.52im.net/data/attachment/forum/201708/30/150023u8ygkcocfga8pnac.jpg)  
- [1]-已经发送并得到接收端ACK的;
- [2]-已经发送但还未收到接收端ACK的;
- [3]-未发送但允许发送的(接收方还有空间);
- [4]-未发送且不允许发送(接收方没空间了)。  
![](http://www.52im.net/data/attachment/forum/201708/30/150115j6d96mozon09nn9n.jpg)  

### TCP解决0窗口问题
为解决0窗口的问题，TCP使用了Zero Window Probe技术，缩写为ZWP。发送端在窗口变成0后，会发ZWP的包给接收方，来探测目前接收端的窗口大小，一般这个值会设置
成3次，每次大约30-60秒（不同的实现可能会不一样）

### TCP避免发送小包问题
避免发送大量小包的问题
- 1)接收端一直在通知一个小的窗口;
- 2)发送端本身问题，一直在发送小包。
一种是接收端有足够的空间再发ACK到发送端,另一种是发送端积累后变大包再发送

### TCP的拥塞处理 – Congestion Handling
- 1）慢启动；
- 2）拥塞避免；
- 3）拥塞发生；
- 4）快速恢复。

### 四次挥手
![](http://www.52im.net/data/attachment/forum/201604/26/142520px6qkzx886895jn8.png)  
- Client发送一个FIN，用来关闭Client到Server的数据传送，Client进入FIN_WAIT_1状态。
- Server收到FIN后，发送一个ACK给Client，确认序号为收到序号+1（与SYN相同，一个FIN占用一个序号），Server进入CLOSE_WAIT状态。
- Server发送一个FIN，用来关闭Server到Client的数据传送，Server进入LAST_ACK状态。
- Client收到FIN后，Client进入TIME_WAIT状态，接着发送一个ACK给Server，确认序号为收到序号+1，Server进入CLOSED状态，完成四次挥手。

### 为什么要四次挥手
关闭连接时，当收到对方的FIN报文时，仅仅表示对方不再发送数据了但是还能接收数据，己方也未必全部数据都发送给对方了，所以己方可以立即close，也可以发送一些数
据给对方后，再发送FIN报文给对方来表示同意现在关闭连接，因此，己方ACK和FIN一般都会分开发送。

### 为什么要三次握手
Server发送SYN包是作为发起连接的SYN包，还是作为响应发起者的SYN包呢？怎么区分？比较容易引起混淆；  
Server的ACK确认包和接下来的SYN包可以合成一个SYN ACK包一起发送的，没必要分别单独发送，这样省了一次交互同时也解决了问题

### 数据打包
出输层    网络层   链路层
段       包       帧
segment->packet->frame

### TIME_WAIT
为什么要这有TIME_WAIT？为什么不直接给转成CLOSED状态呢？主要有两个原因：1）TIME_WAIT确保有足够的时间让对端收到了ACK，如果被动关闭的那方没有收到Ack，
就会触发被动端重发Fin，一来一去正好2个MSL，2）有足够的时间让这个连接不会跟后面的连接混在一起  
从上面的描述我们可以知道，TIME_WAIT是个很重要的状态，但是如果在大并发的短链接下，TIME_WAIT 就会太多，这也会消耗很多系统资源  
TIME_WAIT表示的是主动断连接  
主动关闭方需要进入TIME_WAIT以便能够重发丢掉的被动关闭方FIN的ACK  


### TIME_WAIT重用
- 1）新连接SYN告知的初始序列号比TIME_WAIT老连接的末序列号大；
- 2）如果开启了tcp_timestamps，并且新到来的连接的时间戳比老连接的时间戳大。
要同时开启tcp_tw_reuse选项和tcp_timestamps 选项才可以开启TIME_WAIT重用


### tcp协议头格式 
![](http://www.52im.net/data/attachment/forum/201609/01/134217wuckuyvvcsuygnds.jpg)  
- Sequence Number：是包的序号，用来解决网络包乱序（reordering）问题。
- Acknowledgement Number：就是ACK——用于确认收到，用来解决不丢包的问题。
- Window：又叫Advertised-Window，也就是著名的滑动窗口（Sliding Window），用于解决流控的。
- TCP Flag ：也就是包的类型，主要是用于操控TCP的状态机的。

### tcp拥塞控制
本质上，网络上拥塞的原因就是大家都想独享整个网络资源，对于TCP，端到端的流量控制必然会导致网络拥堵。这是因为TCP只看到对端的接收空间的大小，而无法知道链路上
的容量，只要双方的处理能力很强，那么就可以以很大的速率发包，于是链路很快出现拥堵，进而引起大量的丢包，丢包又引发发送端的重传风暴，进一步加剧链路的拥塞。另外
一个拥塞的因素是链路上的转发节点，例如路由器，再好的路由器只要接入网络，总是会拉低网络的总带宽，如果在路由器节点上出现处理瓶颈，那么就很容易出现拥塞。由于TCP
看不到网络的状况，那么拥塞控制是必须的并且需要采用试探性的方式来控制拥塞，于是拥塞控制要完成两个任务：[1]公平性；[2]拥塞过后的恢复。

TCP的发送端能发多少数据，由发送端的发送窗口决定(当然发送窗口又被接收端的接收窗口、发送端的拥塞窗口限制)的，那么一个TCP连接的传输稳定状态应该体现在发送端的
发送窗口的稳定状态上，这样的话，TCP的发送窗口有哪些稳定状态呢？  
TCP的流量控制使得它想要独享整个网络，而拥塞控制又限制其必要时做出牺牲来体现公平性  

### 其他问题
- 客户端发了很多数据包后不关闭socket,直接退出进程
这种情况下服务器程序能够收到部分TCP消息，然后收到“104: Connection reset by peer”（Linux下）或“10054: An existing connection was
 forcibly closed by the remote host”（Windows下）错误。  
因为server接收数据之后,需要回复ACK,此时client已经异常退出,链接也就失效了


