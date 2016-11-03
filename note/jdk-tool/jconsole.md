jconsole

用法: jconsole [ -interval=n ] [ -notile ] [ -pluginpath  ] [ -version ] [ connection ...]

  -interval   将更新间隔时间设置为 n 秒（默认值为 4 秒）
  -notile     最初不平铺显示窗口（对于两个或更多连接）
  -pluginpath 指定 jconsole 用于查找插件的路径
  -version    输出程序版本

  connection = pid || host:port || JMX URL (service:jmx:://...)

  pid       目标进程的进程 ID
  host      远程主机名或 IP 地址
  port      用于远程连接的端口号

  -J          对正在运行 jconsole 的 Java 虚拟机指定输入参数


http://www.jianshu.com/p/290489f0a495

