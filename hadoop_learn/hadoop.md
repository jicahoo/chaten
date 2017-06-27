# 

## Reference
* http://ercoppa.github.io/HadoopInternals/AnatomyMapReduceJob.html (Has a good diagram about interaction between YARN and map-reduce.)
* http://courses.coreservlets.com/Course-Materials/pdf/hadoop/04-MapRed-6-JobExecutionOnYarn.pdf  (More detalis about flow of MapReduce Flow, Memory config, Failures Handle)
* https://www.youtube.com/watch?v=8m_GqOee1ro  (More details on MapReduce-on-YARN)
* 《Hadoop权威指南》讲的还是比较全面和深入的. 从理论到实践，从流程到代码，从功能到调优，还有设计思想与权衡.

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
* YarnRunner.submitJob
   * ResourceMgrDelegate.submitAppliction
      * YarnClient.submitApplication #YarnClient is interface. From code we guess its instance will be with type YarnClientImpl at running status.
      * YarnClientImpl.submitApplication
         * ApplicationClientProtocol.submitApplication #It is also a interface. We guess it will be ApplicationClientProtocolPBClientImpl
         * ApplicationClientProtocolPBClientImpl.submitApplication #RPC client
         * ----- I am network ---
         * ClientRMService.submitApplication. # RPC server.
            * RMAppManager.submitApplication
               * RMAppManager.createAndPopulateNewRMApp. #真正去创建RMApp.
            * 成功: return recordFactory.newRecordInstance(SubmitApplicationResponse.class);
            * 失败: YarnException.
   * 获得 applicationId (from ResourceMgrDelegate.submitApplication)
   * return clientCache.getClient(jobId).getJobStatus(jobId); #这一步调用还有不少内容，目前还没弄清楚。
            
  

## MapReduce
### Core Class of MapReduce
* org.apache.hadoop.mapred.MapTask
### Difference between mapreduce package and mapred package
* https://stackoverflow.com/questions/16269922/hadoop-mapred-vs-hadoop-mapreduce
