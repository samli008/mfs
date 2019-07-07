#config local yum source
cd /etc/yum.repos.d/
rm -rf *
cat > /etc/yum.repos.d/hpc_mfs.repo << EOF
[mfs]
name=mfs
baseurl=file:///root/mfs
enabled=1
gpgcheck=0
[hpc]
name=hpc
baseurl=file:///root/openhpc
enabled=1
gpgcheck=0
EOF

#config master node
yum -y install moosefs-master moosefs-cgi moosefs-cgiserv moosefs-cli
mfsmaster start
mfscgiserv start
sleep 5
echo "mfsmaster -a" >> /etc/rc.local
echo "mfscgiserv start" >> /etc/rc.local
echo "sleep 5" >> /etc/rc.local

#config local disk to mfs use
for i in {1..3};do ssh node$i mkdir /data;done
for i in {1..3};do ssh node$i mkfs.xfs /dev/vdb;done
for i in {1..3};do ssh node$i "echo /dev/vdb /data xfs defaults 0 0 >> /etc/fstab";done
for i in {1..3};do ssh node$i mount -a;done

#config chunkserver on each nodes
for i in {1..3};do ssh node$i yum -y install moosefs-chunkserver moosefs-client;done
for i in {1..3};do ssh node$i chown mfs:mfs /data;done
for i in {1..3};do ssh node$i "echo MASTER_HOST=node1 >> /etc/mfs/mfschunkserver.cfg";done
for i in {1..3};do ssh node$i "echo /data >> /etc/mfs/mfshdd.cfg";done
for i in {1..3};do ssh node$i mfschunkserver start;done
for i in {1..3};do ssh node$i "echo mfschunkserver start >> /etc/rc.local";done

#config mfs client mount
for i in {1..3};do ssh node$i mkdir /mfs;done
for i in {1..3};do ssh node$i mfsmount -H node1 /mfs;done
for i in {1..3};do ssh node$i "echo mfsmount -H node1 /mfs >> /etc/rc.local";done

for i in {1..3};do ssh node$i chmod 755 /etc/rc.d/rc.local;done
