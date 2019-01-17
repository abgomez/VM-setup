#!/usr/bin/env bash
cd /home/manhattan/Desktop/demo
pwd
export SAWTOOTH_HOME=`pwd`

#generate genesis
sawset genesis -k keys/validator.priv -o config-genesis.batch
sawadm genesis config-genesis.batch

#validator
sawtooth-validator -vv &

#rest api
sawtooth-rest-api -v &

#processors
settings-tp -v &
#intkey-tp-python -v &
