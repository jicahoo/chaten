# 

## Reference
* http://ercoppa.github.io/HadoopInternals/AnatomyMapReduceJob.html (Has a good diagram about interaction between YARN and map-reduce.)
* http://courses.coreservlets.com/Course-Materials/pdf/hadoop/04-MapRed-6-JobExecutionOnYarn.pdf  (More detalis about flow of MapReduce Flow, Memory config, Failures Handle)
* https://www.youtube.com/watch?v=8m_GqOee1ro  (More details on MapReduce-on-YARN)

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