#!/bin/sh
#####################################################
# Version : 0.1.1
# Make by Chernic.Y.Chen @ Guangzhou China
# E-Mail : iamchernic@gmail.com
# Date : 2014-7-17
# v0.0.1(2014-7-18) : Add NotRootOut()
# v0.0.2(2014-7-18) : Add BreakPoint()
# v0.0.3(2014-7-24) : Add InstallGit()
#####################################################
# Add Debug Flag
export PS4='+[$LINENO]'
ORI_DIR="`pwd`" 
# 假如 当前目录有chernix标记(chernix是开发环境目录名),程序不执行
if [ `echo "$ORI_DIR" | grep -c "chernix"` == "1" ]; then
	echo -e "-------------------------------------------------------"
	echo -e "This directory is NOT allowed to execute. Try Another. "
	echo -e "-------------------------------------------------------"
	echo -e "for test. Use This."
	ORI_DIR="/home/focustar/chenyl/CcLocal"
fi
echo " // ORI_DIR=$ORI_DIR" 

# Default Configuration
GIT_ROOT="$ORI_DIR/gitroot"
REPO_NAME="newone.git"
REPO_GROUP="grouprepo"
REPO_USER="github"
TEST_MOD=$1

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
# 基础环境安装
###########################################
# 直接使用yum安装
InstallGit()
{
	yum -y install git
}


###########################################
# 目录工程文件创建
###########################################
AddNewUserOrPrint()
{
	PEOPLE=`cat /etc/passwd|grep "$REPO_USER" `
	if [ -z $PEOPLE ];
		then
			adduser $REPO_USER
			echo "github2014" | passwd $REPO_USER --stdin
		else
			echo -ne " // Exited. ID of $REPO_USER = "
			echo $PEOPLE | awk -F : '{print $3}'
	fi
	echo ""
}
CreateRoot()
{	
	cd $ORI_DIR
	if [ -d gitroot ];then
		echo " // gitroot Existing."
	else
		mkdir -v gitroot
		echo " // gitrootcreated successful."
	fi
	echo ""
}
CreateProject()
{
	cd $GIT_ROOT
	
	echo " // TEST_MOD=$TEST_MOD"
	if [ "$TEST_MOD" == '-t' ]; then
		rm * -rf
	fi

	# 创建git
	if [ -d newone.git ];then
		echo " // Project was Exited. Exit."
		exit 0
	else
		git init --bare newone.git
	fi
	
	echo " // gitrootcreated successful."
	cd $REPO_NAME
	#增加一个分支
	mkdir -v initial.commit  
	git init 
	
	# 增加服务器
	git remote add Local $GIT_ROOT/$REPO_NAME
	# origin 留给github
	git remote add orgin https://github.com/chernic/$REPO_NAME
	
	git remote -v
	echo ""
}
CreateFile()
{
	cd $GIT_ROOT/$REPO_NAME
	echo "Short project description" >README.txt
	git add README.txt
	git commit -a -m "inital commit"
	git push Local master
	echo ""
}


###########################################
# 权限设置（可选）
###########################################
ChangeUserGroup()
{
	PEOPLE=`cat /etc/passwd|grep "$REPO_USER" `
	if [ -z $PEOPLE ];
		then
			adduser $REPO_USER
			echo "0000" | passwd $REPO_USER --stdin
		else
			echo -ne " // Exited. ID of $REPO_USER = "
			echo $PEOPLE | awk -F : '{print $3}'
	fi
	usermod -a -G grouprepo $REPO_USER
}
ChangeRootRight()
{
	cd $GIT_ROOT
	chmod -v g+rx .
	# 改变Git根目录权限
	chown -v :grouprepo .
}
ChangeProjectRight()
{
	cd $GIT_ROOT/$REPO_NAME
	# 改变文件夹所属用户组
	chown -vR :grouprepo .
	# 文件夹所属用户组的用户皆能访问
	git config core.sharedRepository group
	# 更改文件文件夹属性
	find . -type d -print0 | xargs -0 chmod 2770
	find . -type f -print0 | xargs -0 chmod g=u
}

###########################################
# 连接测试（可选）
###########################################
ClientCloneTest()
{
	cd $GIT_ROOT
	git clone $REPO_USER@192.168.1.97:$GIT_ROOT/$REPO_NAME newtest2
}

NotRootOut;

# Install
InstallGit

# Create
AddNewUserOrPrint;
CreateRoot;
CreateProject;
CreateFile;

# Change Right
ChangeUserGroup;
ChangeRootRight;
ChangeProjectRight;

# Test
ClientCloneTest;