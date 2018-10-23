#### getMethods()

##### getMethods()返回的数组，为什么jvm没有保证顺序？

梳理jdk代码，跟到调用了java.lang.Class.getDeclaredMethods0这个native方法，查看jvm实现代码，得知parse_methods就是从class文件里挨个解析出method，并存到_methods数组里，但是接下来做了一次sort_methods的动作，这个动作会对解析出来的方法做排序，Method::sort_methods可以看出其实具体的排序策略是method_comparator，比较的是两个方法的名字，但是这个名字不是一个string，而是一个Symbol对象，每个类或者方法名字都会对应一个Symbol对象，在这个名字第一次使用的时候构建，并且不是在java heap里分配的，比如jdk7里就是在c heap里通过malloc来分配的，jdk8里会在metaspace里分配。

```c++
int Symbol::fast_compare(Symbol* other) const {
 return (((uintptr_t)this < (uintptr_t)other) ? -1
   : ((uintptr_t)this == (uintptr_t) other) ? 0 : 1);
}
```
从上面的fast_compare方法知道，其实对比的是地址的大小，因为Symbol对象是通过malloc来分配的，因此新分配的Symbol对象的地址就不一定比后分配的Symbol对象地址小，也不一定大，因为期间存在内存free的动作，那地址是不会一直线性变化的，之所以不按照字母排序，主要还是为了速度考虑，根据地址排序是最快的。
综上所述，一个类里的方法经过排序之后，顺序可能会不一样，取决于方法名对应的Symbol对象的地址的先后顺序。

##### JVM为什么要对方法排序？

其实这个问题很简单，就是为了快速找到方法，当我们要找某个的方法的时候，根据对应的Symbol对象，能根据对象的地址使用二分查找的算法快速定位到具体的方法。