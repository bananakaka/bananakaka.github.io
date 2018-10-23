[TOC]

### jmap命令

#### 官方使用文档

http://docs.oracle.com/javase/7/docs/technotes/tools/share/jmap.html

#### jmap有什么用途？
打印堆内存、共享对象映射详细信息，一般结合MAT(Memory Analysis Tool)、VisualVM、jhat(Java Heap Analysis Tool)等工具分析jmap dump文件。

注：如果在64位JVM上运行，可能需要指定-J-d64选项。

#### 如何使用？

jmap -h

![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jdk-tool/jmap-help.jpg)

option选项只能是以下其中一个

##### no option

    打印shared object mappings(共享对象映射)信息
    共享对象的起始地址、映射大小、共享对象的文件完整路径。
![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jdk-tool/jmap-no-option.jpg)

##### -heap

    打印堆内存摘要信息。包括：使用的GC算法、堆配置参数和各代中容量、使用、空闲情况，输出信息比jstat友好
    注：对应JVM的启动参数是对应Heap configuration的名称
    MinHeapFreeRatio:堆最小空闲比率(default 40)，堆的使用率小于40%的时候进行缩容，当Xmx=Xms时此配置无效
    MaxHeapFreeRatio:堆最大空闲比率(default 70)，堆的使用率大于70%的时候进行扩容，当Xmx=Xms时此配置无效
    MaxHeapSize:堆最大占用空间
    NewSize:新生代初始占用空间
    MaxNewSize:新生代最大占用空间
    OldSize:老年代初始占用空间
    NewRatio:新生代和老年代空间大小比例，等于2代表new:old=1:2，新生代占整个堆内存的1/3。
    SurvivorRatio:新生代中Survivor区与Eden区空间大小比例，等于8代表(s0或s1):eden=1:8，一个Survivor区占用整个新生代的1/10。
    PermSize:永久代初始占用空间
    MaxPermSize:永久代最大占用空间
    G1HeapRegionSize:使用G1垃圾收集的空间
![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jdk-tool/jmap-heap.jpg)

##### -histo[:live]

    打印堆内存对象的直方图，包括类名(内部类会带有一个"*"前缀)，对象数量，对象占用总空间大小。
    注意：
        1、该命令在线上执行时要做好评估，否则会导致线上机器宕机。
        2、指定":live"的话，则只统计存活的对象，会先触发full gc，然后再统计信息。

![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jdk-tool/jmap-histo.jpg)

##### -permstat

    打印堆内存中class loader维度的永久代统计信息。主要打印：class loader地址、加载类的数量、总字节数、parent_loader地址、是否存活、class loader类型。最后打印出intern的string对象的数量和总字节数。

![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jdk-tool/jmap-permstat.jpg)

##### -finalizerinfo

    打印正等待回收的对象信息。

![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jdk-tool/jmap-finalizerinfo.jpg)

##### -dump:\<dump-options>

    把堆内存dump为hprof二进制格式文件。
    live         仅dump存活对象; 如果不指定此参数，则导出堆内存中所有对象，不管死的活的。
    format=b     二进制格式
    file=<file>  dump heap to <file>
    举例: jmap -dump:live,format=b,file=heap.hprof <pid>
    注意：如果dump文件较大，会比较耗时，而且会导致显示服务不可用，所以在线上环境要慎重使用。
![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jdk-tool/jmap-dump.jpg)

##### -F

    当pid无响应时，强制jmap。 用在jmap -dump或jmap -histo上。注意，带-F时不支持 "live" 子选项。

##### -JOption

    用于将给定的javaOption传给java应用程序加载器，例如，“-J-Xms48m”将把启动内存设置为48M。



#### 生成jmap dump文件

dump文件可以用MAT(Memory Analysis Tool)、VisualVM、jhat(Java Heap Analysis Tool)等工具分析。

- 配置JVM启动参数，目的是在遇到OOM时自动生成dump文件：

  -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/path


- jmap -dump:live,format=b,file=/path/heap.hprof pid


#### 用jhat分析dump文件

jhat -port 9998 /path/heap.hprof
注意：如果dump文件太大，需要加上-J-Xmx512m参数指定最大堆内存，即jhat -J-Xmx512m -port 9998 /path/heap.hprof
然后就可以在浏览器中输入ip:9998查看了：

#### 总结

如果应用内存不足或频繁gc，很有可能存在内存泄漏情况，可以先查看堆内存各代的占用情况，然后借助dump文件查看对象情况。

使用jmap的时候，jvm是处在假死状态的，只能在服务不可用的时候解决问题来使用，否则造成服务中断。



