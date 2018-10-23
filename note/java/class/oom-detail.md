##### OutOfMemoryError一定会被加载吗？

这个类什么时候被加载呢？你或许会不假思索地说，根据java类的延迟加载机制，这个类一般情况下不会被加载，除非当我们抛出OutOfMemoryError这个异常的时候才会第一次被加载，否则一直不会被加载。其实这个类在jvm启动的时候就已经被加载了，不信你就执行java -verbose:class -version打印JDK版本看看，看是否有OutOfMemoryError这个类被加载，再输出里你将能找到下面的内容：
[Loaded java.lang.OutOfMemoryError from /Library/Java/JavaVirtualMachines/jdk1.7.0_79.jdk/Contents/Home/jre/lib/rt.jar]
这意味着这个类其实在jvm启动的时候就已经被加载了，梳理jvm实现，发现在加载OOM的类以后，还创建了好几个OutOfMemoryError对象，每个OutOfMemoryError对象代表了一种内存溢出的场景，比如说Java heap space不足导致的OutOfMemoryError，抑或Metaspace不足导致的OutOfMemoryError，如果是JDK8之前，你将看到Perm的OutOfMemoryError。

##### 能通过agent拦截到这个类加载吗？

熟悉字节码增强的人，可能会条件反射地想到是否可以拦截到这个类的加载呢，这样我们就可以做一些譬如内存溢出的监控啥的。我要告诉你的是NO WAY，因为通过agent的方式来监听类加载过程是在jvm初始化完成之后才开始的，而这个类的加载是在jvm初始化过程中，因此不可能拦截到这个类的加载，于此类似的还有java.lang.Object,java.lang.Class等。

##### 何时抛出OutOfMemoryError?

简单来说就是尝试分配内存，实在没办法就gc，gc后还不能分配就抛出异常。
不同的地方，分配的策略不一样，在heap或metaspace(perm)分配，分配策略也不一样。
下面以heap内存分配说一下具体过程：
一般情况下对象创建需要分配的内存是来自于Heap的Eden区域里，当Eden内存不够用的时候，某些情况下会尝试到Old里进行分配(比如说要分配的内存很大)，如果还是没有分配成功，于是会触发一次ygc的动作，而ygc完成之后我们会再次尝试分配，如果仍不足以分配此时的内存，那会接着做一次full gc(不过此时的soft reference不会被强制回收)，将老生代也回收一下，接着再做一次分配，仍然不够分配那会做一次强制将soft reference也回收的full gc，如果还是不能分配，那这个时候就不得不抛出OutOfMemoryError了。这就是Heap里分配内存抛出OutOfMemoryError的具体过程了。

##### 为什么要在vm启动过程中加载这个类？会创建无数OutOfMemoryError实例吗？

这两个问题可以一块回答，首先明确一个问题：抛出异常的java代码位置需要我们关心吗？
抛出OutOfMemoryError异常的java方法其实只是临门一脚而已，导致内存泄漏的不一定就是这个方法，当然也不排除可能是这个方法，不过这种情况的可能性真的非常小。所以你大可不必去关心抛出这个异常的堆栈。
好，明确这个问题，下面进入解答：既然可以不关心其异常堆栈，那意味着这个异常其实没必要每次都创建一个不一样的了，因为不需要堆栈的话，其他的东西都可以完全相同。
为什么要在jvm启动过程中加载这个类？：在jvm启动过程中我们把OOM类加载起来，并创建几个没有堆栈的对象缓存起来，只需要设置下不同的提示信息即可。当需要抛出特定类型的OutOfMemoryError异常的时候，就直接拿出缓存里的这几个对象就可以了。
当然除非你代码要不断new OutOfMemoryError()，否则不会创建无数的OOM的。

##### 如何分析OutOfMemoryError异常？

说是Perm导致的，那抛出来的异常信息里会带有Perm的关键信息，那我们应该重点看Perm的大小，以及Perm里的内容；如果是Heap的，那我们就必须做内存dump，MAT之。



