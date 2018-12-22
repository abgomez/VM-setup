#path setup
#cd /home/lab/Desktop/client
mkdir data
mkdir logs
mkdir keys

export SAWTOOTH_HOME=`pwd`
export SAWTOOTH_RAFT_HOME=`pwd`


#keys
sawadm keygen
sawtooth keygen

#validator
sawtooth-validator -vv --bind component:tcp://127.0.0.1:1001 --bind network:10.0.1.20:1003 --endpoint tcp://10.0.1.20:1003 --bind consensus:tcp://127.0.0.1:1004 --peering static --peers tcp://10.0.0.20:1003 --scheduler parallel &

#rest api
sawtooth-rest-api -v --bind 127.0.0.1:1002 --connect 127.0.0.1:1001 &

#processors
settings-tp -v --connect tcp://127.0.0.1:1001 &
#poet-validator-registry-tp -v --connect tcp://127.0.0.1:1001 &
intkey-tp-python -v --connect tcp://127.0.0.1:1001 &

#raft-engine
raft-engine -v --connect tcp://127.0.0.1:1004 &
