### jps命令

[TOC]

#### jps有什么用途？

查看基于HotSpot的JVM的java进程信息，与unix上的ps类似，只不过jps是用来显示java进程，可以把jps理解为ps的一个子集。jps仅查找当前用户的Java进程，而不是当前系统中的所有进程。

#### 实现原理

java程序启动以后，会在`java.io.tmpdir`目录下，就是临时文件夹里，生成类似于`hsperfdata_{userName}`的文件夹，这个文件夹里（在Linux中为/tmp/hsperfdata_{userName}/），有几个文件，名字就是java进程的pid，因此列出当前运行的java进程，只是把这个目录里的文件名列一下而已。

#### 如何使用？

jps -help

![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jps-help.jpg)

```shell
jps [-q] [-mlvV] [<hostid>]
```

#### 示例

```shell
jps -lvm
```

![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jps-lvm.jpg)

#### 具体参数

##### hostid

    如果没有指定hostid，它只会显示本机所有的Java进程
    如果指定了hostid，它就会显示指定hostid上面的java进程，不过这需要远程机器开启了jstatd服务(jvm监控服务，采用rmi协议，默认端口1099)
##### -l

    输出应用程序主类的类全名，或者是应用程序JAR文件的完整路径。
![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jps-l.jpg)

##### -v

    输出传给JVM的参数。
![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jps-v.jpg)

##### -m

    输出传递给main方法的参数，如果是内嵌的JVM则输出为null。
![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jps-m.jpg)

##### -V

    输出通过标记的文件传递给JVM的参数（.hotspotrc文件，或者是通过参数-XX:Flags=<filename>指定的文件）。
##### -q

    只输出pid，忽略输出的类名、Jar包名以及传递给main方法的参数。
![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jps-q.jpg)

##### -JjavaOption

    用于将给定的javaOption传给java应用程序加载器，例如，“-J-Xms48m”将把启动内存设置为48M。使用-J选项可以非常方便的向基于Java开发的底层虚拟机应用程序传递参数。
#### 远程jps

    hostid的格式：
        [protocol:][[//]hostname][:port][/servername]
    protocol - 如果protocol及hostname都没有指定，那表示的是与当前环境相关的本地协议，如果指定了hostname却没有指定protocol，那么protocol的默认就是rmi。
    hostname - 服务器的IP或者名称，没有指定则表示本机。
    port - 远程rmi的端口，如果没有指定则默认为1099。
    servername - 注册到RMI注册中心中的jstatd的名称。

#### jps不足之处

jps有个地方很不好，似乎只能显示当前用户的java进程，要显示其他用户的还是只能用ps命令。

#### JPS失效时如何处理？

**现象：** 用ps ef|grep java能看到启动的java进程，但是用jps查看却不存在该进程的id。jconsole、jvisualvm可能无法监控该进程，其他java自带工具也可能无法使用。

**分析：** jps、jconsole、jvisualvm等工具的数据来源就是这个文件（/tmp/hsperfdata_{userName}/pid)。所以当该文件不存在或是无法读取时就会出现jps无法查看该进程号，jconsole无法监控等问题。

**原因：**

1. 磁盘读写、目录权限问题。若该用户没有权限写/tmp目录或是磁盘已满，则无法创建/tmp/hsperfdata_userName/pid文件。或该文件已经生成，但用户没有读权限
2. 临时文件丢失，被删除或是定期清理。对于linux机器，一般都会存在定时任务对临时文件夹进行清理，导致/tmp目录被清空。常用的可能定时删除临时目录的工具为crontab、redhat的tmpwatch、ubuntu的tmpreaper等等。这个导致的现象可能会是这样，用jconsole监控进程，发现在某一时段后进程仍然存在，但是却没有监控信息了。
3. java进程信息文件存储地址被设置，不在/tmp目录下。上面我们在介绍时说默认会在/tmp/hsperfdata_{userName}目录保存进程信息，但由于以上1、2所述原因，可能导致该文件无法生成或是丢失，所以java启动时提供了参数(-Djava.io.tmpdir)，而jps、jconsole都只会从/tmp目录读取，而无法从设置后的目录读物信

