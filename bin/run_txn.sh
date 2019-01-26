#!/bin/bash
#validate parms
while getopts "hs:t:" arg; do
    case $arg in
        h)
            echo "-r <rate to send transactions>"
            echo "-c <how many transaction"
            echo "example: -s 2 -c 5 <every two seconds sen 5 txn>"
            ;;
        s)
            rate=$OPTARG
            echo "Setting rate to:" $rate
            ;;
        t)
            txn_count=$OPTARG
            echo "Setting count to:" $txn_count
            ;;
  esac
done

#assign default values
if [ -z "$rate" ]
    then
        rate=2
fi

if [ -z "$txn_count" ]
    then
        txn_count=1
fi

echo "Rate: " $rate
echo "# Transactions: " $txn_count

#go to images folder
cd /home/"$USER"/Desktop/testbed/iot_tp/images
#start sending transactions
while true
do
    for (( c=1; c<=$txn_count; c++ ))
        do
            pick random image and process transaction
            image=`ls * | shuf -n 1`
            echo "python3 /home/$USER/Desktop/testbed/bin/iot_tp.py send $image"
            python3 /home/"$USER"/Desktop/testbed/bin/iot_tp.py send "$image"
            #move the image to an archive folder, avoid duplicates txn
            mv "$image" /home/"$USER"/Desktop/testbed/iot_tp/archive
            #check if we still images to process
            image_count=`ls | wc -l`
            if [ "$image_count" -eq 0  ]
                then
                    echo "No more images"
                    exit
            fi
    done
    sleep $rate
done
