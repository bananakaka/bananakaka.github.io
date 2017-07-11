

##### 通配符

%：一个或多个字符

_：一个字符

[charlist]字符列中的任何单一字符

[^charlist]或者[!charlist]不在字符列中的任何单一字符

select ename,sal from emp where ename like '%\%%';		//  '\'是转义字符   

查找带%的字符串:

select ename,sal from emp where ename like '%$%%' escape '$';	//  escape是将$声明为转义字符 默认为'\'

##### 别名

列别名两侧需要添加双引号

- 类别名包含空格
- 区分大小写
- 含有特殊字符

##### 相关子查询

内部查询需引用外部查询的列，进行交互判断。其实是和for循环的过程一样，内循环都执行完后，再执行一次外循环。

除运算(包含于)用not exists来实现。

exists：判断存在与否，并没有确切记录返回，只判断是否有记录。





##### from

from 子句中只要用","隔开的表，结果集一律先进行笛卡尔乘积

##### between and

between m and n m<=col<=n

##### and、or、not

优先级：NOT > AND > OR







到底要用utf8mb4\_general_ci 还是utf8mb4_unicode_ci 呢？
建议使用： utf8mb4_unicode_ci
这两种排序规则都是为UTF-8字符编码。
utf8mb4\_unicode_ci 使用标准的Unicode Collation Algorithm(UCA)，utf8mb4\_general_ci 比utf8mb4\_unicode_ci 速度要来得快，但是utf8mb4\_unicode_ci 比utf8mb4_general_ci 要来得精确。
像是"ß"，若是以utf8mb4\_general_ci 运作，会转成"s"，而utf8mb4_unicode_ci 则是会转成"ss"。







