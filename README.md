# chaten
Flume + Hive + ElasticSearch
## Version Info
* Hive: 1.2.2
* Hadoop: 2.8.0
* ElasticSearch: 5.4.0

## Done
* Hadoop cluster was set up successfully. Blow examples can be ran successfully.
```shell
./bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.8.0.jar pi 16 1000
```



## Current status:
* Just completed the simplest requirements. Query data from Hive and push to ElasticSearch, then user can search that data in ElasticSearch and leverage all query capabilities provided by ElasticSearch.
* Next step: 1. Hive + ElasticSearch on it.


## Achitecture
![Alt text](images/chaten-architecure.jpg?raw=true "Title")
