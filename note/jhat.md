[TOC]

### jhat命令

#### 官方使用文档

http://docs.oracle.com/javase/7/docs/technotes/tools/share/jhat.html

#### jhat有什么用途？

对heap dump文件进行离线分析，并启动web服务，支持OQL(对象查询语言，类似SQL)语言查询。
默认的访问地址：http://localhost:7000/oqlhelp/

#### 生成堆dump文件的方式

用jmap -dump选项
Use jconsole option to obtain a heap dump via HotSpotDiagnosticMXBean at runtime;
Heap dump will be generated when OutOfMemoryError is thrown by specifying -XX:+HeapDumpOnOutOfMemoryError VM option;
Use hprof.

#### 如何使用？

![https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jhat-help.jpg]()

```
Usage:  jhat [-stack <bool>][-refs ] [-port <port>][-baseline ] [-debug <int>][-version] [-h|-help] <file>

        -J<flag>          Pass <flag> directly to the runtime system. For example, -J-mx512m to use a maximum heap size of 512MB
        -stack false:     Turn off tracking object allocation call stack.
        -refs false:      Turn off tracking of references to objects
        -port <port>:     Set the port for the HTTP server.  Defaults to 7000
        -exclude <file>:  Specify a file that lists data members that should
                  be excluded from the reachableFrom query.
        -baseline <file>: Specify a baseline object dump.  Objects in
                  both heap dumps with the same ID and same class will
                  be marked as not being "new".
        -debug <int>:     Set debug level.
                    0:  No debug output
                    1:  Debug hprof file parsing
                    2:  Debug hprof file parsing, no server
        -version          Report version number
        -h|-help          Print this help and exit
        <file>            The file to read
For a dump file that contains multiple heap dumps,
you may specify which dump in the file
by appending "#<number>" to the file name, i.e. "foo.hprof#3".
All boolean options default to "true"
```

##### -stack false/true

关闭跟踪对象分配调用栈。在堆内存dump文件中没有提供分配站点信息时，必须将此选项设为false。默认开启。

##### -refs false/true

关闭跟踪对象的引用。默认开启，返回的指针计算堆内存中所有对象。

##### -port port-number

指定jhat启动的http服务器的开放端口，默认是7000

##### -exclude exclude-file

指定一个文件，文件内容是在"可达对象"中要排除的数据成员列表。例如，如果文件列表是"java.lang.String.value"，当计算任何一个"可达对象"时，如果对象依赖图中引用到了java.lang.String.value属性，则此对象将被忽略解析。

##### -baseline baseline-dump-file

指定dump基线。
在两个dump文件中有相同的对象id和类名的对象，不会标识为"new"，其他对象会标识为"new"。
在比较两个dump文件时，非常有用。

##### -debug int

指定debug级别。0代表不输出debug信息，1代表debug hprof文件的解析过程，2代表不开启server的情况debug hprof文件的解析过程。

##### -Joption

用于将给定的javaOption传给java应用程序加载器，例如，“-J-Xms512m”将把启动内存设置为512MB。

#### 在jhat使用OQL

http://blog.csdn.net/gtuu0123/article/details/6039592





