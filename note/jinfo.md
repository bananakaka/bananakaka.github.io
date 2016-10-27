[TOC]

### jhat命令

#### 官方使用文档
http://docs.oracle.com/javase/7/docs/technotes/tools/share/jinfo.html

#### jhat有什么用途？
打印Java进程配置信息，包括Java启动参数，系统变量等。

注：如果在64位JVM上运行，可能需要指定-J-d64选项。

#### 如何使用？
```
Usage:
    jinfo [option] <pid>
        (to connect to running process)
    jinfo [option] <executable <core>
        (to connect to a core file)
    jinfo [option] [server_id@]<remote server IP or hostname>
        (to connect to remote debug server)

where <option> is one of:
    -flag <name>         打印指定jvm启动参数的值
    -flag [+|-]<name>    启用或禁用指定的jvm启动参数
    -flag <name>=<value> 给指定的jvm启动参数赋值
    -flags               打印所有的jvm启动参数
    -sysprops            打印所有的Java系统属性
    <no option>          不带参数时，jvm启动参数和系统属性都会打印
```

选项：
no option  打印命令行参数和系统属性
-flags  打印命令行参数
-sysprops  打印系统属性
-h  帮助

观察运行中的java程序的运行环境参数：参数包括Java System属性和JVM命令行参数
实例：
jinfo 2083
其中2083就是java进程id号，可以用jps得到这个id号。我在windows上尝试输入这个命令，但是不管用，于是我输入了下面这个命令：
jinfo -flag MaxPermSize 3980
显示如下：
-XX:MaxPermSize=67108864



 jinfo可以输出并修改运行时的java 进程的opts。用处比较简单，用于输出JAVA系统参数及命令行参数。用法是jinfo -opt  pid 如：查看2788的MaxPerm大小可以用  jinfo -flag MaxPermSize 2788。