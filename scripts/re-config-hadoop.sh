#/bin/bash
SSH_KEY="/path/to/key_file"
SCP_COMMAND="scp -o ServerAliveInterval=10 -o ServerAliveCountMax=1 -o ConnectTimeout=10 -o User=root -i $SSH_KEY "

run_network_copy()
{
    local image="$1"
    local host_location="$2"
    echo "Copying $image to $host_location ..."
    eval $SCP_COMMAND "$image" "$host_location"
    return $?
}
array=( 10.141.49.90 10.141.45.166 10.141.45.165 10.141.68.198 10.141.68.199 127.0.0.1 )
for i in "${array[@]}"
do
    echo $i
    files=`ls chaten/config/hadoop_config_files/`
    for f in chaten/config/hadoop_config_files/*; do
    run_network_copy $f $i:/hadoop_env/hadoop/hadoop-2.8.0/etc/hadoop/
    done
done
