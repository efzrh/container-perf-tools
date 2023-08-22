#!/bin/bash

# env vars:
#   RTLA_ARGS (default "-d 30")

source common-libs/functions.sh

function sigfunc() {
    exit 0
}

echo "############# dumping env ###########"
env
echo "#####################################"

echo " "
echo "########## container info ###########"
echo "/proc/cmdline:"
cat /proc/cmdline
echo "#####################################"

echo "**** uid: $UID ****"
if [[ -z "${RTLA_ARGS}" ]]; then
    RTLA_ARGS="-d 30"
fi

for cmd in rteval; do
    command -v $cmd >/dev/null 2>&1 || { echo >&2 "$cmd required but not installed. Aborting"; exit 1; }
done

cpulist=`get_allowed_cpuset`
echo "allowed cpu list: ${cpulist}"

uname=`uname -nr`
echo "$uname"

cpulist=`convert_number_range ${cpulist} | tr , '\n' | sort -n | uniq`

declare -a cpus
cpus=(${cpulist})

trap sigfunc TERM INT SIGUSR1

newcpulist=${cpus[0]}
cindex=1
ccount=1
while (( $cindex < ${#cpus[@]} )); do
    newcpulist="${newcpulist},${cpus[$cindex]}"
    cindex=$(($cindex + 1))
    ccount=$(($ccount + 1))
done

echo "cpu list: ${newcpulist}"

cmd="rteval ${RTLA_ARGS}"

echo "running cmd: ${cmd}"

if [ "${manual:-n}" == "n" ]; then
    ${cmd}
else
    sleep infinity
fi

sleep infinity
