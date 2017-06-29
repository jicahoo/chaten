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
* MapOutputBuffer is a MapOutputCollector. #Map任务使用MapOutputBuffer作为默认的MapOutputCollector.
* MapTask.NewOutputCollector是RecordWriter的子类。MapTask.NewOutputCollector包含了一个类型为MapOutputCollector的成员。写操作(RecordWriter.write)的具体执行就是调用MapOutputCollector.collect.
* Mapper.map方法的Context参数是抽象类。该抽象类的具体实现是WrappedMapper.Context. 这个实现类会包含一个类型为MapContext的成员. 在runNewMapper方法中，会创建一个具体的MapContextImpl，并包裹在WrappedMapper中。所以, 具体干活的类是MapContextImpl。MapContextImpl又继承了TaskInputOutputContextImpl的一些关于输出收集的功能。
* 结合上面三条，我们可以得出结论，在Mapper.map的具体实现方法中，调用context.write, 就会调用到MapContextImpl.write方法，从而调用到RecordWriter.write, 最终，就会调用到MapOutputBuffer的collect方法。整个过程的调用栈如下，
   * Mapper.Context.write (具体实现方法：WrappedMapper.write)
      * MapContext.write (MapContextImpl.write)
         * RecordWrite.write (具体实现方法：NewOutputCollector.write)
            * MapOutputCollector.collect (具体实现方法: MapperOutputBuffer.collect)
### MapTask.MapOutputBuffer #环形缓冲
* MapOutputBuffer使用了几个instance级别的内部类来完成工作，这样内部类可以访问外层类的成员变量，所以，逻辑调用不一定那么清楚。就像是到处在访问全局变量似的.
   * BlockingBuffer: 访问了kvbuffer, 包装了Buffer.
   * Buffer: 访问kvbuffer
   * SpillThread
   * InMemValBytes
   * MRResultIterator.
* MapOutputBuffer: 利用Stream的方式来移动byte. 
* MapOutputBuffer.flush会调用MapOutputBuffer.mergeParts得到最终的一个Map任务的输出文件。
* 正常的写入到kvbuffer的流程。过程中不出现异常，不出现空间不足，不出现wrap around。
    * 终点: MapTask.MapOutputBuffer.Buffer.write: System.arraycopy(b, off, kvbuffer, bufindex, len);
    * 起点：MapOutputBuffer.collect
      * keySerializer.serialize(key); (WritableSerializer.serialize(Writable w)).
        * w.write(dataOut); (Text.write(DataOutput out)) #dataOut正是MapOutputBuffer.BlockingBuffer. BlockingBuffer继承自DataOutputStream.
            * out.write(bytes, 0, length); #out就是BlockingBuffer, 而BlockingBuffer包装了MapOutputBuffer.Buffer, 所以会调用Buffer.write
                * Buffer.write(byte b[], int off, int len)
                    * 终点：System.arraycopy(b, off, kvbuffer, bufindex, len);
