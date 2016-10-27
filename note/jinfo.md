jinfo
用法：
jinfo [ option ] pid
jinfo [ option ] executable core
jinfo [ option ] [server-id@]remote-hostname-or-IP

参数：

pid   进程号
executable   产生core dump的java executable
core   core file
remote-hostname-or-IP  主机名或ip
server-id    远程主机上的debug server的唯一id

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