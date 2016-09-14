### Java Dump

#### Java Dump有什么用途？

JVM的运行时的状态和信息保存到文件。

- 线程Dump：包含所有线程的运行状态。纯文本格式。
- 堆Dump：包含线程Dump，包含所有堆对象的状态。二进制格式。

#### 为什么要用Java Dump？

补足传统Bug分析手段的不足：可在任何Java环境使用，信息量充足。 针对非功能正确性的Bug，主要为:多线程开发、内存泄漏。

#### 如何生成Java Dump？

- 使用JVM生成

在发生内存不足错误时，自动生成堆Dump

```shell
-XX:+HeapDumpOnOutOfMemoryError
```

- 使用GUI生成


    Java VisualVM

- 使用命令生成


    jstack：制作线程dump
    jmap：制作堆dump

