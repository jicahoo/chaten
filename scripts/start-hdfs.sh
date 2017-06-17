#--------- Start HDFS nodes one by one ----------#
# On NameNode
$HADOOP_HOME/bin/hdfs namenode -format <cluster_name>
#
$HADOOP_HOME/bin/hdfs namenode #Start the namenode.

# On DataNode.
$HADOOP_HOME/bin/hdfs datanode #Start the datanode.
#--------- Start HDFS nodes one by one ----------#

#--------- Start HDFS use only one script --------#
$HADOOP_HOME/sbin/start-dfs.sh
#--------- Start HDFS use only one script --------#

#--------- Check if HDFS can work -----------#
./hdfs dfs -mkdir /hello_hdfs
./hdfs dfs -ls /
#--------- Check if HDFS can work -----------#

# WEB UI
# Step 1: Find the IP Port
netstat -tuanp | grep <NameNodeProcess>
tcp        0      0 10.141.49.90:8020       0.0.0.0:*               LISTEN      18240/java
tcp        0      0 0.0.0.0:50070           0.0.0.0:*               LISTEN      18240/java
tcp        0      0 10.141.49.90:8020       10.141.68.199:44699     ESTABLISHED 18240/java
tcp        0      0 10.141.49.90:8020       10.32.253.40:56874      ESTABLISHED 18240/java
tcp        0      0 10.141.49.90:8020       10.141.68.198:34325     ESTABLISHED 18240/java

# Step 2: Open Chrome and access http://<NameNodeIp>:50070. 
