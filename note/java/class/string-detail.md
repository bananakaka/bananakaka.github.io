#### 拼接string的效率

- Java中字符串拼接不要直接使用+拼接。
- 两个字符串拼接直接调用String.concat性能最好，多个字符串循环拼接，还是推荐StringBuilder。
- String.concat的源码，在这个方法中，调用了一次Arrays.copyOf，并且指定了len + otherLen，相当于分配了一次内存空间，并分别从str1和str2各复制一次数据。而如果使用StringBuilder并指定capacity，相当于分配一次内存空间，并分别从str1和str2各复制一次数据，最后因为调用了toString方法，又复制了一次数据。

#### String.intern()

##### 原理

在JVM里存在一个叫做StringTable的数据结构，这个数据结构是一个Hashtable(C++版的HashMap)，在我们调用String.intern()的时候其实就是先去这个StringTable里查找是否存在一个同名的项，如果存在就直接返回对应的对象，否则就往这个table里插入一项，指向这个String对象，那么再下次通过intern()再来访问同名的String对象的时候，就会返回上次插入的这一项指向的String对象，根据原理，知道存在hash碰撞类似的风险，tomcat里爆发的一个HashMap导致的hash碰撞的问题，这里其实也是一个Hashtable。不过JVM里提供一个参数专门来控制这个table的size，-XX:StringTableSize，这个参数的默认值如下
product(uintx, StringTableSize, NOT_LP64(1009) LP64_ONLY(60013), "Number of buckets in the interned String table")
另外JVM还会根据hash碰撞的情况来决定是否做rehash，比如你从这个StringTable里查找某个字符串是否存在，如果对其对应的桶挨个遍历，超过了100个还是没有找到对应的同名的项，那就会设置一个flag，让下次进入到safepoint的时候做一次rehash动作，尽量减少碰撞的发生。
```c++
if (so & SO_Strings || (!collecting_perm_gen && !JavaObjectsInPerm)) {
    StringTable::oops_do(roots);
}
```
YGC过程不涉及到对perm做回收，因此collecting_perm_gen是false，而JavaObjectsInPerm默认情况下也是false，表示String.intern返回的字符串是不是在perm里分配，如果是false，表示是在heap里分配的，因此StringTable指向的字符串是在heap里分配的，为了保证处于新生代的String对象不会被回收掉，所以ygc过程需要对StringTable做扫描。

##### YGC过程扫描StringTable对CPU影响大吗？

要回答这个问题我首先得问你们的机器到底有多少个核，如果核数很多的话，其实影响不是很大，因为这个扫描的过程是单个GC线程来做的，所以最多消耗一个核，因此看起来对于核数很多的情况，基本不算什么

##### StringTable什么时候清理？

YGC过程不会对StringTable做清理，但是在Full GC或者CMS GC过程会对StringTable做清理，具体验证很简单，执行下jmap -histo:live <pid>，你将会发现YGC的时候又降下去了。








