#### 正则是什么？

定义了字符串的模式。

#### 正则用来做什么？

正则的应用极其广泛，可以轻松解决很多场景下字符串搜索、编辑或处理文本。

#### Java中正则涉及到的类

并不仅限于某一种语言，但是在每种语言中有细微的差别。Java 正则表达式和 Perl 的是最为相似的。

在java.util.regex 包下，主要包括以下三个类：

- **Pattern 类**：表示某个具体的正则表达式，没有public的构造方法，创建Pattern对象:Pattern.compile()
- **Matcher 类：**对输入字符串进行解释和匹配操作的引擎。创建Matcher对象:Matcher matcher = pattern.matcher(line);
- **PatternSyntaxException类：**非检查异常，表示一个正则表达式模式中的语法错误。

##### 常用类使用方法

```java
/**
 * 创建Pattern对象:Pattern.compile()
 * 创建Matcher对象:Matcher matcher = pattern.matcher(line);
 * matcher.find()看是否有匹配,如果有返回true,会继续往下找
 */
@Test
public void base() {
  String line = "ab,cyzab,ccxxxab,c";
  String patternStr = "b\\,c";
  Pattern pattern = Pattern.compile(patternStr);
  // 第一个参数是正则表达式，第二个是编译选项，可以同时指定多个
  Pattern pattern1 = Pattern.compile(patternStr, Pattern.CASE_INSENSITIVE | Pattern.DOTALL);
  Matcher matcher = pattern.matcher(line);
  boolean isMatches = matcher.matches();
  System.out.printf("@_@--isMatches-->%s\n", isMatches);
}

@Test
public void pattern_matches() {
  // 转发了Matcher.matches()
  boolean isMatches = Pattern.matches("\\d+", "124");
  System.out.printf("@_@--isMatches-->%s\n", isMatches);
}

@Test
public void pattern_quote() {
  // quote(),块转义,类似sql预编译.防止字符被看做正则中的关键字.
  // 正则：\Q[1]\E，表示的是匹配一对方括号，里面有一个数字1，而不是只有数字1的字符组。
  // 在搜索功能的一些用户输入，但这个输入可能不安全字符所以你可以使用下面的方式:
  // Pattern pattern = Pattern.compile(Pattern.quote(userInput));
  String quote = Pattern.quote("[a-z]+\\d{3,5}AAA");
  System.out.printf("@_@--quote-->%s\n", quote);
  Pattern pattern = Pattern.compile(quote);
  System.out.printf("@_@--pattern.pattern()-->%s\n", pattern.pattern());
}

@Test
public void pattern_split() {
  String patternStr = "b\\,c";
  Pattern pattern = Pattern.compile(patternStr);
  String line = "ab,cyzab,ccxxxab,c";
  // pattern.split(字符串)  对当前字符串用r分隔
  String[] strArray = pattern.split(line);
  System.out.printf("@_@--strArray-->%s\n", Arrays.toString(strArray));

  // String.split()对正则表达式内部优化:
  /*
  fastpath if the regex is a
       (1)one-char String and this character is not one of the
          RegEx's meta characters ".$|()[{^?*+\\", or
       (2)two-char String and the first char is the backslash and
          the second is not the ascii digit or ascii letter.
  */
  strArray = line.split("b\\,c");
  System.out.printf("@_@--strArray-->%s\n", Arrays.toString(strArray));
}

@Test
public void matcher() {
  String patternStr = "b\\,c";
  Pattern pattern = Pattern.compile(patternStr);
  String line = "ab,cyzab,ccxxxab,c";
  Matcher matcher = pattern.matcher(line);
  //==============================================查找================================================
  // Matcher.find()尝试查找匹配子串,查找结果bool类型
  // Matcher.start()类似String.indexOf(),找到匹配子串起始处的索引,不过这个可以连续匹配多次
  while (matcher.find()) {
    int startIndex = matcher.start();
    System.out.printf("@_@--start-->%s\n", startIndex);
  }

  // boolean find(int start),重置此Mather,尝试查找从指定索引开始匹配的子串
  if (matcher.find(0)) {
    int startIndex = matcher.start();
    System.out.printf("@_@--start-->%s\n", startIndex);
  }
  while (matcher.find()) {
    int startIndex = matcher.start();
    System.out.printf("@_@--start-->%s\n", startIndex);
  }

  // 重置matcher,意味着可以复用,另外:matcher.reset(input)可以用不同的输入字符串去匹配正则,节省内存开销
  matcher.reset();
  // Matcher.end(),找到匹配子串末尾的索引,可以连续匹配多次
  while (matcher.find()) {
    int startIndex = matcher.end();
    System.out.printf("@_@--end-->%s\n", startIndex);
  }

  matcher.reset();
  // matches(),尝试将整个字符串去匹配正则
  boolean isMatch = matcher.matches();
  System.out.printf("@_@--matches-->%s\n", isMatch);

  matcher.reset("b,cyzab,ccxxxab,c");
  // lookingAt(),尝试从字符串开始匹配正则
  boolean lookingAt = matcher.lookingAt();
  System.out.printf("@_@--lookingAt-->%s\n", lookingAt);

  //==============================================替换================================================
  matcher.reset(line);
  String replaceFirstStr = matcher.replaceFirst("@");
  System.out.printf("@_@--replaceFirst-->%s\n", replaceFirstStr);

  // String.replaceFirst()内部就一行代码:Pattern.compile(regex).matcher(this).replaceFirst(replacement);
  // 效率肯定低于缓存住Pattern和Matcher的方式
  replaceFirstStr = line.replaceFirst(patternStr, "@");
  System.out.printf("@_@--String.replaceFirst-->%s\n", replaceFirstStr);

  String replaceAllStr = matcher.replaceAll("@");
  System.out.printf("@_@--replaceAllStr-->%s\n", replaceAllStr);

  // String.replaceAll()内部就一行代码:Pattern.compile(regex).matcher(this).replaceAll(replacement);
  // 效率肯定低于缓存住Pattern和Matcher的方式
  replaceAllStr = line.replaceAll(patternStr, "@");
  System.out.printf("@_@--String.replaceAll-->%s\n", replaceAllStr);

  //==============================================匹配成功后append================================================
  matcher.reset();
  StringBuffer stringBuffer = new StringBuffer();
  StringBuffer stringBufferTail = new StringBuffer();
  while (matcher.find()) {
    // appendReplacement(),stringBuffer追加从上一次匹配成功的end index开始,一直到本次匹配成功的startIndex,然后再追加替换的字符串,返回matcher自身
    Matcher matcher1 = matcher.appendReplacement(stringBuffer, "#");
    System.out.printf("@_@--appendReplacement-->%s\n", stringBuffer);
    // appendTail(),stringBuffer追加从本次匹配成功的end index开始,一直到字符串末尾,返回stringBuffer自身
    matcher.appendTail(stringBufferTail);
    System.out.printf("@_@--appendTail-->%s\n", stringBufferTail);
  }

  //==============================================扫描================================================
  matcher.reset("12a34");
  // usePattern(),更换正则,返回mather自身
  matcher.usePattern(Pattern.compile("\\d+"));
  // hitEnd(),hitEnd=true，并且之前是能找到匹配的，但是继续输入字符串，结果有可能变为无法找到匹配。
  // 如果为false，继续输入则不会改变匹配结果。
  boolean isHitEnd = matcher.hitEnd();
  System.out.printf("@_@--isHitEnd-->%s\n", isHitEnd);
  // requireEnd()
  // 如果为true，继续输入可能导致之前的丢失之前的匹配结果
  // 如果为false，并且找到了匹配，更多的输入可能会导致之前的匹配内容改变，但是结果不会改变；如果没有找到匹配，那么此变量无意义。
  boolean isRequireEnd = matcher.requireEnd();
  System.out.printf("@_@--requireEnd-->%s\n", isRequireEnd);

}

/**
 * 设置边界的检查
 */
@Test
public void matcher_region() {
  String patternStr = "(?<=a)b";
  Pattern pattern = Pattern.compile(patternStr);
  String str = "abcde";
  Matcher matcher = pattern.matcher(str);
  // region(),为字符串设置边界,返回matcher自身
  matcher.region(1, 5);
  // regionStart(),获取边界起始索引
  int regionStart = matcher.regionStart();
  System.out.printf("@_@--regionStart-->%s\n", regionStart);
  // regionEnd(),获取边界末尾索引
  int regionEnd = matcher.regionEnd();
  System.out.printf("@_@--regionEnd-->%s\n", regionEnd);

  /*
  目标字符串为abcde，要查找b，但是要求b的前面是a。
  如果边界设置为[1,5]，也就是在bcde中查找，那默认情况下是匹配不到结果的，因为b已经在边界上了
  但是如果允许在边界外检查，那么这里的b就符合要求
  */
  // hasTransparentBounds(),默认false,边界不透明,意味着不允许检查边界之外的字符
  boolean hasTransparentBounds = matcher.hasTransparentBounds();
  System.out.printf("@_@--hasTransparentBounds-->%s\n", hasTransparentBounds);
  System.out.printf("@_@--close TransparentBounds find-->%s\n", matcher.find());

  matcher.reset();
  // useTransparentBounds(),如果设置了边界,当环视查找时,允许检查边界外的字符,设置为true,返回matcher自身
  matcher.useTransparentBounds(true);
  System.out.printf("@_@--open TransparentBounds find-->%s\n", matcher.find());

  // useTransparentBounds(true)后再去reset()，hasTransparentBounds并没有改变
  matcher.reset();
  hasTransparentBounds = matcher.hasTransparentBounds();
  System.out.printf("@_@--hasTransparentBounds-->%s\n", hasTransparentBounds);


  // hasAnchoringBounds(),默认true,使用了锚边界
  boolean hasAnchoringBounds = matcher.hasAnchoringBounds();
  System.out.printf("@_@--hasAnchoringBounds-->%s\n", hasAnchoringBounds);

  // useAnchoringBounds(),返回matcher自身
  /*
    Using anchoring bounds, the boundaries of this matcher's region match anchors such as ^ and $.
    Without anchoring bounds, the boundaries of this matcher's region will not match anchors such as ^ and $.
  */
  matcher.useAnchoringBounds(false);
}

@Test
public void matcher_quoteReplacement() {
  // quoteReplacement(),字符串中出现反斜杠'\'或'$'统一在前面加上'\',Matcher类唯一的静态方法.
  String quoteReplacement = Matcher.quoteReplacement("a\\bc\\de$f$g");
  System.out.printf("@_@---->%s\n", quoteReplacement);
}
```

##### 捕获分组(group)

###### 定义

把多个字符当一个单独单元进行处理的方法，它通过括号对字符分组来创建。例如，正则表达式 (dog) 创建了单一分组，组里包含"d"，"o"，和"g"。

###### 捕获组编号

捕获组是通过从左至右计算其左开括号来编号。例如，在表达式((A)(B(C)))，有四个这样的组：

```
((A)(B(C)))
(A)
(B(C))
(C)
```

通过调用 Matcher.groupCount()来查看表达式有多少个分组。组0总是代表了整个表达式。

```java
@Test
public void matcher_group() {
  // String to be scanned to find the pattern.
  String line = "This order was placed for QT3000! OK?";
  String patternStr = "(\\D*)(\\d+)(.*)";
  // Create a Pattern object
  Pattern pattern = Pattern.compile(patternStr);
  // Now create matcher object.
  Matcher matcher = pattern.matcher(line);
  if (matcher.find()) {
    System.out.println("Found groupCount: " + matcher.groupCount());
    // 组0总是代表了整个表达式。
    System.out.println("Found value: " + matcher.group(0));
    System.out.println("Found value: " + matcher.group(1));
    System.out.println("Found value: " + matcher.group(2));
    System.out.println("Found value: " + matcher.group(3));
  } else {
    System.out.println("NO MATCH");
  }
}
```

Pattern类编译选项

| 编译标志                 | 效果                                       |
| -------------------- | ---------------------------------------- |
| CANON_EQ             | 当且仅当两个字符的"正规分解(canonical decomposition)"都完全相同的情况下，才认定匹配。比如用了这个标志之后，表达式"a/u030A"会匹配"?"。默认情况下，不考虑"规范相等性(canonical equivalence)"。 |
| CASE_INSENSITIVE(?i) | 默认情况下，大小写不明感的匹配只适用于US-ASCII字符集。这个标志能让表达式忽略大小写进行匹配。要想对Unicode字符进行大小不明感的匹配，只要将UNICODE_CASE与这个标志合起来就行了。 |
| COMMENTS(?x)         | 在这种模式下，匹配时会忽略(正则表达式里的)空格字符(注：不是指表达式里的"//s"，而是指表达式里的空格，tab，回车之类)。注释从#开始，一直到这行结束。可以通过嵌入式的标志来启用Unix行模式。 |
| DOTALL(?s)           | 在这种模式下，表达式'.'可以匹配任意字符，包括表示一行的结束符。默认情况下，表达式'.'不匹配行的结束符。 |
| MULTILINE(?m)        | 在这种模式下，'^'和'$'分别匹配一行的开始和结束。此外，'^'仍然匹配字符串的开始，'$'也匹配字符串的结束。默认情况下，这两个表达式仅仅匹配字符串的开始和结束。 |
| UNICODE_CASE(?u)     | 在这个模式下，如果你还启用了CASE_INSENSITIVE标志，那么它会对Unicode字符进行大小写不明感的匹配。默认情况下，大小写不明感的匹配只适用于US-ASCII字符集。 |
| UNIX_LINES(?d)       | 在这个模式下，只有'/n'才被认作一行的中止，并且与'.'，'^'，以及'$'进行匹配。 |

#### 基本语法

**注意**：根据 Java Language Specification 的要求，Java 源码的字符串中的'\'被解释为 Unicode 转义或其他字符转义。**因此必须在字符串字面量中使用'\\\'，表示正则表达式受到保护，不被编译器转义。**例如，当解释正则表达式时，字符串字面值 "\b" 与单个退格字符匹配，而 "\\\b" 与单词边界匹配。字符串字面值 "\\(hello\\)" 是非法的，将导致编译时错误；要与字符串 (hello) 匹配，必须使用字符串字面值 "\\\\(hello\\\\)"。

| **字符**        | **说明**                                   |
| ------------- | ---------------------------------------- |
| \             | 将下一字符标记为特殊字符、文本、反向引用或八进制转义符。例如，"n"匹配字符"n"。"\n"匹配换行符。序列"\\\"匹配"\"，"\\("匹配"("。 |
| ^             | 匹配输入字符串开始的位置。如果设置了 **RegExp** 对象的 **Multiline** 属性，^ 还会与"\n"或"\r"之后的位置匹配。 |
| $             | 匹配输入字符串结尾的位置。如果设置了 **RegExp** 对象的 **Multiline** 属性，$ 还会与"\n"或"\r"之前的位置匹配。 |
| *             | 零次或多次匹配前面的字符或子表达式。例如，zo* 匹配"z"和"zoo"。* 等效于 {0,}。 |
| +             | 一次或多次匹配前面的字符或子表达式。例如，"zo+"与"zo"和"zoo"匹配，但与"z"不匹配。+ 等效于 {1,}。 |
| ?             | 零次或一次匹配前面的字符或子表达式。例如，"do(es)?"匹配"do"或"doesa"中的"does"。? 等效于 {0,1}。 |
| {*n*}         | n 是非负整数。正好匹配 n 次。例如，"o{2}"与"Bob"中的"o"不匹配，但与"food"中的两个"o"匹配。 |
| {*n*,}        | n 是非负整数。至少匹配 n 次。例如，"o{2,}"不匹配"Bob"中的"o"，而匹配"foooood"中的所有 o。'o{0,1}' 等效于 'o?'。"o{1,}"等效于"o+"。"o{0,}"等效于"o\*"。 |
| {*n*,*m*}     | *M* 和 *n* 是非负整数，其中 *n* <= *m*。匹配至少 *n* 次，至多 *m* 次。例如，"o{1,3}"匹配"fooooood"中的头三个 o。注意：**不能将空格插入逗号和数字之间**。 |
| ?             | 当此字符紧随任何其他限定符（\*、+、?、{*n*}、{*n*,}、{*n*,*m*}）之后时，匹配模式是"非贪心的"。"非贪心的"模式匹配搜索到的、尽可能短的字符串，而默认的"贪心的"模式匹配搜索到的、尽可能长的字符串。例如，在字符串"oooo"中，"o+?"只匹配单个"o"，而"o+"匹配所有"o"。 |
| .             | 匹配除"\r\n"之外的任何单个字符。若要匹配包括"\r\n"在内的任意字符，请使用诸如"[\s\S]"之类的模式。 |
| (*pattern*)   | 匹配 *pattern* 并捕获该匹配的子表达式。可以使用 **$0…$9** 属性从结果"匹配"集合中检索捕获的匹配。若要匹配括号字符 ( )，请使用"\\("或者"\\)"。 |
| (?:*pattern*) | 匹配 *pattern* 但不捕获该匹配的子表达式，即它是一个非捕获匹配，不存储供以后使用的匹配。这对于用"or"字符 (\|) 组合模式部件的情况很有用。例如，'industr(?:y\|ies) 是比 'industry\|industries' 更经济的表达式。 |
| (?=*pattern*) | 执行正向预测先行搜索的子表达式，该表达式匹配处于匹配 *pattern* 的字符串的起始点的字符串。它是一个非捕获匹配，即不能捕获供以后使用的匹配。例如，'Windows (?=95\|98\|NT\|2000)' 匹配"Windows 2000"中的"Windows"，但不匹配"Windows 3.1"中的"Windows"。预测先行不占用字符，即发生匹配后，下一匹配的搜索紧随上一匹配之后，而不是在组成预测先行的字符后。 |
| (?!*pattern*) | 执行反向预测先行搜索的子表达式，该表达式匹配不处于匹配 *pattern* 的字符串的起始点的搜索字符串。它是一个非捕获匹配，即不能捕获供以后使用的匹配。例如，'Windows (?!95\|98\|NT\|2000)' 匹配"Windows 3.1"中的 "Windows"，但不匹配"Windows 2000"中的"Windows"。预测先行不占用字符，即发生匹配后，下一匹配的搜索紧随上一匹配之后，而不是在组成预测先行的字符后。 |
| *x*\|*y*      | 匹配 *x* 或 *y*。例如，'z\|food' 匹配"z"或"food"。'(z\|f)ood' 匹配"zood"或"food"。 |
| [*xyz*]       | 字符集。匹配包含的任一字符。例如，"[abc]"匹配"plain"中的"a"。  |
| [^*xyz*]      | 反向字符集。匹配未包含的任何字符。例如，"\[^abc]"匹配"plain"中"p"，"l"，"i"，"n"。 |
| [*a-z*]       | 字符范围。匹配指定范围内的任何字符。例如，"[a-z]"匹配"a"到"z"范围内的任何小写字母。 |
| [^*a-z*]      | 反向范围字符。匹配不在指定的范围内的任何字符。例如，"\[^a-z]"匹配任何不在"a"到"z"范围内的任何字符。 |
| \b            | 匹配一个字边界，即字与空格间的位置。例如，"er\b"匹配"never"中的"er"，但不匹配"verb"中的"er"。 |
| \B            | 非字边界匹配。"er\B"匹配"verb"中的"er"，但不匹配"never"中的"er"。 |
| \c*x*         | 匹配 *x* 指示的控制字符。例如，\cM 匹配 Control-M 或回车符。*x* 的值必须在 A-Z 或 a-z 之间。如果不是这样，则假定 c 就是"c"字符本身。 |
| \d            | 数字字符匹配。等效于 [0-9]。                        |
| \D            | 非数字字符匹配。等效于 \[^0-9]。                     |
| \f            | 换页符匹配。等效于 \x0c 和 \cL。                    |
| \n            | 换行符匹配。等效于 \x0a 和 \cJ。                    |
| \r            | 匹配一个回车符。等效于 \x0d 和 \cM。                  |
| \s            | 匹配任何空白字符，包括空格、制表符、换页符等。与 [ \f\n\r\t\v] 等效。 |
| \S            | 匹配任何非空白字符。与 \[^ \f\n\r\t\v] 等效。          |
| \t            | 制表符匹配。与 \x09 和 \cI 等效。                   |
| \v            | 垂直制表符匹配。与 \x0b 和 \cK 等效。                 |
| \w            | 匹配任何字类字符，包括下划线。与"[A-Za-z0-9_]"等效。        |
| \W            | 与任何非单词字符匹配。与"\[^A-Za-z0-9_]"等效。          |
| \Q            | 引用字符的初始，结束于\E                            |
| \E            | 结束由\Q开始的引用                               |
| \x*n*         | 匹配 *n*，此处的 *n* 是一个十六进制转义码。十六进制转义码必须正好是两位数长。例如，"\x41"匹配"A"。"\x041"与"\x04"&"1"等效。允许在正则表达式中使用 ASCII 代码。 |
| \\*num*       | 匹配 *num*，此处的 *num* 是一个正整数。到捕获匹配的反向引用。例如，"(.)\1"匹配两个连续的相同字符。 |
| \\*n*         | 标识一个八进制转义码或反向引用。如果 \\*n* 前面至少有 *n* 个捕获子表达式，那么 *n* 是反向引用。否则，如果 *n* 是八进制数 (0-7)，那么 *n* 是八进制转义码。 |
| \\*nm*        | 标识一个八进制转义码或反向引用。如果 \\*nm* 前面至少有 *nm* 个捕获子表达式，那么 *nm* 是反向引用。如果 \\*nm* 前面至少有 *n* 个捕获，则 *n* 是反向引用，后面跟有字符 *m*。如果两种前面的情况都不存在，则 \\*nm* 匹配八进制值 *nm*，其中 n 和 m 是八进制数字 (0-7)。 |
| \nml          | 当 *n* 是八进制数 (0-3)，*m* 和 *l* 是八进制数 (0-7) 时，匹配八进制转义码 *nml*。 |
| \u*n*         | 匹配 *n*，其中 *n* 是以四位十六进制数表示的 Unicode 字符。例如，\u00A9 匹配版权符号 (©)。 |

#### 正则调优

**首先要统一观点**：能不用正则解决的，尽量不要用正则。简单字符串处理应避免使用正则表达式。

优化代码

##### 缓存Pattern、Matcher对象

避免直接使用Pattern.matches()，因为每一次调用都要编译正则表达式，而编译阶段是相对耗时的。

调用Matcher.reset(string)对不同待匹配的字符串重复利用Matcher对象。



优化正则才是王道

关于分支场景，类似：(X|Y|Z)

##### 减少选择分支

##### 最常出现的字符放在分支最前面

##### 能懒则懒，不要贪婪

\*＋{m,n}后面加上'?'就会变成非贪婪模式。

##### 减少捕获分组，尽量使用非捕获性分组

如果不需要引用括号内文本的时候，使用非捕获分组。例如使用"(?:X)"代替"(X)"。捕获性分组为额外消耗内存记录分组的信息和状态。

##### 语法优化

用0-9代替\d，在循环10w次随机挑选输入字符串的场景下，速度提升最少10ms。



针对NFA正则引擎调优

##### 优先选择最左端的匹配结果

将比较常用的选择项放在前面，可以快速匹配。

##### 标准量词优先匹配

比如'.\*\[0-9][0-9]' 来匹配字符串"abcd12efghijklmnopqrstuvw"，这时候的匹配方式是'.*'先匹配了整行，但不满足'\[0-9\]\[0-9\]'匹配，所以'.\*'就退还一个字符'w'，还是无法匹配，继续退还一个'v'，直到退还到'2'发现匹配了一个，但是还是无法匹配两个数字，所以继续退还'1'。

##### 使用字符范围代替分支

例如：用[a-d] 代替 a|b|c|d避免不必要的回溯。

##### 单个字符时不要用字符集

\\. 代替 [.]

##### 使用锚点^ $ \b 加速定位

##### 锚点要独立出来

很多正则编译器会根据锚点进行特别的优化: ^123|^abc 改成^(?:123|abc)。同样的$也尽量独立出来。

##### 提取共用的模式

将"(abcd|abef)"替换为"ab(cd|ef)"。因为NFA会尝试匹配ab，如果没有找到就不再尝试任何选择项。

*测试结果*：表达式".\*(abcd|efgh|ijkl).\*"要比调用String.indexOf()三次，每次针对表达式中的一个选项慢三倍。所以正则要慎用！

##### 如果括号是非必须的，请不要加括号。



最后，引用CFC4N大牛的一句话 滥用. 点号  * 星号  +加号  ()括号是不环保，不负责任的做法 ！

#### 正则其他知识

正则表达式引擎

分为两类：一类称为DFA（确定性有穷自动机），另一类称为NFA（非确定性有穷自动机，Nondeterministic Finite Automaton）。

DFA拿着字符串去比较正则式，看到一个子正则式，就把可能的匹配串全标注出来，然后再看正则式的下一个部分，根据新的匹配结果更新标注。而NFA是拿着正则式去比字符串，吃掉一个字符，就把它跟正则式比较，匹配就记下来，然后接着往下比。一旦不匹配，就把刚吃的这个字符吐出来，一个个的吐，直到回到上一次匹配的地方。 

DFA与NFA对比：

- DFA 对于文本串里的每一个字符只需扫描一次，比较快，但特性较少；NFA要翻来覆去吃字符、吐字符，速度慢，但是特性丰富，所以应用广泛，当今主要的正则表达式引擎，如Perl、Ruby、Python的re模块、Java和.NET的regex包，都是NFA的。
- NFA急于邀功请赏，所以最左子正则式会优先匹配成功，因此偶尔会错过最佳匹配结果；DFA则可以确保匹配最长的可能的字符串。 
- 只有NFA才支持lazy、backreference等特性
-  NFA可能会陷入递归调用的陷阱而表现得性能极差。 

总结：使用正则表达式的时候，底层是通过递归方式调用执行的，每一层的递归都会在方法调用栈占一定内存，如果递归的层次很多，就会报出StackOverFlowError异常。所以在使用正则的时候其实是有利有弊的。

下面两条规则适用于不同的正则引擎：

1、优先选择最左端的匹配结果。
2、标准的匹配量词(* + ？ {n，m})是优先匹配的。

参考'.*\[0-9][0-9]'匹配字符串"abcd12efghijklmnopqrstuvw"例子

