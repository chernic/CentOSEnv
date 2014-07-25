#!/bin/sh
#####################################################
# Version : 0.0.1
# Make by Chernic.Y.Chen @ China
# E-Mail : iamchernic@gmail.com
# Date : 2014-6-12
#####################################################
# This Shell Script has been Test on RHEL-5
#####################################################
FILENAME=/etc/sysconfig/network-scripts/ifcfg-eth0
C_HOSTNAME=CactiTest
C_IPADDR=192.168.0.96
C_NETMASK=255.255.255.0

# 删除除HWADDR以外的信息
sed -i '/^DEVICE.*/d'               $FILENAME 
sed -i '/^BOOTPROTO.*/d'            $FILENAME 
sed -i '/^DHCPCLASS.*/d'            $FILENAME 
sed -i '/^HOSTNAME.*/d'             $FILENAME
sed -i '/^IPADDR.*/d'               $FILENAME
sed -i '/^NETMASK.*/d'              $FILENAME
sed -i '/^DNS1.*/d'                 $FILENAME
sed -i '/^DNS2.*/d'                 $FILENAME
sed -i '/^MTU.*/d'                  $FILENAME
sed -i '/^NM_CONTROLLED.*/d'        $FILENAME
sed -i '/^ONBOOT.*/d'               $FILENAME

# file 删除文件中的空行
sed -i /^[[:space:]]*$/d            $FILENAME
echo "##### What's Lefted in ifcfg-eth0: "
cat -v                              $FILENAME
echo " "

# # 修改Cacti主机的网络信息
sed -i '2a DEVICE=eth0'             $FILENAME 
sed -i '3a BOOTPROTO=dhcp'          $FILENAME 
sed -i '4a HOSTNAME='$C_HOSTNAME    $FILENAME
sed -i '5a DHCPCLASS='              $FILENAME
sed -i '6a ONBOOT=yes'              $FILENAME
echo "##### What's in ifcfg-eth0:"
cat -v                              $FILENAME
echo " "

# 重启网络服务
service network restart
echo " "

# 测试网络
ping 192.168.0.1 -c 4
echo " "