#!/bin/bash
# Kiem tra su dung tai nguyen VM OVZ
# ThangNV Nhan Hoa

rm -rf /usr/local/src/USED.csv
/usr/sbin/vzlist -a | grep -v STATUS | awk '{print $1}' > /usr/local/src/ids.txt

for line in `cat /usr/local/src/ids.txt`
do
status=`/usr/sbin/vzctl status $line |awk '{print $5}'`
ip=`/usr/sbin/vzctl exec $line "curl ifconfig.me"`
CPU=`/usr/sbin/vzctl exec $line cat /proc/cpuinfo | grep processor | wc -l`
mem=`/usr/sbin/vzctl exec $line free -m | grep Mem | awk '{printf $2}'`
umem=`/usr/sbin/vzctl exec $line free -m | grep Mem | awk '/^Mem/ {printf("%u%%", ($2-$4)/$2*100);}'`
disk=`/usr/sbin/vzctl exec $line df -h | grep /dev | grep -v none | grep -v mpfs | awk '{printf $2}'`
udisk=`/usr/sbin/vzctl exec $line df -h | grep /dev | grep -v none | grep -v mpfs | awk '{printf $5}'`
sdisk=`echo $udisk | rev | cut -c 2- | rev`
smem=`echo $umem | rev | cut -c 2- | rev`
if [ $sdisk -le 90 ]
then
Status="OK"
if [ $smem -le 90 ]
then
Smem="OK"
echo "$line, $ip, $CPU, $mem, $umem, $disk, $udisk, $status" >> /usr/local/src/USED.csv
else
Smem="FULL RAM"
echo "$line, $ip, $CPU, $mem, $umem, $disk, $udisk, $status, $Smem" >> /usr/local/src/USED.csv
fi

else
Status="DISK FULL"
if [ $smem -le 90 ]
then
Smem="OK"
echo "$line, $ip, $CPU, $mem, $umem, $disk, $udisk, $status, $Status" >> /usr/local/src/USED.csv
else
Smem="FULL RAM"
echo "$line, $ip, $CPU, $mem, $umem, $disk, $udisk, $status, $Status $Smem" >> /usr/local/src/USED.csv
fi
fi

done

sed -i '1iCTID, IP, CPU, Ram, Ram use, Disk, Disk use, Trang thai,' /usr/local/src/USED.csv
scp /usr/local/src/USED.csv root@103.101.161.38:/checkbk/`hostname`
scp /usr/local/src/USED.csv root@103.101.161.38:/checkmail/`hostname`.csv