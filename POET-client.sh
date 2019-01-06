cd /home/manhattan/Desktop/demo/POET

#get ip address
IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -n 1)

#setup work directory
if [ -d "$IP" ]; then
  echo "Everything ready, start sawtooth"
else
  mkdir $IP
  cd /home/manhattan/Desktop/demo/POET/$IP
  mkdir data
  mkdir logs
  mkdir keys

  export SAWTOOTH_HOME=`pwd`

  #keys
  sawadm keygen
  sawtooth keygen
fi

cd /home/manhattan/Desktop/demo/POET/$IP
export SAWTOOTH_HOME=`pwd`


#validator
sawtooth-validator -vv --bind component:tcp://127.0.0.1:1001 --bind network:tcp://$IP:1003 --endpoint tcp://$IP:1003 --peers tcp://10.0.3.20:1003 &

#rest api
sawtooth-rest-api -v --bind 127.0.0.1:1002 --connect 127.0.0.1:1001 &

#processors
settings-tp -v --connect tcp://127.0.0.1:1001 &
poet-validator-registry-tp --connect tcp://127.0.0.1:1001 &
intkey-tp-python -v --connect tcp://127.0.0.1:1001 &
