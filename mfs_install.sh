echo "1 install mfs to node"
echo "2 install master on current node"
echo "3 install chunkserver on current node"
echo
read -p "pls input your choise [1]: " n

case $n in
1)
read -p "pls input node name: " node
scp -r mfs $node:/root/
scp mfs.repo $node:/etc/yum.repos.d/
scp mfs_install.sh $node:/root/
;;

2)
read -p "pls input mfs storage networking as [192.168.20.0/24]: " network
yum -y install moosefs-master moosefs-cgi moosefs-cgiserv moosefs-cli
cat >> /etc/rc.local << EOF
mfsmaster start
mfscgiserv start
EOF
cat > /etc/mfs/mfsexports.cfg << EOF
$network / rw,alldirs,admin,maproot=0:0
EOF
chmod 755 /etc/rc.d/rc.local

mfsmaster start
mfscgiserv start
ss -nlpt |grep 94
echo "goto http://ip:9425"
;;

3)
read -p "pls input master node: " master
read -p "pls provide mount point of chunkserver [/data]: " data
read -p "pls provide local mfs client mount point [/mfs]: " mfs

yum -y install moosefs-chunkserver moosefs-client
chown mfs:mfs $data
mkdir $mfs

cat >> /etc/mfs/mfschunkserver.cfg << EOF
MASTER_HOST = $master
EOF
cat >> /etc/mfs/mfshdd.cfg << EOF
$data
EOF
mfschunkserver start

cat >> /etc/rc.local << EOF
mfschunkserver start
mfsmount -H $master $mfs
EOF
chmod 755 /etc/rc.d/rc.local

mfsmount -H $master $mfs
ss -nlpt |grep 94
sleep 5
df -hT |grep mfs
;;

*)
echo "pls input 1-3 choise item"
exit;

esac
