[TOC]

### jinfo命令

#### 官方使用文档
http://docs.oracle.com/javase/7/docs/technotes/tools/share/jinfo.html

#### jinfo有什么用途？
打印Java进程配置信息，包括Java启动参数，系统变量等。

注：如果在64位JVM上运行，可能需要指定-J-d64选项。

#### 如何使用？

##### jinfo -h

![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jinfo-help.jpg)

option选项只能是以下其中一个

##### -flag <name>

打印指定jvm启动参数的值

![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jinfo-flag-name.jpg)

##### -flag [+|-]<name>

启用或禁用指定的jvm启动参数

##### -flag <name>=<value>

给指定的jvm启动参数赋值

##### -flags

打印所有的jvm启动参数。

![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jinfo-flags.jpg)

##### -sysprops

打印所有的Java系统属性。

![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jinfo-sysprops.jpg)

##### no option

jvm启动参数和系统属性都会打印。

![](https://raw.githubusercontent.com/tinyivc/tinyivc.github.io/master/img/jinfo-no-option.jpg)





