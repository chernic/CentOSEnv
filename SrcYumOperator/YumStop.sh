#!/bin/sh
#####################################################
# Version : 0.0.2
# Make by Chernic.Y.Chen @ Guangzhou China
# E-Mail : iamchernic@gmail.com
# Date : 2014-7-16
# v0.0.2(2014-7-18) : Add NotRootOut()
#####################################################
# This Shell Script has been Test on RHEL-5Server
#####################################################
# Add Debug Flag
export PS4='+[$LINENO]'
NotRootOut()
{
	[ $(id -u) != "0" ] && echo "Error: You must be root to run this script" && exit 1 
}

StopYumUpdate()
{
	# 手段一:关闭Yum自我更新服务程序
	cd /etc/init.d/
	[ -f yum-updatesd ] && yum-updatesd stop && echo "Yum Stoped ." || echo "yum-updatesd is Unfound, Try Another."
}

DelYumUpdatePid()
{
	# 手段二:结束Yum进程
	cd /var/run/
	[ -f yum.pid ] && rm -f yum.pid && echo "Yum Stoped ."|| echo "yum.pid is Unfound, Try NoMore."
}

# 问题：
# $ yum 
# File "/usr/bin/yum", line 30 
# except KeyboardInterrupt, e: 
                                         # ^
# SyntaxError: invalid syntax
 
# 原因：
# 这是因为yum采用python作为命令解释器，这可以从/usr/bin/yum文件中第一行#!/usr/bin/python发现。而python版本之间兼容性不太好，使得2.X版本与3.0版本之间存在语法不一致问题。而CentOS 5自带的yum采用的是python2.4，当系统将python升级到2.6或3.0后，出现语法解释错误。
 
# 解决办法：
# 很简单，一是升级yum，一是修改yum的解释器为旧版本python2.4（如果你没有采用覆盖升级的话）。
# 升级yum的作法就不详述了。修改yum的解释器为旧版本python2.4：
# $ vi /usr/bin/yum
# 将第一行"#!/usr/bin/python" 改为 "#!/usr/bin/python2.4"即可。
ISError1()
{
	# Answer0(http://bingu.net/692/yum-traceback-error/)
	# 在/root/.bashrc裡加一行：
	# alias yum='yum --disableplugin=fastestmirror'

	# Answer1
	# Python解释器问题
	sed -i "s/python2.4/python/" /usr/bin/yum;cat /usr/bin/yum
	
	# Answer2(http://www.linuxdiyf.com/viewarticle.php?id=160417)
	# 是国家防火墙在调试造成的，现在已经解决了。
	
	# Answer3(http://zcm8483.blog.163.com/blog/static/3886645200772495234986/)
	# vi /etc/sysconfig/i18n
	# LANG="zh_CN.GB2312"
	#More(http://blog.sina.com.cn/s/blog_54371f570100cci9.html)
	
	# Answer4(http://yyri.blog.sohu.com/155684738.html)
	# 原来是因为代理上网的，yum需要单独在/etc/yum.conf里边配置代理
	# proxy=http://172.1.1.1:808
}

ISError2()
{
	# all method
	echo "Clean Up Yum"
		yum remove yum-fastmirror
	echo "Clean Up Yum"
		yum clean metadata
	echo "Clean Up Yum"
		yum clean all
	echo "Remove rpm cache"
		rm -f /var/lib/rpm/__db*
	echo "ReBuid rpm"
		rpm --rebuilddb
}

Disablefastestmirror()
{
	AddFalg="# User specific aliases and functions"
	if [ `grep "disableplugin=fastestmirror" /root/.bashrc` != "" ];then
		if [ `grep "$AddFalg" /root/.bashrc` != "" ];then
			sed "/$AddFalg/a\alias yum='yum --disableplugin=fastestmirror'" /root/.bashrc
		else
			echo "Add Flag not Found."
			exit 0;
		fi
	fi
}


NotRootOut;
StopYumUpdate;
DelYumUpdatePid;