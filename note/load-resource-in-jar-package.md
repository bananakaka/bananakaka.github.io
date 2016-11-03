#### 背景

bizad_admin、bizad_cpc_server依赖bizad_tool(jar包)，生成图片的代码(bizad_tool)用到了本工程里的资源文件，所以需要读取jar包内资源。

#### 目标

从依赖的jar包中读取资源文件。

因为jar包是一个独立文件而非文件夹，绝对不可能通过"file:/e:/.../bizad_tool.jar/banner/hot.jpg"这种形式的文件URL来定位hot.jpg。即使是相对路径，也无法定位到jar包的资源文件。

能否通过C:/bizad_tool.jar!/banner/hot.jpg来得到hot.jpg文件？

```java
File file = new File("C:/bizad_tool.jar!/banner/hot.jpg");
```
当然不可能，因为".../bizad_tool.jar!/banner/...."并不是文件资源定位符的格式 (jar包中资源有其专门的URL形式：**jar:!/{entry}** )。所以，如果jar包中用new File(相对路径)的形式，是不可能定位到文件资源的。

#### 解决方案

- 通过Class类的getResource()和getResourceAsStream()，**推荐使用**。这两个方法会委托ClassLoader类getResource()和getResourceAsStream()。


```java
InputStream leftTopLogoIS = ImageUtil.class.getResourceAsStream("/banner/hot.jpg");
```
​        1、路径参数以"/"开头，代表在classpath根路径下获取资源。内部实现委托了ClassLoader(一般是URLClassLoader).getResourceAsStream("banner/hot.jpg")。**推荐用Class类的方法，路径参数以"/"开头。**

​        2、路径参数不以"/"开头，代表在这个类所在的package下获取资源。

​        区分逻辑参见：**Class.resolveName方法**

- 通过ClassLoader类getResource()和getResourceAsStream()方法

```java
InputStream leftTopLogoIS = ImageUtil.class.getClassLoader().getResourceAsStream("banner/hot.jpg");
```

​        1、路径参数以"/"开头，代表用bootstrap加载器，C++实现，加载范围为null。

​        2、路径参数不以"/"开头，代表用classloader的加载范围，加载过程中，用双亲委派方式。

#### 注意

Class.getResource和Class.getResourceAsStream在使用时，路径选择上是一样的。

ClassLoader.getResource和ClassLoader.getResourceAsStream在使用时，路径选择上也是一样的。

#### 为什么推荐用Class类的getResource()和getResourceAsStream()？

分析源码得知，此方式考虑了classloader为null的情况，做了判空。什么时候返回的类加载器为null？当前类被bootstrap加载器加载时，返回null。

#### classloader加载的类所在位置

bootstrapClassLoader加载jre\lib\rt.jar

ExtClassLoader加载jre\lib\ext\*.jar

AppClassLoader加载应用的jar

注：ExtClassLoader和AppClassLoader都是sun.misc.Launcher类中的内部类。

#### 通过Class获取outputStream

```java
FileOutputStream out = new FileOutputStream(new File (Test.class.getResource("path").toURI()));
```