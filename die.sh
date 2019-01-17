#!/usr/bin/env bash
ps aux | grep python3 | grep -v git |awk '{print $2}' | xargs kill -9
rm /home/manhattan/Desktop/demo/data/*
