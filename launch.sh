#!/bin/bash

prog=$(basename $0)
mykeyfile=mykey.txt
myaddrfile=myaddr.txt
cmd_log=last.log

function run() {

name="zilliqa"
ip="$IP"
port="33133"
zilliqa_path="$ZILLIQA_PATH"

echo -n "Enter the full path of your zilliqa source code directory: " && read path_read && [ -n "$path_read" ] && zilliqa_path=$path_read

if [ -z "$zilliqa_path" -o ! -x $zilliqa_path/build/bin/zilliqa ]
then
    echo "Cannot find zilliqa binary on the path you specified"
    exit 1
fi

# echo -n "Enter your IP address ('NAT' or *.*.*.*): " && read ip_read && [ -n "$ip_read" ] && ip=$ip_read
# echo -n "Enter your listening port (default: $port): " && read port_read && [ -n "$port_read" ] && port=$port_read

if [ ! -s $mykeyfile ]
then
    echo "Cannot find $mykeyfile, generating new keypair for you..."
    ${zilliqa_path}/build/bin/genkeypair > $mykeyfile
fi

prikey=$(cat $mykeyfile | awk '{ print $2 }')
pubkey=$(cat $mykeyfile | awk '{ print $1 }')

$zilliqa_path/build/bin/getaddr --pubk $pubkey > $myaddrfile

cmd="zilliqa --privk $prikey --pubk $pubkey --address $ip --port $port --synctype 1"

$zilliqa_path/build/bin/$cmd > $cmd_log 2>&1 &

echo
echo "Use 'cat $cmd_log' to see the command output"
echo "Use 'tail -f zilliqa-00001-log.txt' to see the runtime log"
}

function cleanup() {
rm -rfv "*-log.txt"
}

function usage() {
cat <<EOF
Usage: $prog [OPTIONS]

Options:
    --cleanup               remove log files
    --help                  show this help message
EOF
}

case "$1" in
    "") run;;
    --cleanup) cleanup;;
    --help) usage ;;
    *) echo "Unrecognized option '$1'"; usage ;;
esac
