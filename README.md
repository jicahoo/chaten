# chaten
Flume + Hive + ElasticSearch
## Version Info
* Hive: 1.2.2
* Hadoop: 2.8.0
* ElasticSearch: 5.4.0

## Goal
* Learn Hadoop: Know the work flow of Hadoop.  [TODO]
* The original problem: Flume -> Hive -> ElasticSerach [Undone] Requiremnets: [poc/requirements.md](poc/requirements.md)
* Project has business value. [TODO]

## Block
* Have no stable Hadoop cluster enviroment.

## Next Step
* The word count executing flow.

## Done Things
* Hadoop cluster was set up successfully. Blow examples can be ran successfully.
* Hive can run on Hadoop Cluster. Hive is installed on NameNode. Is it correct to install Hive on NameNode?
* Just completed the simplest requirements. Query data from Hive and push to ElasticSearch, then user can search that data in ElasticSearch and leverage all query capabilities provided by ElasticSearch.

```shell
# Compute PI
./bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.8.0.jar pi 16 1000

# Compute Word Count
./bin/hdfs dfs  -mkdir /user/root/word_count_input
./bin/hdfs dfs -copyFromLocal etc/hadoop/* /user/root/word_count_input/
./bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.8.0.jar wordcount /user/root/word_count_input/ /user/root/word_count_output
./bin/hdfs dfs -ls /user/root/word_count_output
./bin/hdfs dfs -cat /user/root/word_count_output/part-r-00000
```

## Achitecture
![Alt text](images/chaten-architecure.jpg?raw=true "Title")
