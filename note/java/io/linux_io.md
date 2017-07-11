**背景知识**

在Linux中，对于一次读取IO的操作，数据并不会直接拷贝到程序的程序缓冲区。它首先会被拷贝到操作系统内核的缓冲区中，然后才从内核缓冲区拷贝到应用程序的缓冲区。
1.Waiting for the data to be ready(等待数据到达内核缓冲区)
2.Copying the data from the kernel to the process(从内核缓冲区拷贝数据到程序缓冲区)

在Linux上一切皆文件，文件描述符(file descriptor)是内核为文件所创建的索引，所有I/O操作都通过调用文件描述符(索引)来执行，包括下面我们要提到的socket。Linux刚启动的时候会自动设置0是标准输入，1是标准输出，2是标准错误。


**blocking IO(阻塞IO)**
进程调用一个recvfrom请求，但是它不能立刻收到回复，直到数据返回，然后将数据从内核空间复制到程序空间。
步骤1和步骤2都是阻塞的

**nonblocking IO(非阻塞IO)**
当设置一个socket为nonblocking，相当于告诉内核当我们请求的IO操作不能立即得到返回结果，不要把进程设置为sleep状态，而是返回一个错误信息(EWOULDBLOCK)。
步骤1并不是完全的阻塞的，但是步骤2依然处于一个阻塞状态。

步骤1循环多次system call，在数据没准备好之前，OS都会返回EWOULDBLOCK状态码。


IO multiplexing(IO复用)
好处是可以通过(select/poll/epoll)同一个时刻处理多个文件描述符
IO复用两个步骤实际上也是完全阻塞的，看起来IO复用和阻塞IO相比似乎并没有什么优势，而且还需要两个return，但是这里注意在IO复用中我们可以同时监听多个文件描述符。

**signal driven IO(信号驱动IO)**
设置socket为一个信号驱动IO，并且通过sigaction system call得到一个signal handler，这个操作立刻完成。所以步骤1是非阻塞的。
当数据已经准备好了以后，一个SIGIO信号传送给应用进程告诉我们数据准备好了，然后进行步骤2，步骤2依然的阻塞的。

asynchronous IO(异步IO)
当步骤1和步骤2全部完成后会自动通知进程，相比前面的信号驱动IO，异步IO两个阶段都是非阻塞的。

**总结**
阻塞式IO(默认)，非阻塞式IO(nonblock)，IO复用(select/poll/epoll)，signal driven IO(信号驱动IO)都是属于同步型IO。因为步骤2全部是阻塞进行的。

