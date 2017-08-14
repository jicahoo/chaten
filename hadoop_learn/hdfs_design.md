## HDFS的设计
* http://hadooptutorial.info/hdfs-design-concepts/
* https://hadoop.apache.org/docs/r1.2.1/hdfs_design.html

## HDFS设计假设
* 硬件失败是经常发生的，所以HDFS的核心架构设计目标之一就是及时地探测失败并快速自动地恢复。
* 数据写一次，读取多次进行分析处理
* 移动计算比移动数据的成本更低, 所以HDFS为应用提供了相应的接口，使得应用程序能够将自己移动到离数据更近的地方。

## HDFS的设计目标
* 在一个集群上存储大量数据，PB级别.
* 可靠的存储数据，容错性: 当系统的一部分出现故障时，系统继续运行并提供服务的能力
* 
