cd /home/manhattan/Desktop/demo/POET
#get ip address
IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -n 1)

#setup work directory
if [ -d "$IP" ]; then
  echo "Everything ready, start sawtooth"
else
  #create folders
  mkdir $IP
  cd /home/manhattan/Desktop/demo/POET/$IP
  mkdir data
  mkdir logs
  mkdir keys
  export SAWTOOTH_HOME=`pwd`

  #create peer keys
  sawadm keygen
  sawtooth keygen

  #generate genesis
  sawset genesis -k keys/validator.priv -o config-genesis.batch

  sawset proposal create -k keys/validator.priv -o config.batch \
  sawtooth.consensus.algorithm=poet \
  sawtooth.poet.report_public_key_pem="$(cat /etc/sawtooth/simulator_rk_pub.pem)" \
  sawtooth.poet.valid_enclave_measurements=$(poet enclave measurement) \
  sawtooth.poet.valid_enclave_basenames=$(poet enclave basename) \
  sawtooth.validator.max_transactions_per_block=10

  poet registration create -k keys/validator.priv -o poet.batch

  sawset proposal create -k keys/validator.priv \
  -o poet-settings.batch \
  sawtooth.poet.target_wait_time=5 \
  sawtooth.poet.initial_wait_time=25 \
  sawtooth.publisher.max_batches_per_block=100

  sawadm genesis config-genesis.batch config.batch poet.batch poet-settings.batch
fi

cd /home/manhattan/Desktop/demo/POET/$IP
export SAWTOOTH_HOME=`pwd`

#validator
sawtooth-validator -vv --bind component:tcp://127.0.0.1:1001 --bind network:tcp://$IP:1003 --endpoint tcp://$IP:1003 --peering dynamic &

#rest api
sawtooth-rest-api -v --bind 127.0.0.1:1002 --connect 127.0.0.1:1001 &

#processors
settings-tp -v --connect tcp://127.0.0.1:1001 &
poet-validator-registry-tp --connect tcp://127.0.0.1:1001 &
python3 /home/manhattan/Desktop/demo/bin/int_key-tp -v --connect tcp://127.0.0.1:1001 &
