#!/bin/bash
#https://cwiki.apache.org/confluence/display/Hive/GettingStarted#GettingStarted-InstallingHivefromaStableRelease

# On Name Node ?
export JAVA_HOME=/hadoop_env/jdk/jdk1.8.0_111/
export HADOOP_HOME=/hadoop_env/hadoop/hadoop-2.8.0/
$HADOOP_HOME/bin/hadoop fs -mkdir       /tmp
$HADOOP_HOME/bin/hadoop fs -mkdir       /user/hive/warehouse
$HADOOP_HOME/bin/hadoop fs -chmod g+w   /tmp
$HADOOP_HOME/bin/hadoop fs -chmod g+w   /user/hive/warehouse
# wget  http://apache.claz.org/hive/hive-1.2.2/apache-hive-1.2.2-bin.tar.gz
export HIVE_HOME=/hive_env/apache-hive-1.2.2-bin

# Verify
$HIVE_HOME/bin/hive
#SQL
CREATE TABLE pokes (foo INT, bar STRING);
insert into table pokes values (1, "hello");
select p.foo from pokes p;

# On HDFS you will see pokes folder.
./bin/hadoop fs -ls /user/hive/warehouse 
./bin/hadoop fs -ls /user/hive/warehouse/pokes