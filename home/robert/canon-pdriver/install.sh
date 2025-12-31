#!/bin/bash

##############################################################################
##
##  Canon Laser Printer Driver for Linux
##  Copyright CANON INC. 2015
##
##  This program is free software; you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 2 of the License, or
##  (at your option) any later version.
##
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with this program; if not, write to the Free Software
##  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
##
##############################################################################


#-------------------------------------------------#
# install package list define
#  0x01:CARPS2/UFR2LT Driver
#  0x02:LIPSLX/UFR2 Driver
#  0x04:LIPS4 Driver
#-------------------------------------------------#
INSTALL_PACKAGE_RPM_32="
0x07:cups
0x04:ghostscript
0x02:libjpeg-turbo
0x06:libgcrypt
0x07:gtk3
0x03:jbigkit-libs
0x04:zlib
0x06:redhat-lsb-core"

REPLACE_PACKAGE_RPM_32="
redhat-lsb-core,neokylin-lsb-core
zlib,zlib-ng-compat"

INSTALL_PACKAGE_RPM_64="
0x07:cups
0x04:ghostscript
0x02:libjpeg-turbo
0x06:libgcrypt
0x07:gtk3
0x03:jbigkit-libs
0x04:zlib
0x06:redhat-lsb-core"

REPLACE_PACKAGE_RPM_64="
redhat-lsb-core,neokylin-lsb-core,lsb_release
zlib,zlib-ng-compat"

INSTALL_PACKAGE_DEB_32="
0x07:cups
0x07:cups-bsd
0x07:libcups2
0x03:libcupsimage2
0x04:ghostscript
0x07:libgtk-3-0
0x02:libjpeg62
0x06:libgcrypt20
0x03:libjbig0
0x04:zlib1g
0x06:lsb-release"

REPLACE_PACKAGE_DEB_32="
cups,cupsys
libcups2,libcups2t64,libcupsys2
libcupsimage2,libcupsimage2t64
libjpeg62,libjpeg62-turbo
libgcrypt20,libbeecrypt7
libgtk-3-0,libgtk-3-0t64"

INSTALL_PACKAGE_DEB_64="
0x07:cups
0x07:cups-bsd
0x07:libcups2
0x03:libcupsimage2
0x04:ghostscript
0x07:libgtk-3-0
0x02:libjpeg62
0x06:libgcrypt20
0x03:libjbig0
0x04:zlib1g
0x06:lsb-release"

REPLACE_PACKAGE_DEB_64="
cups,cupsys
libcups2,libcups2t64,libcupsys2
libcupsimage2,libcupsimage2t64
libjpeg62,libjpeg62-turbo
libgcrypt20,libbeecrypt7
libgtk-3-0,libgtk-3-0t64"

UPDATE_ONCE_FLAG=0

#-------------------------------------------------#
# install message
#-------------------------------------------------#
INST_COM_01_01="#----------------------------------------------------#"

INST_ERR_01_01="The current user is %s.
Change user to root, and then perform installation again."
INST_ERR_02_01="Could not install."
INST_MSG_01_01="This installer is recommended for the following distributions that are currently supported as of the release of this installer:
- Fedora/Ubuntu/CentOS/Debian/UOS/Kylin OS/NeoKylin OS

If this installer is run under distributions for which the support period has ended, the installation of additional system libraries may be necessary after driver installation is complete.

Note that an internet connection is required for installation.

Do you want to continue with installation? (y/n)"
INST_MSG_01_02="This installer is recommended for the following distributions that are currently supported as of the release of this installer:
- Fedora/Ubuntu/CentOS/Debian

If this installer is run under distributions for which the support period has ended, the installation of additional system libraries may be necessary after driver installation is complete.

Note that an internet connection is required for installation.

Do you want to continue with installation? (y/n)"
INST_MSG_02_01="Some system libraries could not be installed.
Refer to the Readme file for more information.
Do you want to continue with installation? (y/n)"
INST_MSG_03_01="Installation is complete.
Do you want to register the printer now? (y/n)"

LC_FILE_DIR="resources"
LC_FILE="no_localize"    
LANG_INFO=`echo $LANG | tr '[:upper:]' '[:lower:]'`
case "${LANG_INFO##*.}" in
	utf8 | utf-8)
		case "${LANG_INFO%%.*}" in
			ja_jp)
				LC_FILE="installer_ja_utf8.lc"
			;;
			fr_fr)
				LC_FILE="installer_fr_utf8.lc"
			;;
			it_it)
				LC_FILE="installer_it_utf8.lc"
			;;
			de_de)
				LC_FILE="installer_de_utf8.lc"
			;;
			es_es)
				LC_FILE="installer_es_utf8.lc"
			;;
			zh_cn)
				LC_FILE="installer_zh_CN_utf8.lc"
			;;
			ko_kr)
				LC_FILE="installer_ko_utf8.lc"
			;;
			zh_tw)
				LC_FILE="installer_zh_TW_utf8.lc"
			;;
			*)
				LC_FILE="installer_en_utf8.lc"
			;;
		esac
	;;
esac

#-------------------------------------------------#
# etc. define
#-------------------------------------------------#
DRIVER_FLAG=0
ERROR_CHECK=0
DRIVER_ERROR_CHECK=0
MACHINE_TYPE=""
PACKAGE_TYPE=""
DRIVER_PACKAGE=""
INSTALL_PACKAGE=""
INSTALL_CMD=""
INSTALL_OPT=""
INSTALL_PACKAGE_CMD=""

LIST_SPACE=" "

COLOR_K='\033[1;30m'
COLOR_R='\033[1;31m'
COLOR_G='\033[1;32m'
COLOR_Y='\033[1;33m'
COLOR_B=''
COLOR_M='\033[1;35m'
COLOR_C='\033[1;36m'
COLOR_OFF='\033[m'


#-------------------------------------------------#
# common function
#-------------------------------------------------#
C_output_log()
{
	echo -e -n $COLOR_B
	echo -e $INST_COM_01_01
	echo -e "# $1"
	echo -e $INST_COM_01_01
	echo -e -n $COLOR_OFF
}


C_output_message()
{
	echo -e -n $COLOR_B
	echo -e "$1"
	echo -e -n $COLOR_OFF
}


C_output_error_message()
{
	echo -e -n $COLOR_R
	echo -e "$1"
	echo -e -n $COLOR_OFF
}


C_check_distribution()
{	
	if [ $DRIVER_FLAG -eq 4 ]; then
		read -p "$INST_MSG_01_02" ans
	else 
		read -p "$INST_MSG_01_01" ans
	fi
	if [ "$ans" != "y" -a "$ans" != "Y" ]; then
		exit 1
	fi
	echo
}


C_set_driver_flag()
{
	find . -name "*$MACHINE_TYPE.$PACKAGE_TYPE" | grep -i -e carps2 -e ufr2lt > /dev/null 2>&1
	if [ "${?}" -eq 0 ]; then
		DRIVER_FLAG=$(($DRIVER_FLAG | 0x01))
	fi

	find . -name "*$MACHINE_TYPE.$PACKAGE_TYPE" | grep -i -e lipslx  -e ufr2- > /dev/null 2>&1
	if [ "${?}" -eq 0 ]; then
		DRIVER_FLAG=$(($DRIVER_FLAG | 0x02))
	fi

	find . -name "*$MACHINE_TYPE.$PACKAGE_TYPE" | grep -i -e lips4 > /dev/null 2>&1
	if [ "${?}" -eq 0 ]; then
		DRIVER_FLAG=$(($DRIVER_FLAG | 0x04))
	fi
	
}


C_check_driver_and_install_package()
{
	local lc_package_flag=`echo $1 | cut -d ':' -f1`

	if [ $(($lc_package_flag & $DRIVER_FLAG)) = $DRIVER_FLAG ]; then
		echo $1 | cut -d ':' -f2-
	fi
}
	

C_check_directory()
{
	echo "${0}" | grep '/' >/dev/null  2>&1
	if [ "${?}" -eq 0 ]; then
		shell_dir="${0%/*}"
		cd "${shell_dir}"
	fi
}


C_update()
{
	if [ $UPDATE_ONCE_FLAG -eq 0 ]; then
		case $PACKAGE_TYPE in
		'deb')
			C_output_log "$INSTALL_PACKAGE_CMD update"
			$INSTALL_PACKAGE_CMD update
			;;
		esac
		UPDATE_ONCE_FLAG=1
		echo
	fi
}


C_install_package()
{
	C_output_log "$INSTALL_PACKAGE_CMD install $1"

	$INSTALL_PACKAGE_CMD -y install $1

	echo
}


C_check_package_installed()
{
	local inst_pkg=$1

	if [ -d "/etc/yum.repos.d" ]; then
		echo $inst_pkg | grep '\.'  > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			rpm -qa --qf '%{NAME}.%{ARCH}\n' | grep -iE "^$inst_pkg$" > /dev/null 2>&1
		else
			rpm -qa --qf '%{NAME}\n' | grep -iE "^$inst_pkg$" > /dev/null 2>&1
		fi
	else
		echo $inst_pkg | grep ":" > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			dpkg-query -W -f='${Package}:${Architecture}\n' | grep -iE "^$inst_pkg$" > /dev/null 2>&1
		else
			dpkg-query -W -f='${Package}\n' | grep -iE "^$inst_pkg$" > /dev/null 2>&1
		fi
	fi

	return $?
}


C_install_package_check()
{
	C_output_log "Install Package Check"

	local inst_pkg=$1
	local replace_list=""
	local err_check=0

	for check_pkg in $REPLACE_PACKAGE
	do
		IFS_BACK=$IFS
		IFS=','
		array=($check_pkg)
		IFS=$IFS_BACK
		count=${#array[@]}
		if [ ${array[0]} = $inst_pkg ]; then
			for ((i=1;i<$count;i++))
			do
				replace_list=$replace_list$LIST_SPACE${array[$i]}
			done
			break
		fi
	done

	err_check=1
	for pkg in $inst_pkg $replace_list
	do
		C_check_package_installed $pkg
		if [ $? -eq 0 ]; then
			C_output_message " OK: $pkg"
			err_check=0
			break
		fi
	done

	if [ $err_check -eq 0 ]; then
		echo
		return 0
	fi

	C_update
	C_install_package $inst_pkg
	C_check_package_installed $inst_pkg

	if [ $? -eq 0 ]; then
		C_output_message " OK: $inst_pkg"
		echo
		return 0
	fi

	if [ "$replace_list" = "" ]; then
		C_output_error_message   " NG: $inst_pkg"
		echo
		return 1
	fi

	for pkg in $replace_list
	do
		C_output_error_message   " Replace: $inst_pkg -> $pkg"
		echo
		C_install_package_check $pkg
		if [ $? -eq 0 ]; then
			err_check=0
			break
		fi
	done

	if [ $err_check -ne 0 ]; then
		C_output_error_message   " NG: $inst_pkg"
		echo
	fi

	return $err_check
}


C_install_printer_driver()
{
	C_output_log "Install Printer Driver ($INSTALL_CMD $INSTALL_OPT)" 

	unset DRIVER_PACKAGE
	DRIVER_PACKAGE=`find . -name "*$MACHINE_TYPE.$PACKAGE_TYPE"`
	$INSTALL_CMD $INSTALL_OPT $DRIVER_PACKAGE
	if [ $? -ne 0 ]; then
		DRIVER_ERROR_CHECK=1
	fi

	echo
}

#-------------------------------------------------#
# start install.sh
#-------------------------------------------------#
main()
{
	install_package_list=""
	
	#---------------------
	# check directory 
	#---------------------
	C_check_directory

	#---------------------
	# localize
	#---------------------
	if [ -f ${LC_FILE_DIR}/${LC_FILE} ]; then
		source ${LC_FILE_DIR}/${LC_FILE}
	fi

	#---------------
	# check root
	#---------------
	if test `id -un` != "root"; then
		echo -e -n $COLOR_R
		printf "$INST_ERR_01_01" `id -un`
		echo -e -n $COLOR_OFF
		echo
		exit 1
	fi
	
	#------------------------
	# get distribution data
	#------------------------
	case `uname` in
	'SunOS')
		EXE_PATH='/opt/sfw/cups/sbin'
		;;
	'HP-UX')
		EXE_PATH='/usr/sbin:/usr/bin'
		;;
	'AIX')
		EXE_PATH='/usr/sbin:/usr/bin'
		;;
	'Linux')
		EXE_PATH='/usr/sbin:/usr/bin'
		;;
	esac
	
	export PATH=$EXE_PATH:$PATH
	
	if [ -d "/etc/yum.repos.d" ];
	then
		PACKAGE_TYPE="rpm"
		INSTALL_CMD="rpm"
		INSTALL_OPT="-Uvh --replacepkgs --replacefiles"
		if which yum > /dev/null 2>&1;
		then
			INSTALL_PACKAGE_CMD="yum"
		else
			INSTALL_PACKAGE_CMD="dnf"
		fi

		case `uname -m` in 	 
		'i386'|'i686') 	 
			MACHINE_TYPE="i386" 	 
			install_package_list=$INSTALL_PACKAGE_RPM_32
			REPLACE_PACKAGE=$REPLACE_PACKAGE_RPM_32
			;; 	 
		'x86_64') 	 
			MACHINE_TYPE="x86_64" 	 
			install_package_list=$INSTALL_PACKAGE_RPM_64
			REPLACE_PACKAGE=$REPLACE_PACKAGE_RPM_64
			;;
		'aarch64')
			MACHINE_TYPE="aarch64"
			install_package_list=$INSTALL_PACKAGE_RPM_64
			REPLACE_PACKAGE=$REPLACE_PACKAGE_RPM_64
			;;
		'mips64') 	 
			MACHINE_TYPE="mips64el"
			install_package_list=$INSTALL_PACKAGE_RPM_64
			REPLACE_PACKAGE=$REPLACE_PACKAGE_RPM_64
			;; 	 
		'loongarch64') 	 
			MACHINE_TYPE="loongarch64"
			install_package_list=$INSTALL_PACKAGE_RPM_64
			REPLACE_PACKAGE=$REPLACE_PACKAGE_RPM_64
			;;
		esac
	else
		PACKAGE_TYPE="deb"
		INSTALL_CMD="dpkg"
		INSTALL_OPT="-i -G --force-overwrite"
		INSTALL_PACKAGE_CMD="apt-get"
	
		case `uname -m` in 	 
		'i386'|'i686') 	 
			MACHINE_TYPE="i386" 	 
			install_package_list=$INSTALL_PACKAGE_DEB_32
			REPLACE_PACKAGE=$REPLACE_PACKAGE_DEB_32
			;; 	 
		'x86_64') 	 
			MACHINE_TYPE="amd64" 	 
			install_package_list=$INSTALL_PACKAGE_DEB_64
			REPLACE_PACKAGE=$REPLACE_PACKAGE_DEB_64
			;;
		'aarch64')
			MACHINE_TYPE="arm64"
			install_package_list=$INSTALL_PACKAGE_DEB_64
			REPLACE_PACKAGE=$REPLACE_PACKAGE_DEB_64
			;;
		'mips64')
			MACHINE_TYPE="mips64el"
			install_package_list=$INSTALL_PACKAGE_DEB_64
			REPLACE_PACKAGE=$REPLACE_PACKAGE_DEB_64
			;;
		'loongarch64')
			MACHINE_TYPE="loongarch64"
			install_package_list=$INSTALL_PACKAGE_DEB_64
			REPLACE_PACKAGE=$REPLACE_PACKAGE_DEB_64
			;;
		esac
	fi
	
	

	#---------------------
	# set driver flag
	#---------------------
	C_set_driver_flag
	
	#---------------------
	# check distribution
	#---------------------
	C_check_distribution
	
	#------------------------
	# install start
	#------------------------
	C_output_log "Install Start"
	C_output_message "Machine Type = $MACHINE_TYPE"
	C_output_message "Package Type = $PACKAGE_TYPE"
	
	DRIVER_PACKAGE=`find . -name "*$MACHINE_TYPE.$PACKAGE_TYPE" | sort 2> /dev/null`
	C_output_message "Package list = "
	
	for list in $DRIVER_PACKAGE
	do
		C_output_message "    $list"
	done
	echo
	
	#---
	for package in $install_package_list
	do
		INSTALL_PACKAGE=`C_check_driver_and_install_package $package`
		if [ "$INSTALL_PACKAGE" = "" ]; then
			continue;
		fi

		C_install_package_check $INSTALL_PACKAGE
		if [ $? -ne 0 ]; then
			ERROR_CHECK=1
		fi
	done
	#---

	#---
	if [ $ERROR_CHECK -eq 1 ]; then
		read -p "$INST_MSG_02_01" ans
		if [ "$ans" != "y" -a "$ans" != "Y" ]; then
			exit 1
		fi
		echo
	fi
	#---

	C_install_printer_driver
}

main $*

if [ $ERROR_CHECK -ne 0 -o $DRIVER_ERROR_CHECK -ne 0 ]
then
	C_output_error_message "$INST_ERR_02_01"
fi

exit 0

