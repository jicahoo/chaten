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
