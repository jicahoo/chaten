#!/bin/bash

ROOT_DIR=chaten-1.0
#clean
rm -rf ${ROOT_DIR}
mkdir ${ROOT_DIR}
HADOOP_ENV_DIR=${ROOT_DIR}/hadoop_env
DEPS_ARTIFACT_DIR=depends

#RPM need blow two files. chaten and chaten.conf
mkdir -p ${ROOT_DIR}/usr/bin
touch ${ROOT_DIR}/usr/bin/chaten
mkdir -p ${ROOT_DIR}/etc/chaten
touch ${ROOT_DIR}/etc/chaten/chaten.conf

#Prepare JDK, Hadoop and hadoop config files.
mkdir -p $HADOOP_ENV_DIR/jdk
mkdir -p $HADOOP_ENV_DIR/hadoop
mkdir -p $ROOT_DIR/etc/profile.d/
touch $ROOT_DIR/etc/profile.d/hadoop_setenv.sh
echo 'export HADOOP_HOME=/hadoop_env/hadoop/hadoop-2.8.0/' >> ${ROOT_DIR}/etc/profile.d/hadoop_setenv.sh
mkdir -p $HADOOP_ENV_DIR/namenode/store
mkdir -p $HADOOP_ENV_DIR/namenode/conf/
touch $HADOOP_ENV_DIR/namenode/conf/datanode-allow.list
echo 10.141.68.198 >> $HADOOP_ENV_DIR/namenode/conf/datanode-allow.list
echo 10.141.68.199 >> $HADOOP_ENV_DIR/namenode/conf/datanode-allow.list
mkdir -p $HADOOP_ENV_DIR/datanode/store
mkdir -p $HADOOP_ENV_DIR/resourcemanager
touch $HADOOP_ENV_DIR/resourcemanager/include_nodemanagers.list
echo 10.141.68.198 >> $HADOOP_ENV_DIR/resourcemanager/include_nodemanagers.list
echo 10.141.68.199 >> $HADOOP_ENV_DIR/resourcemanager/include_nodemanagers.list
mkdir -p $HADOOP_ENV_DIR/nodemanager/local_dir_1
mkdir -p $HADOOP_ENV_DIR/nodemanager/log_dir_1
mkdir -p "$HADOOP_ENV_DIR/mr-history/tmp"
mkdir -p "$HADOOP_ENV_DIR/mr-history/done"

tar xzf $DEPS_ARTIFACT_DIR/jdk-8u111-linux-i586.tar.gz -C $HADOOP_ENV_DIR/jdk
tar xzf $DEPS_ARTIFACT_DIR/hadoop-2.8.0.tar.gz -C $HADOOP_ENV_DIR/hadoop
cp hadoop_config/* $HADOOP_ENV_DIR/hadoop/hadoop-2.8.0/etc/hadoop/ 
tar czf ${ROOT_DIR}.tar.gz ${ROOT_DIR}

