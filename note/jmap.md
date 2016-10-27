[TOC]

### jmap命令

#### 官方使用文档

http://docs.oracle.com/javase/7/docs/technotes/tools/share/jmap.html

#### jmap有什么用途？
打印堆内存、共享对象映射详细信息，一般结合MAT(Memory Analysis Tool)、VisualVM、jhat(Java Heap Analysis Tool)等工具分析jmap dump文件。

注：如果在64位JVM上运行，可能需要指定-J-d64选项。

#### 如何使用？

jmap -h

![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jmap-help.jpg)

option选项只能是以下其中一个

##### no option

    打印shared object mappings(共享对象映射)
![https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jmap-no-option.jpg]()

##### -heap

    打印堆内存配置和各个代的容量、使用、空闲情况，输出信息比jstat友好
![https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jmap-heap.jpg]()

##### -histo[:live]

    打印堆内存对象的直方图，包括类名(内部类会带有一个"*"前缀)，对象数量，对象占用总空间大小。指定":live"的话，则只统计存活的对象，会触发full gc。

![https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jmap-histo.jpg]()

##### -permstat

    打印堆内存中class loader维度的永久代统计信息。主要打印：class loader地址、加载类的数量、总字节数、parent_loader地址、是否存活、class loader类型。最后打印出intern的string对象的数量和总字节数。

![https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jmap-permstat.jpg]()

##### -finalizerinfo

    打印正等待回收的对象信息。

![https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jmap-finalizerinfo.jpg]()

-dump:<dump-options>

    把堆内存dump为hprof二进制格式文件。
    live         仅dump存活对象; 如果不指定此参数，则导出堆内存中所有对象，不管死的活的。
    format=b     二进制格式
    file=<file>  dump heap to <file>
    举例: jmap -dump:live,format=b,file=heap.hprof <pid>
![https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jmap-dump.jpg]()

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

