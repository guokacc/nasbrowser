#! /bin/bash

PROC_NAME=main.go
ProcNumber=`ps -ef |grep -w $PROC_NAME|grep -v grep|wc -l`
if [ $ProcNumber -le 0 ];then
   echo "re run .."
   go run main.go
fi
