

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









