# In Chinese: 需求

# A requirements sample:
下面这个需求，已经做出简单的POC, 参见[代码](https://github.com/jicahoo/chaten/blob/master/poc/hive_custom_info_join_and_conversion.sql)。
现有客户电话信息表bcfmcidi，客户扩展信息表 cust_ecif 两张表，表结构如下：

```sql
bcfmcidi：
cust_isn（客户内码） string，
bel_org（机构号） string，
phone_no（电话号码） string，
cust_name（客户名称）string，
sex（性别）int，
birthday（出生日期）decimal(8,0),


cust_ecif：
cust_isn （客户内码） string,
bel_org (机构号) string，
post（职务） string，
office_tel（办公电话） string，
address(居住地址) string
```


已知实际业务中，一个客户在同一个机构只有一份电话信息，同样，一个客户在同一个机构只有一份扩展信息。现在需要汇总一张客户的详细信息表cust_info，
表结构中含有该客户的客户内码，客户名称，电话号码，性别，出生日期，职务，居住地址。有一部分没有扩展信息，但是有电话信息，对于这些客户，需展示除职务和居住地址的其他字段。
性别需要由1,2对应转换为男，女，出生日期转换为yyyy-mm-dd的格式。

## 场景
用户的数据通过Flume不断流入到Hive, 而且数据量极大，可能需要分区. 

## 需求不明确的地方
* 数据的来源的性质，从哪里来，是多台机器吗? 不同的数据源会有重复数据吗?
* 数据的量有多大? 产生的频率有多快?

## 可能需要解决的问题
* 数据从Hive流向ES的时候，如果数据量很大，岂不是很慢?
* 数据从Flume流向Hive, 如何保证速度?
