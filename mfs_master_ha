#!/bin/bash
A=`ip a | grep 111 | wc -l`
B=`ps -C mfsmaster --no-header | wc -l`
if [ $A -ne 0 ];then
        if [ $B -eq 0 ];then
                /usr/sbin/mfsmaster -a
        fi
fi
if [ $A -ne 0 ];then
        if [ $HOSTNAME == mfs1 ];then
                c=mfs2
                /usr/bin/rsync -a /var/lib/mfs/ $c:/var/lib/mfs/
        fi
        if [ $HOSTNAME == mfs2 ];then
                c=mfs1
                /usr/bin/rsync -a /var/lib/mfs/ $c:/var/lib/mfs/
        fi
fi
