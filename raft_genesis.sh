#path setup
mkdir data
mkdir logs
mkdir keys

export SAWTOOTH_HOME=`pwd`

#keys
sawadm keygen
sawtooth keygen

#genesis
sawset genesis -k keys/validator.priv -o config-genesis.batch

sawset proposal create -k keys/validator.priv -o config.batch \
sawtooth.consensus.algorithm=raft \
sawtooth.consensus.raft.peers=["03796aa411cc2462df2f10d3d2875d6b1a474757abd38d101b24e09eb6228f374e"] \
sawtooth.validator.max_transactions_per_block=10

sawset proposal create -k keys/validator.priv \
-o raft-settings.batch \
sawtooth.consensus.raft.heartbeat_tick=2 \
sawtooth.consensus.raft.election_tick=20 \
sawtooth.consensus.raft.period=3000 \
sawtooth.publisher.max_batches_per_block=100

sawadm genesis config-genesis.batch config.batch #raft-settings.batch

#validator
sawtooth-validator -vv --bind component:tcp://127.0.0.1:1001 --bind network:127.0.0.1:1003 --endpoint tcp://127.0.0.1:1003 -- bind consensus:tcp://127.0.0.1:5050 --peering static &

#rest api
sawtooth-rest-api -v --bind 127.0.0.1:1002 --connect 127.0.0.1:1001 &

#processors
settings-tp -v --connect tcp://127.0.0.1:1001 &
#poet-validator-registry-tp -v --connect tcp://127.0.0.1:1001 &
intkey-tp-python -v --connect tcp://127.0.0.1:1001 &

#raft-engine
raft-engine -v --connect tcp://127.0.0.1:5050 &

