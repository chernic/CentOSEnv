#!/bin/bash
#####################################################
# Template
#####################################################
# Version : 0.0.2
# Make by Chernic.Y.Chen @ China
# E-Mail : iamchernic@gmail.com
# Date : 2014-6-12
# v0.0.2(2014-7-25) :  DNS(8:8:8:8) is down.
# v0.0.3(2014-7-25) :  No Ok In RHEL57
#####################################################
# This Shell Script has been Test on RHEL-5

export PS4='+[$LINENO]'
AUTO_FLAG_yn="n"
BreakPoint()
{
	while [ "$AUTO_FLAG_yn" != "y" ]
	do
		read -p "Do you Make Sure to Continue? [y/n/q] " AUTO_FLAG_yn;
		[ "$AUTO_FLAG_yn" == "q" ] && exit 0;
	done
}

NotRootOut()
{
	[ $(id -u) != "0" ] && echo "Error: You must be root to run this script" && exit 1 
}

############### Template Version 0.0.6 ##############
FILENAME=/etc/sysconfig/network-scripts/ifcfg-eth0

SetTarget()
{
	C_HOSTNAME=CactiNew
	C_IPADDR=192.168.0.96
	C_NETMASK=255.255.255.0
	
	echo ""
	echo "Configure now is"
	echo "  C_HOSTNAME=$C_HOSTNAME";
	echo "  C_IPADDR=$C_IPADDR";
	echo "  C_NETMASK=$C_NETMASK";
	echo ""
		
	Sure="0"
	while [ "$Sure" != "y" ] && [ "$Sure" != "n" ];
	do
		read -p "Are you sure? (y or n):" Sure;
	done
	
	# checking is not enough.
	if [ "$Sure" == "n" ]; then
		read -p "Change <CactiTest>    : C_HOSTNAME="  C_HOSTNAME
		read -p "Change <192.168.0.96> : C_IPADDR  ="  C_IPADDR
		read -p "Change <255.255.255.0>: C_NETMASK ="  C_NETMASK
	fi
}

ShowTarget()
{
	echo ""
	echo "Configure now is"
	echo "  C_HOSTNAME=$C_HOSTNAME";
	echo "  C_IPADDR=$C_IPADDR";
	echo "  C_NETMASK=$C_NETMASK";
	echo ""
	BreakPoint;
}

DeleteOld()
{
	# 删除除HWADDR以外的信息
	sed -i '/^DEVICE.*/d'               $FILENAME 
	sed -i '/^BOOTPROTO.*/d'            $FILENAME 
	sed -i '/^DHCPCLASS.*/d'            $FILENAME 
	sed -i '/^HOSTNAME.*/d'             $FILENAME
	sed -i '/^IPADDR.*/d'               $FILENAME
	sed -i '/^NETMASK.*/d'              $FILENAME
	sed -i '/^GATEWAY.*/d'              $FILENAME
	sed -i '/^NETWORK.*/d'              $FILENAME
	sed -i '/^BOARDCAST.*/d'            $FILENAME
	sed -i '/^DNS1.*/d'                 $FILENAME
	sed -i '/^DNS2.*/d'                 $FILENAME
	sed -i '/^MTU.*/d'                  $FILENAME
	sed -i '/^NM_CONTROLLED.*/d'        $FILENAME
	sed -i '/^ONBOOT.*/d'               $FILENAME
	sed -i '/^TYPE.*/d'                 $FILENAME

	##### sed '/^ *$/d'
	# file 删除文件中的空行
	# 因为由于特殊字符(^M)的存在
	# 空行并不是真的空行（^$）没有效果
	##### sed /^[[:space:]]*$/d 
	# [[:space:]]表示空格或者tab的集合，还匹配了^M这个不可见的换行符号
	# 另外，注意到[[:space:]]后面跟着一个*，表示匹配0个或多个。
	##### sed '/^/s*$/d'   (v)[考证后不行]
	# [[:space:]]可以用/s表示
	##### sed /^/s*$/d     (X)
	# 但是使用转义字符，一定要对命令添加引号
	sed -i /^[[:space:]]*$/d            $FILENAME
	echo "##### What's Lefted in ifcfg-eth0: "
	cat -v                              $FILENAME
	echo " "
}

AddNew()
{
	# # 修改Cacti主机的网络信息
	sed -i '2a DEVICE=eth0'             $FILENAME 
	sed -i '3a BOOTPROTO=static'        $FILENAME 
	sed -i '4a HOSTNAME='$C_HOSTNAME    $FILENAME
	sed -i '5a IPADDR='$C_IPADDR        $FILENAME
	sed -i '6a NETMASK='$C_NETMASK      $FILENAME
	sed -i '7a NETWORK=192.168.0.0'     $FILENAME
	sed -i '8a GATEWAY=192.168.0.1'     $FILENAME
	sed -i '9a BOARDCAST=192.168.0.255' $FILENAME
	sed -i '10a DNS1=192.168.0.1'       $FILENAME
	sed -i '11a DNS2=114.114.114.114'   $FILENAME
	sed -i '12a ONBOOT=yes'             $FILENAME
	# sed -i '13a MTU=1500'               $FILENAME
	# sed -i '14a NM_CONTROLLED=yes'      $FILENAME
	# sed -i '15a TYPE=yes'               $FILENAME
	echo "##### What's in ifcfg-eth0:"
	cat -v                              $FILENAME
	echo " "
}

# 判断权限
NotRootOut;

# 配置网络
SetTarget;
# 展示配置
ShowTarget;

# 删除旧配置
DeleteOld;
# 进行新配置
AddNew;

# 重启网络服务
echo " // Restart Service Network "
service network restart

# 测试网络
echo " // Check Ping "
ping 192.168.0.1 -c 4
