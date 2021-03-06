#!/bin/bash
#####################################################
# Fuction of yum install
#####################################################
# Version : 0.0.6
# Make by Chernic.Y.Chen @ China
# E-Mail : iamchernic@gmail.com
# Date : 2014-7-22
# v0.0.2(2014-7-18) : Add NotRootOut()
# v0.0.3(2014-7-18) : Add Dir
# v0.0.4(2014-7-24) : Add Aliyum Mirror
#####################################################
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

GetIPAddress()
{
	IPAddress=`ifconfig eth0 | grep 'inet addr' | cut -d ":" -f 2 | cut -d " " -f 1`
}

ReadConf()
{
	# [获取本文件路径中 的 文件名称] 即本文件名的配置文件
	CONF_FILE=$(basename $0 .sh).conf
	# 判断对应文件是否存在,若存在则导入
	[ -f $CONF_FILE ] && . $CONF_FILE
}
############### Template Version 0.0.6 ##############
# 获取本文件所在路径
BUILD_DIR=`pwd`





###########################################
# 检查
###########################################
CheckRpms()
{
	echo -e "A standard RHEL may have Such Libs :"
	echo -e "yum-metadata-parser-1.1.2-3.el5"
	echo -e "yum-security-1.1.16-16.el5"
	echo -e "yum-3.2.22-37.el5"
	echo -e "yum-rhn-plugin-0.5.4-22.el5"
	echo -e "yum-updatesd-0.9-2.el5\n"
	
	echo " // What's in This System :"
	echo "  Grep yum"
	rpm -aq|grep yum;
	echo " Grep python-iniparse"
	rpm -aq|grep python-iniparse;
	echo "  Grep epel-release"
	rpm -aq|grep epel-release;
	echo "  Grep rpmforge-release"
	rpm -aq|grep rpmforge-release;
}


###########################################
# 除旧
###########################################
RemoveOldRpms()
{
	BreakPoint;
	echo "  Uninstall yum... Wait 1"
	rpm -aq|grep yum|xargs rpm -e --nodeps
	echo "  Uninstall python-iniparse... Wait 2"
	rpm -aq|grep python-iniparse|xargs rpm -e --nodeps
	echo "  Uninstall epel-release... Wait 3"
	rpm -aq|grep epel-release|xargs rpm -e --nodeps
	echo "  Uninstall rpmforge-release... Wait 4"
	rpm -aq|grep rpmforge-release|xargs rpm -e --nodeps
}
RemoveOldRepo()
{
	echo "What's in /etc/yum.repos.d/ :"
	ls /etc/yum.repos.d/; 
	echo " !!! remove all old repoes. Because you knew how to Make it."	
	
	BreakPoint;
	rm /etc/yum.repos.d/* -f
}


###########################################
# 迎新
###########################################
InstallNewYum()
{
	echo "Install New yum"
	cd $BUILD_DIR/rpm
	
	rpm -ivh python-iniparse*.rpm  yum*.rpm
	rpm -ivh epel-release-*.rpm
	rpm -ivh rpmforge-release-*.rpm
}
InstallNewRepo()
{
	# 导入后路径(etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5)
	cd $BUILD_DIR/Repos
	echo "******* Inport RPM-GPG-KEYs"
	rpm --import RPM-GPG-KEY-CentOS-5
	rpm --import RPM-GPG-KEY-EPEL-5
	rpm --import RPM-GPG-KEY.dag.txt
}

###########################################
# 配置reps
# RHEL 须直接标明版本
# 不使用包检查
###########################################

CentOsAliyunRepo()
{
	if [ -n "$(cat /etc/redhat-release | grep '6\.')" ];then
		# Aliyun
		wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo
		sed -i 's@\$releasever@6@g' /etc/yum.repos.d/CentOS-Base.repo
		sed -i 's@gpgcheck=1@gpgcheck=0@g' /etc/yum.repos.d/CentOS-Base.repo	
	elif [ -n "$(cat /etc/redhat-release | grep '5\.')" ];then
		# Aliyun
		wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-5.repo
		sed -i 's@\$releasever@5@g' /etc/yum.repos.d/CentOS-Base.repo
		sed -i 's@gpgcheck=1@gpgcheck=0@g' /etc/yum.repos.d/CentOS-Base.repo	
	fi
}
CentOs163Repo()
{
	if [ -n "$(cat /etc/redhat-release | grep '6\.')" ];then
		wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS6-Base-163.repo
		sed -i 's@\$releasever@6@g' /etc/yum.repos.d/CentOS-Base.repo
		sed -i 's@gpgcheck=1@gpgcheck=0@g' /etc/yum.repos.d/CentOS-Base.repo
		# Sina163	
	elif [ -n "$(cat /etc/redhat-release | grep '5\.')" ];then
		wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS5-Base-163.repo
		sed -i 's@\$releasever@5@g' /etc/yum.repos.d/CentOS-Base.repo
		sed -i 's@gpgcheck=1@gpgcheck=0@g' /etc/yum.repos.d/CentOS-Base.repo
		# Sina163
	fi
}

DisableRepo()
{
	# 找出指定行并修改
	echo " // Change $1.repo"
	FILE=$REPO_DIR/$1.repo
	lss=$1
	ss=$(grep -n '^\['$lss'\]' $FILE | cut -d ':' -f 1)
	sed -i  $ss',/enabled/ s/enabled.*/enabled=0/' $FILE
	grep 'enabled' $FILE
}

ManualRepo()
{
	echo "******* EPEL.rpm had Helped us to Add Repos"
	echo "******* rpmforge.rpm had Helped us to Add Repos"	
	
	cd $BUILD_DIR/Repos	
	echo "******* Add XXX.repo"

	MIRROR=local
	BASE=Sina163	
	if [ ! -z "$(cat /etc/redhat-release | grep 'Red Hat')" ];then
		MIRROR=local
	fi
	if [ "$BASE" == "Sina163" ] && [ "$MIRROR" == "web" ] ;then
		CentOs163Repo;
	elif [ "$BASE" == "Alinyun" ] && [ "$MIRROR" == "web" ] ;then
		CentOsAliyunRepo;
	elif [ "$BASE" == "Sina163" ] && [ "$MIRROR" == "local" ] ;then
		cp CentOS5-Base-163.repo   		/etc/yum.repos.d/
	elif [ "$BASE" == "Alinyun" ] && [ "$MIRROR" == "local" ] ;then
		cp CentOS5-Base-aliyun.repo     /etc/yum.repos.d/
	else
		exit 0
	fi
	
	#################
	# 人工优化配置Reps
	#################
	# rpmforge的优化(注释RHEL-rpmforge-CCmirrors里速度慢的连接)
	# cp RHEL-rpmforge-CCmirrors.repo /etc/yum.repos.d/
	# cp RHEL-rpmforge-CCmirrors      /etc/yum.repos.d/
}


ManulPython24()
{
	sed -i 's@#!/usr/bin/python@#!/usr/bin/python2.4@g' /usr/bin/yum  
}


###########################################
# 测试
###########################################
YumTest()
{
	# 查看所有Repoes

	echo " // Find all Repoes"
	ls /etc/yum.repos.d/
	
	# 命令将服务器上的 软件包 信息 现在本地缓存，以提高 搜索 安装软件的速度
	echo " // MakeCaches"
	yum makecache	
	echo " // List all Repoes"
	yum repolist all
	
	# 风速慢的话可以通过增加yum的超时时间，这样就不会总是因为超时而退出。 
	# vi /etc/yum.conf 
	# 加上这么一句：timeout=120 	
}

NotRootOut;
# 检查
CheckRpms;

# 清除
RemoveOldRpms;
RemoveOldRepo;

# 部署
InstallNewYum;
InstallNewRepo;
ManualRepo;
ManulPython24;

# 测试
YumTest;