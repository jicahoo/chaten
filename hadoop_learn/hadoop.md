# 

## Reference
* http://ercoppa.github.io/HadoopInternals/AnatomyMapReduceJob.html (Has a good diagram about interaction between YARN and map-reduce.)
* http://courses.coreservlets.com/Course-Materials/pdf/hadoop/04-MapRed-6-JobExecutionOnYarn.pdf  (More detalis about flow of MapReduce Flow, Memory config, Failures Handle)
* https://www.youtube.com/watch?v=8m_GqOee1ro  (More details on MapReduce-on-YARN)
* 《Hadoop权威指南》讲的还是比较全面和深入的. 从理论到实践，从流程到代码，从功能到调优，还有设计思想与权衡.
* MapReudce Flow: http://www.dineshonjava.com/2014/11/mapreduce-flow-chart-sample-example.html
* MapReduce Flow: https://stackoverflow.com/questions/22141631/what-is-the-purpose-of-shuffling-and-sorting-phase-in-the-reducer-in-map-reduce

## Misc when broswe the code
* Task(org.apache.hadoop.mapreduce.v2.app.job): read only view for task.
* TaskAttemp(org.apache.hadoop.mapreduce.v2.app.job): Read only view of TaskAttempt
* TaskAttemptImpl(org.apache.hadoop.mapreduce.v2.app.job.impl): Implementation of TaskAttempt interface. I think it is core class.

```java
MapTaskAttemptImpl extends TaskAttempImpl
ReduceTaskAttempImpl extends TaskAttempImpl
```

## MapReduce

依照下面的脉络看代码:
* ApplicationMaster -> MRAppMaster -> Job -> Task -> TaskImpl

##
* Container on NodeManager is a Java Process. For each task Node Manager(s) start container – a java process with YarnChild as the main class

## SPring has goot integration with YARN
* https://spring.io/guides/gs/yarn-basic/


## Yarn - Start
* ${HADOOP_HOME}/bin/yarn -> yarn resourcemanager -> org.apache.hadoop.yarn.server.resourcemanager.ResourceManager.main -> May clear RMState (MemRMStat, ZkRMState)  -> 
    * ResourceManager.init(conf) -> ResourceManager.serviceInit (conf, rmContext, rmLoginUGI, rmDispatcher, adminService, webAppAddress)
    * ResourceManager.start() -> ResourceManager.serviceStart -> ResourceManager.startWepApp(): Build a embedded web app using Jetty, war is from hadoop-yarn-ui-version.war
 
### YARN Resource Manager 相关的三大RPC
* http://blog.csdn.net/lipeng_bigdata/article/details/52002854
* ResourceManager有三个RPC相关的成员变量：ClientRMService, ApplicationMasterService,  ResourceTrackerService. 这些成员都是RPC的服务器端实现。他们的职责分别是和提交作业的Client通信，和正在运行的ApplicationMaster通信，和NodeManager通信；他们实现的RPC协议是ApplicationClientProtocol, ApplicationMasterProtocol, ResourceTracker。这些协议都是以Java接口的形式定义的。
* ResourceManager和ResourceTracker通信需要RPC协议ResourceTracker
* ResourceManager和要提交作业的Client通信需要RPC协议ApplicationClientProtocol
* ResourceManager和正在执行的应用通信需要RPC协议ApplicationMasterProtocol.
### 将作业提交到YARN的基本过程
* org.apache.hadoop.mapreduce.Job.submit
* JobSubmitter.submitInternal
* JobID jobId = submitClient.getNewJobID(); #submitClient is of type ClientProtocol (an interface). YarnRunner implements ClientProtocol.
* YarnRunner.submitJob(jobId,...
   * ResourceMgrDelegate.submitAppliction
      * YarnClient.submitApplication #YarnClient is interface. From code we guess its instance will be with type YarnClientImpl at running status.
      * YarnClientImpl.submitApplication
         * ApplicationClientProtocol.submitApplication #It is also a interface. We guess it will be ApplicationClientProtocolPBClientImpl
         * ApplicationClientProtocolPBClientImpl.submitApplication #RPC client
         * ----- I am network ---
         * ClientRMService.submitApplication. # RPC server. ClientRMService also implements ApplicationClientPRotocol.
            * RMAppManager.submitApplication
               * RMAppManager.createAndPopulateNewRMApp. #真正去创建RMApp.
            * 成功: return recordFactory.newRecordInstance(SubmitApplicationResponse.class);
            * 失败: YarnException.
   * 获得 applicationId (from ResourceMgrDelegate.submitApplication)
   * return clientCache.getClient(jobId).getJobStatus(jobId); #这一步调用还有不少内容，目前还没弄清楚。

### YARN中的状态机
* YARN中也有状态机: StateMachineFactory,StateMachine,SingleArcTransition (org.apache.hadoop.yarn.state), RMAppState, RMAppEvent, RMAppEventType
* RMAppImpl和RMAppAttempImpl都使用了状态机。所以相应的代码中，有许多Transition类的定义和对应状态转移的注册。
            
  

## MapReduce
### Core Class of MapReduce
* org.apache.hadoop.mapred.MapTask
### Difference between mapreduce package and mapred package
* https://stackoverflow.com/questions/16269922/hadoop-mapred-vs-hadoop-mapreduce

### Source Code
* MapTask.runNewMapper #It will run customer-defined map. 'New' means new MapReduce API.
   * mapper.run(mapperContext);
* MapTask: 成员
   1. MapOutputBuffer #著名的环形缓冲
* YarnChild: The main() for MapReduce task processes.

### MapTask如何collect输出
* MapOutputBuffer is a MapOutputCollector. #Map任务使用MapOutputBuffer作为默认的MapOutputCollector.
* MapTask.NewOutputCollector是RecordWriter的子类。MapTask.NewOutputCollector包含了一个类型为MapOutputCollector的成员。写操作(RecordWriter.write)的具体执行就是调用MapOutputCollector.collect.
* Mapper.map方法的Context参数是抽象类。该抽象类的具体实现是WrappedMapper.Context. 这个实现类会包含一个类型为MapContext的成员. 在runNewMapper方法中，会创建一个具体的MapContextImpl，并包裹在WrappedMapper中。所以, 具体干活的类是MapContextImpl。MapContextImpl又继承了TaskInputOutputContextImpl的一些关于输出收集的功能。
* 结合上面三条，我们可以得出结论，在Mapper.map的具体实现方法中，调用context.write, 就会调用到MapContextImpl.write方法，从而调用到RecordWriter.write, 最终，就会调用到MapOutputBuffer的collect方法。整个过程的调用栈如下，
   * Mapper.Context.write (具体实现方法：WrappedMapper.write)
      * MapContext.write (MapContextImpl.write)
         * RecordWrite.write (具体实现方法：NewOutputCollector.write)
            * MapOutputCollector.collect (具体实现方法: MapperOutputBuffer.collect)

### MapTask.MapOutputBuffer. 如何写缓冲区  #环形缓冲
* MapOutputBuffer使用了几个instance级别的内部类来完成工作，这样内部类可以访问外层类的成员变量，所以，逻辑调用不一定那么清楚。就像是到处在访问全局变量似的.
   * BlockingBuffer: 访问了kvbuffer, 包装了Buffer.
   * Buffer: 访问kvbuffer
   * SpillThread
   * InMemValBytes
   * MRResultIterator.
* MapOutputBuffer: 利用Stream的方式来移动byte.  使用System.arraycopy来操作缓冲。
* MapOutputBuffer.flush会调用MapOutputBuffer.mergeParts得到最终的一个Map任务的输出文件。
* 正常的写入到kvbuffer的流程。过程中不出现异常，不出现空间不足，不出现wrap around。
    * 终点: MapTask.MapOutputBuffer.Buffer.write: System.arraycopy(b, off, kvbuffer, bufindex, len);
    * 起点：MapOutputBuffer.collect
      * keySerializer.serialize(key); (WritableSerializer.serialize(Writable w)).
        * w.write(dataOut); (Text.write(DataOutput out)) #dataOut正是MapOutputBuffer.BlockingBuffer. BlockingBuffer继承自DataOutputStream.
            * out.write(bytes, 0, length); #out就是BlockingBuffer, 而BlockingBuffer包装了MapOutputBuffer.Buffer, 所以会调用Buffer.write
                * Buffer.write(byte b[], int off, int len)
                    * 终点：System.arraycopy(b, off, kvbuffer, bufindex, len);

### 如何Spill
* 具体执行函数： MapOutputBuffer#sortAndSpill 
* 排序：
    * sorter.sort(MapOutputBuffer.this, mstart, mend, reporter); #排序的范围是当前环形缓冲的所有记录。
    * 理解上面的调用:
        * 第一个参数就是MapOutputBuffer本身，MapOutputBuffer实现了IndexedSortable的接口：compare(i,j), swap(i,j). 根据index排序的基础操作。 第一个参数是排序的主题，可以把它想象成数组，数组放上可排序的元素就是IndexedSortable.
        * 后面几个参数理解就很容易了。 最后一个参数的类型其实是Progressable, 用来记录排序的进度。
        * MapOutpubBuffer的compare是决定数据如何排序的: 先按分区排序，再按键排序。
    * 结论：此处的排序是局部(当前缓冲区)有序。

* sortAndSpill的输出：一个spill文件
    * MapOutputBuffer有一个numSpills的整形成员变量，用以记录写了多少个Spill文件，会作为输出文件名的一部分。OutputFiles#getSpillFileForWrite的文件名就会设置为"spill"+numSpills+".out".

* SpliiThread会调用sortAndSpill函数。SpillThread会和MapOutputBuffer.collect所在的线程进行同步。
    * 两者之间会争用spillLock
    * 当collect发现需要spill的时候，就会调用startSpill，去通知随时待命的SpillThread进行sortAndSpill
    * 在MapOutputBuffer.init中，会初始化SpillThread, 让该线程处于待命状态，一直等待spillThreadRunning变成true, 否则，在条件队列spillDone上等待。

### Spill之后的合并
* 入口： MapoutputBuffer.mergeParts
* 实现合并逻辑的核心类：org.apache.hadoop.mapred.Merger 和 org.apache.hadoop.mapred.Merger.MergeQueue
* 合并过程中的排序是如何实现的： MergeQueue其实是个小根堆。 MergeQueue中的元素是Segment<K,V>.
* mergetParts中的核心代码:

```java
        for (int parts = 0; parts < partitions; parts++) {
            //create the segments to be merged
            List<Segment<K,V>> segmentList =
                new ArrayList<Segment<K, V>>(numSpills);
            for(int i = 0; i < numSpills; i++) {
                IndexRecord indexRecord = indexCacheList.get(i).getIndex(parts);
                ...
            }

            @SuppressWarnings("unchecked")
            RawKeyValueIterator kvIter = Merger.merge(job, rfs,
                            keyClass, valClass, codec,
                            segmentList, mergeFactor,
                            new Path(mapId.toString()),
                            job.getOutputKeyComparator(), reporter, sortSegments,
                            null, spilledRecordsCounter, sortPhase.phase(),
                            TaskType.MAP);
            ...
            Merger.writeFile(kvIter, writer, reporter, job);
            ...
        }
```

* 从代码可以看出，合并是一个分区一个分区地执行的。
* kvIter就返回一个迭代器，每次迭代就可以拿出小根堆的堆顶元素。
* 输出：一个文件：Path finalIndexFile = mapOutputFile.getOutputIndexFileForWrite(finalIndexFileSize);

## Reduce
* Reduce任务的大致执行过程
    * 入口： run(JobConf job, final TaskUmbilicalProtocol umbilical) #会被YarnChild.main调用.
    * 分三个主要过程(phase)：copy, sort, reduce.
    * 委托Shuffle.run方法完成了copy和sort过程。Shuffle实现了ShuffleConsumerPlugin接口。
    * 委托NewTrackingRecordWriter将结果写出。

* Shuffle.run完成了两件事：Copy 和 merge, 最终, 通过MergeManagerImpl.close方法返回一个RawKeyValueIterator
* 第一个阶段：Copy
    * 代码位置：Shuffle.run的前半部分。其中有个调用： copyPhase.complete();  宣告了Copy阶段的结束。
    * Copy的具体工作是由EventFetcher和Fetcher来完成的。
    * Reduce怎样知道什么时候，去哪才能拿到已完成的Map任务的输出？
        * EventFetcher线程会不断地从父Java进程中，获取TaskCompletionEvent. 交互协议用的是Umbilical.
        * EventFetcher的成员scheduler(ShuffleScheduler)会负责解析TaskCompletionEvent。具体代码在EventFetcher.getMapCompletionEvents方法中，会为每个Event调用:scheduler.resolve方法。会记录下Map输出所在的Host的信息.
        * Shuffle.run中，在启动EventFetcher线程之后，会启动多个Fetcher线程（默认为5个）进行具体的Copy工作。
        * Note: scheduler(ShuffleSchedulerImpl)是EventFetcher和Fetcher的桥梁。
* 第二个阶段：Sort (Merge)
    * 入口: Shuffle.run: merger.close(). #merger是类MergeManagerImpl的一个实例
    * MergerManager会利用OnDiskMerger, InMemoryMerger, Merger完成合并过程。

* 第三个阶段： Reduce
    * 上面的两个阶段的输出就转化为一个RawKeyValueIterator
    * ReduceTask.run会调用runNewReducer来具体完成。runNewReducer比较简单
        * 构造ReduceContext
        * 创建客户提供的Reducer类的实例.
        * 调用Reducer类的run(Context)方法。
