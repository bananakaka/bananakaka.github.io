#### 背景

由于资源文件太大，不想打包到应用中，每次从中央库down jar包都花很长时间。考虑每次部署时，用部署脚本去把资源文件scp到服务器上。

#### 目的

用scp命令免密码传输文件。

#### 解决方案

用ssh的对称密钥实现，机器A向机器B免密传文件，在机器A上生成密钥对，把生成的公钥(id_rsa.pub)内容，copy到机器B的~/.ssh/authorized_keys文件。

1. 机器A生成密钥对：ssh-keygen -t rsa -P ""
2. 在~/.ssh目录找到id_rsa.pub文件，copy文件内容，内容类似这样：
```
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA15QJjhCjMPo3XxcjGG7KyyGNIUWfaLQ27yACNerC6Mb2nH6OvIAPXpDGkfZOrJJKPoXiyqeel20TPm81VknMTdUPcd+BxZfUaKKRb6zTyZbT/jTJGgAK4OnSTV3e1nc6pwG9Jnhsrjr7r+yk2ig+9zDFMgYHVRNgv124K1y5T+XNvO3ZiBhO4HKre6xMzOok8KPFxyN9e1SPuZWdIHxZs72WlhCD4MWdkEWC65NDd2kkJrMV6wNBl4mAGoxvx9NMmlbiUuapQrzQ1p4W5A+fvQF5vxyy6rhWfhAaYENgM6CNZqeB5SbqcNvj0iy0IidW+HuL3JZ+vKZ/5QwyCU6W7Q== sankuai@fdy651.office.mos
```
3. 登陆机器B，在~/.ssh目录下authorized_keys文件中(不存在则创建一个)，追加机器A的id_rsa.pub文件内容(步骤2的内容)。
4. 实现机器B向机器A免密传文件，同理。把机器B的id_rsa.pub内容copy到机器A的authorized_keys文件即可。


