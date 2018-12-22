#path setup
#cd /home/lab/Desktop/genesis
mkdir data
mkdir logs
mkdir keys

export SAWTOOTH_HOME=`pwd`
export SAWTOOTH_RAFT_HOME=`pwd`

#keys
sawadm keygen
sawtooth keygen

#genesis
sawset genesis -k keys/validator.priv -o config-genesis.batch

sawset proposal create -k keys/validator.priv -o config.batch \
sawtooth.consensus.algorithm=raft \
sawtooth.consensus.raft.peers=["027a7c73190a99b0138187a49cc8557ff21ec1000087d2498591aadebf711f754a", "0325eb668fc6054bcdda0a0162c013274dba5b9c54bc9dddb32813a7aaa9fde855"]
#sawtooth.validator.max_transactions_per_block=10

sawset proposal create -k keys/validator.priv \
-o raft-settings.batch \
sawtooth.consensus.raft.heartbeat_tick=2 \
sawtooth.consensus.raft.election_tick=20 \
sawtooth.consensus.raft.period=3000 \
sawtooth.publisher.max_batches_per_block=100

sawadm genesis config-genesis.batch config.batch #raft-settings.batch

#validator
sawtooth-validator -vv --bind component:tcp://127.0.0.1:1001 --bind network:10.0.0.20:1003 --endpoint tcp://10.0.0.20:1003 --bind consensus:tcp://127.0.0.1:1004 --peering static --scheduler parallel &

#rest api
sawtooth-rest-api -v --bind 127.0.0.1:1002 --connect 127.0.0.1:1001 &

#processors
settings-tp -v --connect tcp://127.0.0.1:1001 &
#poet-validator-registry-tp -v --connect tcp://127.0.0.1:1001 &
intkey-tp-python -v --connect tcp://127.0.0.1:1001 &

#raft-engine
raft-engine -v --connect tcp://127.0.0.1:1004 &
