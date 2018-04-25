# redis

## 简单动态字符串(SDS)
SDS(simple dynamic string)
### 1. SDS定义
```c
struct sdshdr {
    int len;
    int free;
    char buf[];
}
```
len(buf) = len + free + 1;
那1个byte是'\0'(空字符)，用于标识字符串结束符。

### 2. SDS与C字符串的区别
#### 2.1 O(1)复杂度获取SDS长度
STRLEN命令获取字符串长度，相比于C字符串，复杂度从O(N)降低到了O(1)。
#### 2.2 杜绝缓冲区溢出(buffer overflow)
strcat(dest, src)
对C字符串执行strcat函数，如果字符串dest剩余空间不够容纳src，src的内容就会覆盖后面的内存区域。
而SDS需要修改时，首先会检查free属性，是否满足修改长度的要求，不用手动修改SDS空间大小。
#### 2.3 减少修改字符串时带来的内存重分配次数
如果做字符串append操作，如果忘了通过内存重分配来扩展数组空间，可能会产生缓冲区溢出。
如果做字符串截断操作，如果不释放字符串不再使用的那段空间，就会产生内存泄露。
内存重分配通常是一个比较耗时的操作，所以对于redis这样数据修改频繁的数据库，是不能忍受的。
为了避免C字符串这种缺陷，SDS里会包含未使用的内存空间。
通过未使用空间，SDS实现了空间预分配，惰性释放空间两种优化策略。

1. 空间预分配
   修改之后，len < 1MB，free=len
   len(buf)=len + free + 1byte，额外1byte保存'\0'
   修改之后，len > 1MB，free=1MB
   len(buf)=len + 1MB + 1byte
   通过预分配策略，SDS将连续增长N次字符串所需的内存重分配次数从必定N次，变为最多N次。

2. 惰性释放空间
   缩短字符串时，并不立即回收多出来的空间，而是使用free属性维护起来。避免了缩短字符串所需的内存重分配操作，并为将来可能发生append操作提供了优化。
   SDS提供了释放未使用空间的API，所以不用担心此策略会造成内存浪费。

#### 2.4 二进制安全
如果把buf数组看做存储C字符串，那字符串中间不能包含'\0'，否则最先被程序读入的'\0'被误认为字符串结尾。这个限制使数组只能保存文本，而不能存储像图片、音频、视频等二进制数据，功能上局限性太小。因此，redis以处理二进制的方式来处理SDS存放在buf的数据。
redis不是用buf数组保存字符，而是保存二进制数据。
SDS使用len属性值而不是空字符来判断字符串是否结束。

#### 2.5 兼容部分C库函数
SDS都是二进制安全的，但它一样遵循C字符串以'\0'结尾，总会把保存数据的末尾设置成'\0'，为了让那些保存文本数据的SDS重用一部分&lt;string.h&gt;库定义的函数。

#### 2.6 重点回顾
- redis只会使用C字符串作为字面量，大多情况下，redis使用SDS作为字符串表示。
- 比起C字符串，SDS有以下优点：
    1. O(1)复杂度获取字符串长度
    2. 杜绝缓冲区溢出
    3. 减少修改字符串长度时所需的内存重分配次数
    4. 二进制安全
    5. 兼容部分C字符串库函数

---
## 链表(linkedlist)
链表被广泛用于实现redis的各种功能，比如key list、发布与订阅、慢查询、监视器等。
redis链表实现是双向链表，链表节点由一个listNode表示。
因为链表的头节点的prev指针和尾节点的next指针都指向null，所以redis的链表实现是无环链表。
通过为链表设置不同的类型特定函数，redis的链表可以用于保存各种不同类型的值。

---

## 字典(hashtable)
符号表(symbol table)、关联数组(associative array)、映射(map)，是一种保存键值对(key-value pair)的抽象数据结构。
redis是key-value数据库，CRUD操作的底层就是用字典实现的。

### dict的扩展与收缩
负载因子：键值对的数量 / 数组的长度
当以下条件任何一个满足，程序会自动开始对dict执行扩容
1. 目前没有执行BGSAVE或BGREWRITEAOF命令，并且dict的负载因子 ≥ 1。
2. 目前正在执行BGSAVE或BGREWRITEAOF命令，并且dict的负载因子 ≥ 5。

dict执行扩容时，所需的负载因子根据BGSAVE或BGREWRITEAOF命令是否正在执行而不同。因为执行命令过程中，redis需要创建当前服务器进程的子进程，而大多数操作系统都采用copy-on-write策略来优化子进程的使用效率。所以在子进程存在期间，服务器会提高执行扩容时负载因子的阀值，这可以避免不必要的写入操作，最大限度节省内存。
当负载因子小于0.1时，程序自动开始对dict执行收缩操作。

### 渐进式rehash
rehash动作并不是一次性、集中式地完成，而是分多次、渐进式地完成。
这样做的好处是，在存储大数据量情况下，庞大的计算量会导致服务器在一段时间内停止服务。
详细步骤：
1. 为ht[1]分配空间，让dict同时拥有ht[0],ht[1]两个table
2. 在dict中维护一个table索引计数器变量rehashidx，并将它的值设为0，表示rehash工作开始。
3. 在rehash期间，每次对dict进行CRUD时，程序除了执行相应操作外，还会顺带将ht[0]table在rehashidx桶索引上的所有元素rehash到ht[1]，rehash工作完成后，rehashidx自增1。
4. 随着CRUD的不断执行，最终在某个时间点上，ht[0]上所有元素都被rehash到ht[1]，这时程序将rehashidx属性值置为-1，表示rehash操作已完成。ht[0]此时为空，数据都在ht[1]中，然后指针互换，ht[1]重新为空。

rehashidx的范围是-1(未rehash状态)，0(开始rehash)，直到table.size-1(rehash完成)。
渐进式rehash执行期间的执行操作
这个期间，dict同时使用ht[0]和ht[1]两个table，dict的修改、删除、查询等操作会在两个table上进行。例如：在dict里查一个元素的话，程序先在ht[0]里进行查找，如果没找到，会继续到ht[1]里进行查找。其他操作类似。
插入操作一律会被保存到ht[1]中，ht[0]不再进行任何插入操作。

### 重点回顾
redis的字典使用hash table作为底层实现，每个字典带有两个table，一个平时使用，一个仅在进行rehash时使用。
当字典被用作数据库的底层实现或key的实现时，使用MurmurHash2算法计算hashCode。
遇到哈希碰撞时，被分配到同一索引上的多个元素会连接成一个单向链表。
对hash table进行扩容或收缩操作时，程序需要将现有hash table的所有元素rehash到新的hash table中，并且这个rehash过程不是一次性地完成，而是渐进式地完成。

---

## 跳跃表(skiplist)
跳跃表是一种有序、不重复的数据结构，它通过在每个节点中维护多个指向其他节点的指针，从而达到快速访问节点的目的。
查找节点的平均时间复杂度O($logN$)、最坏O($N$)，大部分情况下，效率和平衡树相媲美，因为实现起来相比平衡树简单，不少程序用此代替平衡树。
redis只在两个地方用到了跳跃表，一个是sorted sets，另一个是在集群节点中用内部数据结构。

### 跳跃表的实现
#### 跳跃表
zskiplist描述了整个跳跃表的信息
```c
typedef struct zskiplist {
    // 跳跃表的表head节点
    zskiplistNode *header;
    // 跳跃表的表tail节点
    zskiplistNode *tail;
    // 跳跃表中层数最大的节点的层数，head节点不计算在内
    int level;
    // 跳跃表中节点的数量，不包括head节点，因为head节点不存储实际数据
    usigned long length;
} zskiplist;
```

#### 跳跃表节点
zskiplistNode描述了具体的节点信息
```c
typedef struct zskiplistNode {
    // 层
    struct zskiplistLevel {
        // 前进指针，用于访问表尾方向的其他节点
        struct zskiplistNode *forward;
        // 跨度，前进指针指向的节点和current节点的距离
        usigned int span;
    } level[];
    // 后退指针，通过它能实现从tail节点向head节点逆向遍历
    struct zskiplistNode *backward;
    // 分值，节点按照分值升序排序，节点的分值可重复，重复分值的节点，按照SDS字典顺序升序
    double score;
    // 字符串对象，
    robj *obj;
} zskiplistNode;
```
head节点和其他节点的构造是一样的，不过除了level[]属性，其他属性都没用到而已。

#### 跨度
记录了两个节点间的距离，前进指针为null的跨度都为0
注意，跨度和遍历操作无关，只使用forward指针就可以完成了，实际上跨度是用来计算排位(rank)的：其实就是节点在跳跃表中的位置，例如：第一个节点的span是1，最后一个节点的len(skiplist)

#### 重点回顾
redis的跳跃表实现由zskiplist和zskiplistNode两个结构组成，zskiplist保存跳跃表信息，zskiplistNode表示跳跃表节点。
每个节点的层高都是1至32之间的随机数。
同一个跳跃表中，多个节点的字符串对象必须唯一！但可以包含相同的分值。
节点按照分值大小进行排序，当分值相同时，节点按照成员对象的大小排序。

---
## 整数集合(intset)
intset是sets的底层实现之一，当一个集合只包含整型元素，且这个集合的元素数量不多时，会用intset作为底层实现。
特点：数值的数据类型统一，无序，不重复。
127.0.0.1:6379>SADD nums 1 3 5 7
(integer) 4
127.0.0.1:6379>OBJECT ENCODING nums
"intset"

```c
typedef struct intset {
    // 编码方式
    uint32_t encoding;
    // 元素个数，等同于len(contents)
    uint32_t length;
    // 保存数值的数组，元素按升序排列，不包含重复项。
    int8_t contents[];
} intset;
```
contents数组的真正类型取决于encoding属性的值，属性值有：INTSET_ENC_INT16(32767)、INTSET_ENC_INT32、INTSET_ENC_INT64

### 升级
需要升级的场景：将要插入的新元素的类型比现有元素类型都要长时。
升级分3步：
1. 根据新元素数据类型扩展空间，其中包括新元素所占用的空间。
2. 现有元素都转换成和新元素相同的数据类型，将转换后的元素放置在相应位置上，因为C对内存操作很底层，需要对元素移位。
3. 新元素存储到数组末尾，因为新元素的插入才导致数组升级，由此可以推断出，它比现有所有元素都大。
4. 修改encoding、length属性。

向intset添加新元素的时间复杂度为O($N$)，因为每次添加元素都可能会引起升级，每次升级都需要对数组的所有元素进行类型转换。

### 升级的好处
#### intset会更灵活
C是静态语言，为避免类型错误，不会将不同类型的数值放在同一数组。intset可以通过自动升级数组来适应新元素，无论放多大的数进去，不必担心出现类型错误。

#### 节约内存
相对于直接用int64_t类型的数组去实现，intset的升级操作更节省内存，因为只在有需要的时候进行。

### 降级
intset不支持降级，一旦进行了升级，encoding会一直保持升级后的状态。

### 重点回顾
intset的底层实现是数组，以有序、不重复方式保存元素，在有升级需要时，程序会根据新添元素的类型，改变数组类型。
升级操作为intset带来操作上的灵活性，尽可能地节约内存。
intset只支持升级操作，不支持降级。

---
## 压缩列表(ziplist)
ziplist是list和hash的底层实现之一。
使用ziplist存储的场景：
1. list只包含少量元素，且元素占用空间比较小，比如小整数值，长度较短的字符串。
2. hash只包含少量entry，且每个entry的key和value占用空间比较小，比如小整数值，长度短的字符串。

### ziplist的实现
ziplist是redis为了节省内存而开发的，是一组连续的内存区域组成的顺序型的数据结构。一个ziplist可以包含任意个节点，每个节点可以保存一个byte数组或者一个整数。
注意：每个节点的占用的内存空间是不确定的，不定长。

| zlbytes | zltail | zllen | entry1 | entry2 | ...  | entryN | zlend |
| ------- | ------ | ----- | ------ | ------ | ---- | ------ | ----- |
| 4       | 4      | 2     |        |        |      |        | 1     |


zlbytes：4字节，记录整个ziplist占用的内存字节数，对ziplist进行内存重分配或计算zlend的位置时使用。
zltail：4字节，记录ziplist尾节点的起始地址距离ziplist的起始地址有多少字节。通过这个offset，程序无需遍历整个列表就能确定表尾节点的地址。
zllen：2字节，记录ziplist包含的节点数量，当zllen小于UINT16_MAX(65535)时，记录的值是实际的节点数量；当这个值大于65535时，实际节点数需要遍历整个ziplist才能计算出。
entryx：占用内存空间不定，长度由保存内容决定。
zlend：1字节，特殊值0XFF(255)，用于标记ziplist的末端。

### ziplist节点的结构
每个节点都由previous_entry_length、encoding、content三个部分组成。

#### previous_entry_length
此属性以字节为单位，占1字节或5字节，记录了上一个节点占用内存的长度。

- 占1字节的情况：上一个节点的长度小于254字节。
- 占5字节的情况：上一个节点的长度大于等于254字节，其中5个字节的第一个字节会被设置成0xFE(254)，之后的4个字节保存实际的上一个字节的长度。

作用：程序可以通过指针运算，根据当前节点的起始地址计算上一个节点的起始地址。ziplist的逆向遍历就使用这一原理实现的。

#### encoding
该属性记录了content属性所保存的数据类型及长度。

- 长度为1字节、2字节、5字节，值的最高位是00/01/10的是byte数组编码，数组的长度由编码除去最高两位之后的其他位记录。
- 长度为1字节，值的最高位是11的是整数编码：整数的类型和长度由编码除去最高两位后的其他位记录。

具体含义查表。

#### content
该属性保存节点的值，可以是byte数组或者整数，值的类型和长度由节点的encoding属性决定。

### 连锁更新(cascade update)
发生连锁更新的场景：
1. 添加节点：有多个连续的、长度介于250到253字节之间的节点e1至eN，因为所有节点的previous_entry_length属性都是1字节长，这时，将一个长度大于等于254字节的新节点设置为ziplist的表头节点。这时e1节点previous_entry_length属性从原来的1字节扩展为5字节。
2. 删除节点：有多个连续的、长度介于250到253字节之间的节点e1至eN，前面有big和small节点，被删small节点的上一个big节点长度大于等于254字节(5字节的previous_entry_length)，而small节点长度小于254字节(1字节的previous_entry_length)，为了让small的下一个节点的previous_entry_length记录big节点的长度，程序将发生一连串的cascade update。

因为连锁更新在最坏情况下需要对ziplist执行N次空间重分配操作，而每次重分配的最坏复杂度为O($N$)，所以连锁更新的最坏复杂度为O($N^2$)。
不过，尽管连锁更新的复杂度较高，但由于它导致的性能问题的几率还是很低的：
- 首先，ziplist要恰好有多个连续的、长度介于250字节至253字节之间的节点，连锁更新才会被触发，在实际中，这并不常见。
- 其次，即使出现连锁更新，但只要被更新的节点个数不多，就不会对性能造成任何影响。比如说，对三五个节点进行连锁更新是绝对不会影响性能的。

由于以上原因，ziplistPush等命令的平均复杂度仅为O($N$)，实际使用中，可以放心使用这些函数，而不必担心连锁更新会影响ziplist的性能。

### 重点回顾
- ziplist的一种为节约内存而开发的有序的数据结构。
- ziplist是list和hash的底层实现之一。
- ziplist可以包含多个节点，每个节点可以保存一个byte数组或整数。
- 添加节点或删除节点，可能会引发cascade update，但这种情况出现的几率很低。

---
## 对象
redis并没有直接用上面这些数据结构来实现k-v数据库，而是基于这些数据结构创建了一个对象系统，这个对象系统包含了string对象，list对象，set对象，sortedset对象，hash对象这5种类型的对象。每种对象都用到了至少1种前面提到的数据结构。
其次，redis对象系统还实现了基于引用计数的垃圾回收机制，另外，还通过引用计数实现了对象共享机制，这个机制在适当条件下，通过让多个key共享同一个对象来节约内存。
最后，redis对象还记录了访问时间信息，它可以用于计算key的空闲时长，在服务器开启了maxmemory功能时，空闲时长较长的那些key可能会优先被删除。

### 对象的类型和编码
当创建一个k-v记录时，至少会创建两个对象，一个是key对象，一个是value对象。key对象总是string类型。
redis对象由redisObject表示：
```c
typedef struct redisObject {
    // 对象类型
    unsigned type:4;
    // 对象编码
    unsigned encoding:4;
    // 指向底层实现的数据结构的指针
    void *ptr;
} robj;
```

#### 对象类型
使用TYPE命令获取value对象的类型。
例：TYPE key

| 对象       | type属性的值     | TYPE命令的输出 |
| -------- | ------------ | --------- |
| string对象 | REDIS_STRING | "string"  |
| list对象   | REDIS_LIST   | "list"    |
| set对象    | REDIS_SET    | "set"     |
| zset对象   | REDIS_ZSET   | "zset"    |
| hash对象   | REDIS_HASH   | "hash"    |

#### 对象编码和对象底层实现
对象的ptr指针指向对象底层实现的数据结构，而这些数据结构是由encoding属性决定的。也就是说，encoding属性记录了对象是由什么底层数据结构实现的。
redis有8种对象编码，后面对应的是底层实现的数据结构：

- int：long类型
- embstr：embstr编码的SDS
- raw：SDS
- ht：字典(hashtable缩写)
- linkedlist：双向链表
- ziplist：压缩列表
- intset：整数集合
- skiplist：跳跃表和字典

真正的编码常量，前面有REDIS_ENCODING_前缀，比如int的编码常量是REDIS_ENCODING_INT。
每种类型的对象都至少使用了2种不同的编码：

- string: int, embstr, raw
- list: ziplist, linkedlist
- set: intset, ht
- zset: ziplist, skiplist
- hash: ziplist, ht

使用OBJECT ENCODING命令查看对象使用的编码。
例如：OBJECT ENCODING key
通过encoding属性来决定对象使用的编码，极大提升了redis的灵活性和效率，这种做法可以根据不同的使用场景来为同一个对象设置不同的编码，提升效率。
例如：list对象包含元素较少时，用ziplist实现，因为比linkedlist更节省内存，由于元素数量少，在内存中以连续区域保存的ziplist比linkedlist可以更快地被载入到cache。随着包含的元素越来越多，使用ziplist的优势逐渐消失，对象的底层实现从zipllist转向功能更强，更适合保存大量元素的linkedlist上。

底层使用的编码方式，编码的转换条件，同一个命令在多种不同编码上的实现方法。

### string对象
string对象的编码可以是int,raw或embstr。

- 编码是int的情况：value是整数，并且这个整数可以用long类型表示
- 编码是raw的情况：value是字符串，并且长度大于32字节，用SDS保存。
- 编码是embstr的情况：value是字符串，并且长度小于等于32字节，将使用embstr编码的方式来保存字符串。

embstr是专门用于保存长度较短的字符串的一种优化编码，数据结构和raw一样，都使用redisObject和sdshdr来表示string对象。但raw会调用2次申请内存函数分别创建redisObject和sdshdr对象，而embstr编码只调用1次申请内存函数分配一块连续的内存空间，依次包括redisObject和sdshdr对象。
两种编码的string对象执行命令时产生的效果是相同的，但用embstr编码保存短字符串有以下好处：

- 所需内存分配次数从raw编码的2次降低为1次。
- 释放空间时，只需要调用1次。
- string对象的所有数据都保存在一块连续的内存区域，可以比raw编码的string对象更好地利用缓存带来的优势。

raw编码的数据结构
redisObject.ptr->sdshdr->buf 保存字符串的值。
embstr编码的数据结构
redisObject.ptr->buf 保存字符串的值。

浮点数在redis中也是作为字符串来保存的，对浮点数做的一些数值操作，中间会有字符串转浮点数，浮点数转字符串的中间操作。

#### 编码转换
int,embstr编码的字符串在满足一定条件下，会被转换为raw编码。
int：保存的整数，经过一些操作，使得结果不再是整数，而是字符串时，编码将从int变为raw。例如：APPEND操作。
embstr:由于redis没有为embstr编码的字符串对象编写相应的修改函数，只有int和raw编码的string对象有。所以embstr编码的对象实际上是只读的，由于这个原因，embstr编码的字符串在执行修改命令后，总会变成一个raw编码。

### list对象
编码可以是ziplist或linkedlist。
ziplist:ptr指向ziplist的起始地址，ziplist元素的长度和类型可能都不一致。
linkedlist:linkedlist的每个节点保存了一个string对象，string对象保存的是list的元素。
string对象是redis五种类型对象中唯一一种被其他4种类型对象嵌套的。

#### 编码转换
同时满足以下2个条件，list对象才会用ziplist编码：

- 所有字符串元素长度都小于64字节
- 元素数量小于512个

不能满足这2个条件的list对象需要使用linkedlist编码。
注：以上两个条件的上限值是可以修改的，配置文件中关于list-max-ziplist-value和list-max-ziplist-entries。

### set对象
编码可以是intset或hashtable。
intset:set对象包含的所有元素保存在intset里。
hashtable:hashtable的每个key都是string对象，对象包含了1个set元素，value全部设置为null。

#### 编码转换
同时满足以下2个条件，set对象才会用intset编码：

- 所有元素都是整数
- 元素数量小于512个

不能满足这2个条件的set对象需要使用hashtable编码。
注：第二个条件的上限值是可以修改的，配置文件中关于set-max-intset-entries。

### zset对象
编码可以是ziplist或skiplist。
ziplist:每个元素使用两个ziplist节点保存，zset的元素值在前，分值在后，两个节点总是紧挨在一起。ziplist内的zset元素按分值升序排序。
skiplist:使用zset类型作为底层实现，此类型包含1个dict和1个skiplist。
```c
typedef struct zset {
    zskiplist *zsl;
    dict *dict;
} zset;
```
zsl跳跃表按分值升序保存了所有集合元素，每个skiplist节点的object属性保存了元素的内容，score属性保存了元素的分值。通过skiplist，可以对zset进行范围型操作，比如ZRANK、ZRANGE等命令就是基于skiplist的API来实现的。
除此之外，dict维护了zset元素和分值的映射，dict的key保存元素内容，value保存元素分值。通过dict属性，可以用O(1)复杂度查找给定元素的分值，ZSCORE命令就是根据这一特性实现的。
zset的每个元素都是string对象，分值都是double类型浮点数。
注意：虽然zset结构同时使用skiplist和dict来保存，但两种数据结构都会通过指针来共享相同元素内容和分值，不会浪费额外的内存。

#### 编码转换
同时满足以下2个条件，zset对象才会用ziplist编码：

- 所有元素内容的长度都小于64字节
- 元素数量小于128个

不能满足这2个条件的set对象需要使用skiplist编码。
注：第二个条件的上限值是可以修改的，配置文件中关于zset-max-ziplist-value和zset-max-ziplist-entries。

### hash对象
编码可以是ziplist或hashtable。
ziplist:ptr指向ziplist的起始地址，向hash对象插入键值对时，总是把k,v对象推入ziplist表尾，k对象在前，v对象随后，两个节点总是紧挨在一起。
hashtable:hash对象的kv对都使用一个dict entry来保存。entry的key是一个string对象，value也是一个string对象。

#### 编码转换
同时满足以下2个条件，hash对象才会用ziplist编码：

- 所有key和value的字符串长度都小于64字节
- entry元素数量小于512个

不能满足这2个条件的hash对象需要使用hashtable编码。
注：以上两个条件的上限值是可以修改的，配置文件中关于hash-max-ziplist-value和hash-max-ziplist-entries。

### 类型检查与命令多态
redis用于操作key的命令分为2种类型：
1. 对任何类型的key都可以执行，比如DEL、EXPIRE、RENAME、TYPE、OBJECT
2. 只能对特定类型的key执行，比如
   SET GET APPEND STRLEN    只能对string
   RPUSH LPOP LINSERT LLEN  只能对list
   SADD SPOP SINTER SCARD   只能对set
   ZADD ZCARD ZRANK ZSCORE  只能对zset
   HDEL HSET HGET HLEN      只能对hash

#### 类型检查的实现
在执行类型特有的命令前，先检查是否和对象的类型匹配。
检查的是redisObject类型的type属性。

#### 多态命令的实现
LLEN命令的多态：无论list对象使用的是ziplist编码还是linkedlist编码，命令都可以执行。
我们可以将DEL、EXPIRE、TYPE等命令也称为多态命令，因为无论输入的key是什么类型，这些命令都可以正确地执行。
DEL、EXPIRE、TYPE等命令和LLEN的区别在于：前者是基于类型的多态，后者是基于编码的多态。

### 内存回收
利用redisObject类型的refcount属性记录引用计数。

- 创建新对象时，计数值初始化为1
- 当对象被1个新程序使用时，count+1
- 当对象不再被1个程序使用时，count-1
- 当对象的refcount变为0时，占用的内存会被释放

对象的整个生命周期可以划分为创建对象、操作对象、释放对象三个阶段。

### 对象共享
对象的计数引用除了实现内存回收机制外，还带有对象共享的作用。
目前，redis会在初始化时，创建1万个string对象，这些对象包含了从0到9999的所有数值。
注意：通过修改redis.h/REDIS_SHARED_INTEGERS常量实现初始化对象个数。
可以用OBJECT REFCOUNT key命令查看对象被引用的次数。
另外，这些共享的string对象不单单只有key可以复用，那些嵌套了string对象的对象，都可以使用这些共享对象。例如：linkedlist编码的list对象,hashtable编码的hash对象和set对象，zset编码的zset对象。
为什么不共享这些复合对象？
相比于节省的内存成本，CPU计算成本太高。

### 对象空闲时长
redisObject类型的unsigned lru:22属性
OBJECT IDLETIME key命令可以查看空闲时长
OBJECT IDLETIME命令的实现是特殊的，用它访问key时，不会修改对象的lru属性。
空闲时长还有一个作用：
如果服务器打开了maxmemory选项，并且服务器用于回收内存的算法是volatile-lru或allkeys-lru，那么当redis占用的内存超过了maxmemory选项设置的上限时，空闲时长较高的部分key优先被回收。

### 重点回顾
- redis的key和value都是1个对象，key是string对象。
- redis共有string、list、set、zset、hash五种类型的对象，每种类型的对象至少有两种以上的编码方式，不同的编码方式在不同的使用场景上对执行效率有优化。
- redis在执行某些命令前，首先检查给定value的类型能否执行该命令
- redis的共享值为0到9999的string对象
- 对象会记录自己的最后一次被访问的时间，这个时间可以用于计算对象的空闲时间。

---
## 数据库

### redis的db
redis将所有db都保存在redis.h/redisServer类的db数组中，db数组的每个元素都是redis.h/redisDb类型，每个redisDb代表一个db。
初始化redis时，程序会根据redisServer的dbnum属性来决定应该创建多少个db：
```c
struct redisServer {
    // ...
    // redis的db数量
    int dbnum;
    // ...
}
```
dbnum属性值由redis配置的database选项决定，默认值是16，所以redis默认会创建16个db。

### 切换db
默认情况下，redis客户端访问目标db为0号db，可以通过select命令切换db。
```c
typedef struct redisClient {
    // ...
    // 记录client当前使用的db
    redisDb *db;
    // ...
} redisClient;
```
redisClient.db属性指向redisServer.db数组其中一个元素，被指向的元素就是client的目标db。
注意：redis目前没有返回client端正在访问目标db的命令，但redis-cli会在输入符旁边提示。为避免对数据库的误写操作，最好先执行select命令，显式切换到指定db。

### db的key空间
每个数据库用redisDb类表示，其中redisDb的dict属性保存了db的所有k-v对，我们将这个dict称为键空间(key space)。
```c
typedef struct redisDb {
    // db的key空间，保存着db的所有k-v
    dict *dict;
} redisDb;
```
key空间和用户所见的db是直接对应：

- key space的key就是db的key，每个key都是string对象
- key space的value也就是db的value，每个value可以是5种数据类型任意一种。
  对数据库的CRUD实际就是对dict的CRUD。

#### 读写key space时的维护操作
redis对db进行读写时，不仅会会执行相应的读写操作，还会执行一些额外的维护操作，包括：

- 读写都要读取key，读取一个key后，redis会根据key是否存在来更新keyspace hit和miss次数，这两个值在INFO stat命令的keyspace_hit和keyspace_miss属性查看。
- 读取一个key后，会更新redisObject类型的unsigned lru:22属性，用来计算空闲时长，使用OBJECT idletime key查看空闲时间。
- 如果读取一个key时发现该key已过期，那么会删除这个过期key
- 如果有client使用WATCH命令监视某个key，那么redis对这个key修改后，会将这个key标记为dirty，从而让事务程序注意到这个key已经被修改了。
- redis每修改key时，都会对dirty key计数器加1，计数器会触发redis的持久化和复制操作。
- 如果redis开通了db通知功能，那么对key修改后，redis将按配置发送相应的db通知。

### 设置key的生存时间(TTL)和过期时间
用EXPIRE或PEXPIRE命令，以秒或毫秒精度为db的某个key设置TTL(Time To Live，生存时间)，经过指定时间，redis会自动删除TTL为0的key。
SETEX命令可以在设置一个key的同时设置过期时间，但只能用于value为string的key，原理和EXPIRE命令设置过期时间的原理完全一样。
可以通过EXPIREAT和PEXPIREAT命令，比上面的命令多了at，以秒或毫秒精度给db中的某个key设置过期时间(expire time)。
TTL和PTTL命令接受一个带有TTL或expire time的key，返回key的剩余TTL，也就是距离被删除还有多长时间。

#### 设置过期时间
EXPIRE key ttl
PEXPIRE key ttl
EXPIREAT key timestamp
PEXPIREAT key timestamp
实际上其他3个命令都是以PEXPIREAT命令实现的，命令转化步骤：
EXPIRE->PEXPIRE->PEXPIREAT
EXPIREAT->PEXPIREAT

#### 保存过期时间
```c
typedef struct redisDb {
    // 过期字典，保存着所有key的过期时间
    dict *expires;
} redisDb;
```
dict类型的expires属性称为过期字典：

- 过期字典的key是一个指针，指向key space中的某个key对象。
- 过期字典的value是一个long整数，保存了key的过期时间，毫秒精度的时间戳。
  上面4个设置过期时间的命令会添加或修改expire属性。

PEXPIREAT命令伪代码：
```python
def PEXPIREAT(key, expire_time_in_ms):
    # 如果给的的key不在key space，就不能设置过期时间
    if key not in redisDb.dict:
        return 0
    # 在过期字典中关联key和过期时间
    redisDb.expires[key] = expire_time_in_ms
    # 过期时间设置成功
    return 1
```

#### 移除过期时间
PERSIST命令移除key的过期时间，实际上移除expire属性中关联key的过期信息。
```python
def PERSIST(key):
    # 如果过期字典不存在key，直接返回
    if key not in redisDb.expires:
        return 0
    # 移除过期字典中给定key的关联
    redisDb.expires.remove(key)
    # 过期时间移除成功
    return 1
```

#### 计算并返回剩余生存时间
TTL和PTTL两个命令都是通过计算key的过期时间和当前时间的差来实现。

#### 过期key的判定
逻辑：

- 检查key在过期字典是否存在，如果存在，取得key的过期时间。
- 检查当前时间戳是否大于key的过期时间，如果是的话，那么key已经过期，否则key未过期。

注：用TTL或PTTL命令判定key过期，如果返回值大于等于0，说明key未过期，实际上会访问过期字典，因为直接访问字典比执行命令稍微快些。

### 过期key删除策略
如果一个key过期了，那它什么时候被删除呢？
1. 定时删除：设置key的过期时间同时，创建一个timer(定时器)，让定时器在key的过期时间到来时，立即执行删除操作。
2. 惰性删除：对key是否过期放任不管，但每次取key时，都检查取得的key是否过期，如果过期，就删除；没过期，则返回。
3. 定期删除：每隔一段时间，程序就对db进行一次扫描，删除里面的过期key。至于删除多少过期key，及检查多少个db，由算法决定。

#### 定时删除
对内存友好，能保证key尽快的删除。对CPU不友好，key比较多时，删除key会占用相当一部分CPU时间。
创建一个定时器需要用到redis中的时间事件，实现方式是无序链表，查找一个事件的时间复杂度为O($N$)，不能高效处理大量的时间事件。
因此，让服务器创建大量的定时器，实现定时删除策略，不现实。

#### 惰性删除
对CPU友好，只会在取出key时才对key进行过期检查，不会在删除其他无关的过期key上花费任何CPU时间。对内存不友好，该删除的key却还驻留在内存中，相当于内存泄露。
对于一些和时间相关的数据，比如log，在某个时间点后，对它们的访问就会大大减少，甚至不再访问，这类数据大量地积压在db中，造成后果非常严重。

#### 定期删除
从上面对定时删除和惰性删除的分析，这两种方式在单一使用时都有明显缺陷：

- 定时删除占用太多CPU时间，影响服务器的响应时间和吞吐量。
- 惰性删除浪费太多内存，有内存泄露的危险。

定期删除是两种方式的折中和整合：

- 每隔一段时间执行1次删除过期key，并通过限制删除操作执行的时间和频率来减少对CPU时间的影响。
- 有效减少了因过期key而带来的内存浪费。

难点是确定删除操作的执行时间和频率：

- 执行的太频繁，或时间太长，定期删除策略会退化成定时删除策略，过于消耗CPU
- 执行次数太少，或时间太短，又会和惰性删除策略应用，出现内存浪费情况。

因此，如果采用定期删除策略，服务器必须根据实际情况，合理设置删除操作的执行时间和执行频率。

### redis的过期key删除策略


