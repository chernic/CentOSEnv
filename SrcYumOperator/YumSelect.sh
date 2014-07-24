#!/bin/sh
#####################################################
# Version : 0.0.1
# Make by Chernic.Y.Chen @ China
# E-Mail : iamchernic@gmail.com
# Date : 2014-6-12
#####################################################
# This Shell Script has been Test on RHEL-5Server
#####################################################
export PS4='+[$LINENO]'

# [获取本文件路径 的 文件名称] 即本文件名的配置文件
CONF_FILE=$(basename $0 .sh).conf
WGET_FILE=WgetSrc.conf
# 判断对应文件是否存在,若存在则导入
[ -f $CONF_FILE ] && . $CONF_FILE
[ -f $WGET_FILE ] && . $WGET_FILE
REPO_DIR=/etc/yum.repos.d/
# Add Debug Flag
AUTO_FLAG_yn="n"
BreakPoint()
{
	while [ "$AUTO_FLAG_yn" != "y" ]
	do
		read -p "Do you Make Sure to Continue? [y/n/q] " AUTO_FLAG_yn;
		[ "$AUTO_FLAG_yn" == "q" ] && exit 0;
	done
}

EnableRepo()
{
	# 找出指定行并修改
	echo " // Change $1.repo"
	FILE=$REPO_DIR/$1.repo
	lss=$1
	ss=$(grep -n '^\['$lss'\]' $FILE | cut -d ':' -f 1)
	sed -i  $ss',/enabled/ s/enabled.*/enabled=1/' $FILE
	grep 'enabled' $FILE
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


if [ "$yum_epel" == '1' ];then
	EnableRepo "epel"
else
	DisableRepo;
fi

if [ "$yum_rpmforge" == '1' ];then
	EnableRepo "rpmforge"
else
	DisableRepo;
fi


BreakPoint;
yum repolist all;


