[TOC]

### jstat命令

#### 官方使用文档

http://docs.oracle.com/javase/7/docs/technotes/tools/share/jstat.html

#### jstat有什么用途？

监控JVM，对JVM heap的使用情况进行实时统计，从不同维度查看heap的使用情况。可以对JVM做如下监控：

- 类的加载及卸载情况
- 查看新生代、老年代及持久代的容量及使用情况
- 查看新生代、老年代及持久代的垃圾收集情况，包括垃圾回收(young gc,full gc)的次数及垃圾回收所占用的时间
- 查看新生代中Eden区及Survior区中容量及分配情况等

#### 如何使用？

jstat -help

![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jdk-tool/jstat-help.jpg)

```shell
jstat -<option> [-t][-h] <vmid> [<interval> [<count>]]
jstat [ generalOption | outputOptions vmid [interval[s|ms] [count]] ]
```

#### 示例

jps
找到Java进程id:2334

```shell
jstat -gc -t -h 4 2334 1s
```

#### 打印参数

##### -t

    用于在输出内容的第一列显示时间戳，这个时间戳代表的时JVM开始启动到现在的时间
##### vmid

    pid
interval:\<n>["ms"|"s"]

    间隔时间，单位可以是秒或者毫秒，通过指定s或ms确定，默认单位为毫秒
##### count

    打印次数，如果缺省则打印无数次
##### -h  n

    用于指定每隔几行就输出列头，如果不指定，默认是只在第一行出现列头。
##### -JOption

    用于将给定的javaOption传给java应用程序加载器，例如，“-J-Xms48m”将把启动内存设置为48M。
#### 具体参数

##### -gc    用于查看JVM中堆的垃圾收集情况的统计

    S0C 新生代中Survivor space中S0当前容量的大小（KB）
    S1C 新生代中Survivor space中S1当前容量的大小（KB）
    S0U 新生代中Survivor space中S0容量使用的大小（KB）
    S1U 新生代中Survivor space中S1容量使用的大小（KB）
    EC  Eden space当前容量的大小（KB）
    EU  Eden space容量使用的大小（KB）
    OC  Old space当前容量的大小（KB）
    OU  Old space使用容量的大小（KB）
    PC  Permanent space当前容量的大小（KB）
    PU  Permanent space使用容量的大小（KB）
    YGC   从应用程序启动到采样时发生 Young GC 的次数
    YGCT  从应用程序启动到采样时 Young GC 所用的时间(秒)
    FGC   从应用程序启动到采样时发生 Full GC 的次数
    FGCT  从应用程序启动到采样时 Full GC 所用的时间(秒)
    GCT   T从应用程序启动到采样时用于垃圾回收的总时间(单位秒)，它的值等于YGC+FGC

![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jdk-tool/jstat-gc.jpg)

##### -gccapacity    用于查看新生代、老年代及持久代的存储容量情况

    NGCMN   新生代的最小容量大小（KB）
    NGCMX   新生代的最大容量大小（KB）
    NGC 当前新生代的容量大小（KB）
    S0C 当前新生代中survivor space 0的容量大小（KB）
    S1C 当前新生代中survivor space 1的容量大小（KB）
    EC  Eden space当前容量的大小（KB）
    OGCMN   老年代的最小容量大小（KB）
    OGCMX   老年代的最大容量大小（KB）
    OGC 当前老年代的容量大小（KB）
    OC  当前老年代的空间容量大小（KB）
    PGCMN   持久代的最小容量大小（KB）
    PGCMX   持久代的最大容量大小（KB）
    PGC 当前持久代的容量大小（KB）
    PC  当前持久代的空间容量大小（KB）
    YGC 从应用程序启动到采样时发生 Young GC 的次数
    FGC 从应用程序启动到采样时发生 Full GC 的次数

![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jdk-tool/jstat-gccapacity.jpg)

##### -gccause    用于查看垃圾收集的统计情况

这个和-gcutil选项一样，如果有发生垃圾收集，它比-gcutil会多出最后一次垃圾收集原因以及当前正在发生的垃圾收集的原因。

    LGCC 最后一次垃圾收集的原因，可能为“unknown GCCause”、“System.gc()”等
    GCC  当前垃圾收集的原因
![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jdk-tool/jstat-gccause.jpg)

##### -gcutil    用于查看新生代、老年代及持久代垃圾收集的情况

    S0  Heap上的 Survivor space 0 区已使用空间的百分比
    S1  Heap上的 Survivor space 1 区已使用空间的百分比
    E   Heap上的 Eden space 区已使用空间的百分比
    O   Heap上的 Old space 区已使用空间的百分比
    P   Perm space 区已使用空间的百分比
    还有其他指标像：YGC、YGCT、FGC、FGCT、GCT，可以用-gc查看

![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jdk-tool/jstat-gcutil.jpg)

##### -gcnew    用于查看新生代垃圾收集的情况

    TT  Tenuring threshold，要了解这个参数，我们需要了解一点Java内存对象的结构，在Sun JVM中，（除了数组之外的）对象都有两个机器字（words）的头部。第一个字中包含这个对象的标示哈希码以及其他一些类似锁状态和等标识信息，第二个字中包含一个指向对象的类的引用，其中第二个字节就会被垃圾收集算法使用到。
    在新生代中做垃圾收集的时候，每次复制一个对象后，将增加这个对象的收集计数，当一个对象在新生代中被复制了一定次数后，该算法即判定该对象是长周期的对象，把他移动到老年代，这个阈值叫着tenuring threshold。这个阈值用于表示某个/些在执行批定次数youngGC后还活着的对象，即使此时新生的的Survior没有满，也同样被认为是长周期对象，将会被移到老年代中。
    MTT Maximum tenuring threshold，用于表示TT的最大值。
    DSS Desired survivor size (KB)
    还有其他指标像：S0C、S1C、S0U、S1U、EC、EU、YGC、YGCT，所以如果不是为了查看TT、MTT、DSS，推荐用-gc，因为这些指标-gc也有，还可以查看更多java heap信息

![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jdk-tool/jstat-gcnew.jpg)

##### -gcnewcapacity    用于查看新生代的存储容量情况

    S0CMX   新生代中SO的最大容量大小（KB）
    S1CMX   新生代中S1的最大容量大小（KB）
    ECMX    新生代中Eden的最大容量大小（KB）
    还有其他指标像：NGCMN、NGCMX、NGC、S0C、S1C、EC、YGC、FGC，所以如果不是为了查看TT、MTT、DSS，推荐用-gccapacity，因为这些指标-gccapacity也有，还可以查看更多heap capacity信息

![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jdk-tool/jstat-gcnewcapacity.jpg)

##### -gcold    用于查看老年代及持久代发生GC的情况

    PC、PU、OC、OU、YGC、FGC、FGCT、GCT
    完全可以用-gc代替，-gc还提供更多的信息

![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jdk-tool/jstat-gcold.jpg)

##### -gcoldcapacity    用于查看老年代的容量

    OGCMN、OGCMX、OGC、OC、YGC、FGC
    可以用-gccapacity代替
    FGCT、GCT
    可以用-gc代替

![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jdk-tool/jstat-gcoldcapacity.jpg)

##### -gcpermcapacity    用于查看持久代的容量

    PGCMN、PGCMX、PGC、PC、YGC、FGC
    可以用-gccapacity代替
    FGCT、GCT
    可以用-gc代替

![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jdk-tool/jstat-gcpermcapacity.jpg)

##### -class    用于查看类加载情况的统计

    Loaded  加载了的类的数量
    Bytes   加载了的类的大小，单为Kb
    Unloaded    卸载了的类的数量
    Bytes   卸载了的类的大小，单为Kb
    Time    花在类的加载及卸载的时间

![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jdk-tool/jstat-class.jpg)

##### -compiler    用于查看HotSpot中即时编译器编译情况的统计

    Compiled    编译任务执行的次数
    Failed  编译任务执行失败的次数
    Invalid 编译任务非法执行的次数
    Time    执行编译花费的时间
    FailedType  最后一次编译失败的编译类型
    FailedMethod    最后一次编译失败的类名及方法名

![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jdk-tool/jstat-compiler.jpg)

##### -printcompilation    HotSpot编译方法的统计

    Compiled    编译任务执行的次数
    Size    方法的字节码所占的字节数
    Type    编译类型
    Method  指定确定被编译方法的类名及方法名，类名中使名“/”而不是“.”做为命名分隔符，方法名是被指定的类中的方法，这两个字段的格式是由HotSpot中的“-XX:+PrintComplation”选项确定的。

![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jdk-tool/jstat-printcompilation.jpg)



#### 注意

建议不要编写脚本来解析jstat的输出，因为格式可能会在将来的版本中更改。



#### 原理

##### 怎么输出格式化内容的？

其实在tools.jar里存在一个文件叫做jstat_options，这个文件里定义了上面的每种类型的输出结果，比如说gcutil。

##### jstat如何获取到这些变量的值？

变量值显然是从目标进程里获取来的，但是是怎样来的？其实是从一个共享文件里来的，这个文件叫PerfData，主要指的是/tmp/hsperfdata_{user}目录下，Java进程号的文件名。

##### 文件创建

这个文件是否存在取决于两个参数，一个UsePerfData，另一个是PerfDisableSharedMem，如果设置了-XX:+PerfDisableSharedMem或者-XX:-UsePerfData，那这个文件是不会存在的。默认情况下PerfDisableSharedMem是关闭的，UsePerfData是打开的

UsePerfData：如果关闭这个参数，那么jvm启动过程中perf memory都不会被创建，默认情况是是打开的。
PerfDisableSharedMem：该参数决定了perf memory是不是可以被共享，也就是说不管这个参数有没有设置，jvm在启动的时候都会分配一块内存来存PerfData，只是其他进程是否可见的问题，如果设置了这个参数，说明不能被共享，此时其他进程将访问不了该内存，这样一来，譬如我们jps，jstat等都无法工作。默认这个参数是关闭的，也就是默认支持共享的方式。

##### 文件更新

由于这个文件是通过mmap的方式映射到了内存里，而jstat是直接通过DirectByteBuffer的方式从PerfData里读取的，所以只要内存里的值变了，那我们从jstat看到的值就会发生变化，内存里的值什么时候变，取决于-XX:PerfDataSamplingInterval这个参数，默认是50ms，也就是说50ms更新一次值，基本上可以认为是实时的了。

##### 文件删除

那这个文件什么时候删除？正常情况下当进程退出的时候会自动删除，但是某些极端情况下，比如kill -9，这种信号jvm是不能捕获的，所以导致进程直接退出了，而没有做一些收尾性的工作，这个时候你会发现进程虽然没了，但是这个文件其实还是存在的，那这个文件是不是就一直留着，只能等待人为的删除呢？jvm里考虑到了这种情况，会在当前用户接下来的任何一个java进程(比如说我们执行jps)起来的时候会去做一个判断，看/tmp/hsperfdata_{user}\下的进程是不是还存在，如果不存在了就直接删除该文件，判断是否存在的具体操作其实就是发一个kill -0的信号看是否有异常。

PerfData其他相关VM参数
-XX:PerfDataMemorySize：指定/tmp/hsperfdata_{user}\下perfData文件的大小，默认是32KB，如果用户设置了该值，jvm里会自动和os的page size对齐，比如linux下pagesize默认是4KB，那如果你设置了31KB，那自动会分配32KB
-XX:+PerfDataSaveToFile：是否在进程退出的时候讲PerfData里的数据保存到一个特定的文件里，文件路径由下面的参数指定，否则就在当前目录下
-XX:PerfDataSaveFile：指定保存PerfData文件的路径
-XX:PerfDataSamplingInterval：指定perfData的采样间隔，默认是50ms，基本算实时采样了。

