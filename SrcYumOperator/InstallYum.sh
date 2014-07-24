#!/bin/bash
#####################################################
# Version : 0.0.2
# Make by Chernic.Y.Chen @ China
# E-Mail : iamchernic@gmail.com
# Date : 2014-6-12
# v0.0.2(2014-7-18) : Add NotRootOut()
# v0.0.3(2014-7-18) : Add Dir
#####################################################
# This Shell Script has been Test on RHEL-5Server
#####################################################
# 获取本文件所在路径
BUILD_DIR=`pwd`
# Add Debug Flag
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
	
	echo "What's in This System :"
	echo "Wait 1"
	rpm -aq|grep yum;
	echo "Wait 2"
	rpm -aq|grep python-iniparse;
	echo "Wait 3"
	rpm -aq|grep epel-release;
	echo "Wait 4"
	rpm -aq|grep rpmforge-release;
}


###########################################
# 除旧
###########################################
RemoveOldRpms()
{
	BreakPoint;
	echo "Wait 1"
	rpm -aq|grep yum|xargs rpm -e --nodeps
	echo "Wait 2"
	rpm -aq|grep python-iniparse|xargs rpm -e --nodeps
	echo "Wait 3"
	rpm -aq|grep epel-release|xargs rpm -e --nodeps
	echo "Wait 4"
	rpm -aq|grep rpmforge-release|xargs rpm -e --nodeps
}
RemoveOldRepo()
{
	BreakPoint;
	echo "remove all old repoes. Because you know how to Make it."
	ls /etc/yum.repos.d/; 
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
###########################################
ManualRepo()
{

	echo "************** Get all new repoes"
	# CentOS - [Necessary]
	cd $BUILD_DIR/Repos
	echo "******* Manually Copy 163.repo"
	cp CentOS5-Base-163.repo          /etc/yum.repos.d/
	# # # CentOS - Copy From Other System
	# # cp CentOS-Base.repo               /etc/yum.repos.d/
	# # cp CentOS-Debuginfo.repo          /etc/yum.repos.d/
	# # cp CentOS-Media.repo              /etc/yum.repos.d/
	# # cp CentOS-Vault.repo              /etc/yum.repos.d/
	echo "******* EPEL.rpm had Helped us to Add Repos"
	# cp epel.repo                    /etc/yum.repos.d/
	# cp epel-testing.repo            /etc/yum.repos.d/
	echo "******* rpmforge.rpm had Helped us to Add Repos"
	# cp rpmforge.repo                /etc/yum.repos.d/
	# cp mirrors-rpmforge             /etc/yum.repos.d/
	# cp mirrors-rpmforge-extras      /etc/yum.repos.d/
	# cp mirrors-rpmforge-testing     /etc/yum.repos.d/
	#################
	# 人工优化配置Reps
	#################
	# rpmforge的优化(注释RHEL-rpmforge-CCmirrors里速度慢的连接)
	# cp RHEL-rpmforge-CCmirrors.repo /etc/yum.repos.d/
	# cp RHEL-rpmforge-CCmirrors      /etc/yum.repos.d/
}

###########################################
# 测试
###########################################
YumTest()
{
	# 查看所有Repoes
	echo " // Find all Repoes"
	ls /etc/yum.repos.d/
	echo " // List all Repoes"
	yum repolist all
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

# 测试
YumTest;


# # 命令将服务器上的 软件包 信息 现在本地缓存，以提高 搜索 安装软件的速度
# echo "******* Make Cache"
# yum makecache

# 风速慢的话可以通过增加yum的超时时间，这样就不会总是因为超时而退出。 
# vi /etc/yum.conf 
# 加上这么一句：timeout=120 

# [clusterlabs-next]
# name=High Availability/Clustering server technologies (epel-5-next)
# baseurl=http://www.clusterlabs.org/rpm-next/epel-5
# metadata_expire=45m
# type=rpm-md
# gpgcheck=0
# enabled=1