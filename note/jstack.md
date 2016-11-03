[TOC]

### jstack命令

#### 官方使用文档

http://docs.oracle.com/javase/7/docs/technotes/tools/share/jstack.html

#### jstack有什么用途？

打印java线程的栈跟踪快照，打印所有栈帧。包括java线程名、线程优先级、线程id、native线程id、线程状态、Monitor、线程栈起始地址、调用栈。

如果在64位JVM上运行，可能需要指定-J-d64选项。可以用来分析线程问题（如死锁、锁争用、CPU负载高）、内存问题(OOM、内存泄漏)。在实际应用中，往往仅靠一次的线程dump不足以确认问题，建议产生三次以上的dump信息，如果都是同样的问题，方可确定原因。

#### 为什么要生成线程快照？

主要是定位线程出现长时间停顿的原因，如线程间死锁、死循环、请求外部资源导致的长时间等待等。

线程出现停顿的时候通过jstack来查看各个线程的调用栈，就可以知道无响应的线程到底在后台做什么事情，或者等待什么资源。 如果程序崩溃生成core文件，jstack可以获得core文件的java stack和native stack的信息，从而可以轻松地知道java程序是如何崩溃和在程序何处发生问题。另外，jstack还可以附属到正在运行的java程序中，看到当时运行的java程序的java stack和native stack的信息，如果现在运行的java程序呈现hung的状态，jstack是非常有用的。

#### 如何使用？

jstack -help
![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jdk-tool/jstack-help.jpg)

```shell
注释：
jstack [-m] [-l] <executable> <core>
    (to connect to a core file)
    executable:可执行的core dump文件，JVM crash生成的core文件。
    core:jstack打印的core文件名
jstack [-m] [-l] [server_id@]<remote server IP or hostname>
    (to connect to a remote debug server)
```

#### 示例

jps
找到Java进程id:2334

```shell
jstack -l 2334
jstack -l -m 2334
jstack -m 2334
```

#### 具体参数
##### -l  打印额外的锁信息，发生死锁时，用来观察锁持有情况

![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jdk-tool/jstack-l.jpg)

##### -m  不仅会输出Java栈信息，还会输出C/C++栈信息（比如native方法）
![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jdk-tool/jstack-m.jpg)

##### jstack -l -m pid

![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jdk-tool/jstack-l-m.jpg)

##### -F  进程没有响应(hung住)的时候，强制打印线程栈信息
#### 实战：配合top、printf命令

jps找到java进程

29767

```shell
top -Hp 29767
```

找到CPU负载最高的线程id

21742

计算线程id对应的十六进制数，因为jstack打印的线程id是十六进制

```shell
printf "%x\n" 21742
54ee
```

用jstack排查该线程的调用栈，查看线程快照

jstack -l 29767 | fgrep -30 '54ee'

#### 额外说明

##### Monitor

Monitor是 Java中实现线程之间的互斥与协作的主要手段，它可以看成是Class或者对象的锁。每一个Class/对象有且仅有一个Monitor。下面这个图，描述了线程和Monitor之间关系，以及线程的**状态转换图**：

![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jdk-tool/java-monitor.bmp)

拥有锁的线程称为"active thread"，其他线程称为"wait thread"，这些"wait thread"分别在两个队列"entry set"和"wait set"里等候。

- 当线程申请进入临界区时，会进入"entry set"队列，线程状态是"waiting for monitor entry"
- "wait set"队列的线程状态是"in Object.wait()"，只有当别的线程在该对象/Class上调用了notify()/nofityAll()，"wait set"队列中的线程才会得到机会去竞争monitor。


##### 方法调用修饰

表示线程在方法调用时，额外重要的操作。

- locked <地址> 目标：使用synchronized申请对象锁成功，Monitor的拥有者。对象锁可重入。
- waiting to lock <地址> 目标：使用synchronized申请对象锁未成功，在entry set等待。在调用栈顶出现，线程状态为Blocked。

- waiting on <地址> 目标：使用synchronized申请对象锁成功后，释放锁在wait set等待。在调用栈顶出现，线程状态为WAITING或TIMED_WATING。

- parking to wait for <地址> 目标：park是基本的线程阻塞原语，不通过Monitor在对象上阻塞。随concurrent包出现的新的机制，和synchronized体系不同。

##### 线程状态

- runnable:状态一般为RUNNABLE。
- in Object.wait():wait set等待，状态为WAITING或TIMED_WAITING。
- waiting for monitor entry:entry set等待，状态为BLOCKED。
- waiting on condition:wait set等待、parked。
- sleeping:休眠的线程，调用了Thread.sleep()。
- DeadLock:死锁
- suspend:暂停


