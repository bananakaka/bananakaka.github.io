#### 三次握手

![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/web/tcp/three-shake-hands.jpg)

#### 四次握手

![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/web/tcp/four-shake-hands.jpg)

#### tcp四层模型

- **应用层 (Application)**：应用层由一系列协议组成，包括HTTP、FTP、Telnet、SMTP，DNS、TFTP(用的UDP传输)。
- **传输层 (Transport)**：传输层包括 TCP 和 UDP，TCP 提供传输保证，而 UDP 几乎不对报文进行检查。
- **网络层 (Network)**：网络层协议由一系列协议组成，包括IP(v4,v6)、ICMP、ARP、RARP、OSPF等。
- **链路层 (Link)**：又称为物理数据网络接口层，负责报文传输。

![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/web/tcp/tcp-layer-model.jpg)

#### Socket

Socket是应用层与TCP/IP协议族通信的中间软件抽象层，它是一组接口。在设计模式中，Socket其实就是一个门面模式，它把复杂的TCP/IP协议族隐藏在Socket接口后面，对用户来说，一组简单的接口就是全部，让Socket去组织数据，以符合指定的协议。

当客户端要与服务端通信，客户端首先要创建一个 Socket 实例，操作系统将为这个 Socket 实例分配一个没有被使用的本地端口号，并创建一个包含本地和远程地址和端口号的套接字数据结构，这个数据结构将一直保存在系统中直到这个连接关闭。在创建 Socket 实例的构造函数正确返回之前，将要进行 TCP 的三次握手协议，TCP 握手协议完成后，Socket 实例对象将创建完成，否则将抛出 IOException 错误。
与之对应的服务端将创建一个 ServerSocket 实例，ServerSocket 创建比较简单只要指定的端口号没有被占用，一般实例创建都会成功，同时操作系统也会为 ServerSocket 实例创建一个底层数据结构，这个数据结构中包含指定监听的端口号和包含监听地址的通配符，通常情况下都是"*"，即监听所有地址。之后当调用 accept() 方法时，将进入阻塞状态，等待客户端的请求。当一个新的请求到来时，将为这个连接创建一个新的套接字数据结构，该套接字数据的信息包含的地址和端口信息正是请求源地址和端口。这个新创建的数据结构将会关联到 ServerSocket 实例的一个未完成的连接数据结构列表中，注意这时服务端与之对应的 Socket 实例并没有完成创建，而要等到与客户端的三次握手完成后，这个服务端的 Socket 实例才会返回，并将这个 Socket 实例对应的数据结构从未完成列表中移到已完成列表中。所以 ServerSocket 所关联的列表中每个数据结构，都代表与一个客户端的建立的 TCP 连接。

