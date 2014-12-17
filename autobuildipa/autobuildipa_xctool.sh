#!/bin/bash

#--------------------------------------------
# 功能：使用xctools自动打包
# 使用说明：
#	  ./autobuildipa_xctool.sh prjRootDic1:Scheme1#prjRootDic2:Scheme2 141029
# 作者：xujunwen
# E-mail:xujunwen426@gmail.com
# 创建日期：2014-10-29 13:58:00
#--------------------------------------------

#build前清除之前的目录
clean_app_build_dic=true
#是否只通过*.app来生成ipa
only_packge_ipa=false

##############配置工程目录和scheme名称,scheme名称要和xcodeproj一致,用空格隔开#############
#要打包的项目
project_config=$1
#新版本
new_version_code=$2
#去空格
new_version_code=$(echo $new_version_code)

if  [[ ! $new_version_code =~ ^[0-9]+$ ]] || [ ${#new_version_code} -ne 6 ]  ; then
	echo "错误 -> 版本号必须为6位的数字!"
	exit 2
fi

##############解析参数##################
str_dic=""
str_scheme=""
for item in $(echo $project_config | tr "#" "\n")
do
  	count=1
	for config in $(echo $item | tr ":" "\n")
	do
		# echo $count
		if [ $count = 1 ];then
			str_dic=$str_dic" "$config
		fi
		if [ $count = 2 ] ;then
			str_scheme=$str_scheme" "$config
		fi
		let "count++"
	done
done

#echo $str_dic #以空格分开的目录数组
#echo $str_scheme #以空格分开的Scheme数组

dicArray=($str_dic)
schemeArray=($str_scheme)

# exit 0

#############安装brew 和xctool#############
if which brew 2>/dev/null; then
  echo "brew已经安装!"
else
  echo "brew未安装,开始安装···"
  curl -LsSf http://github.com/mxcl/homebrew/tarball/master | sudo tar xvz -C/usr/local --strip 1
fi

if which xctool>/dev/null; then
  echo "xctool已经安装"
else
  echo "xctool未安装,开始安装···"
  sudo brew update
  sudo brew install xctool 
fi

# xctool -scheme sanguopp -reporter plain:log.txt  archive  -archivePath ./xctoolBuild 

#############批量打包应用#############
dic_count=${#dicArray[@]}
scheme_count=${#schemeArray[@]}
if [ dic_count!=0 ] && [ $dic_count != $scheme_count ] ; then
	echo "错误 -> 配置工程目录和scheme名称数量不等!"
	exit 2
fi

# 设置编译和输出路径
build_path=$(pwd) # 当前目录的全路径
ios_build_path=$build_path/releaseIpas
ios_ipa_build_path=$build_path/releaseIpas/ipabuild

# 如果不存在输出目录创建，build前清除之前的目录
if [ $clean_app_build_dic  ] && [ -d $ios_build_path ]; then
	rm -rf $ios_build_path
fi

if [ ! -d $ios_ipa_build_path ] ; then
	mkdir -p $ios_ipa_build_path
fi

function replace_info_list(){
	app_infoplist_path=$1
	schemeName=$2
	#取版本号
	bundleShortVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleShortVersionString" ${app_infoplist_path})
	#取build值
	bundleVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleVersion" ${app_infoplist_path})
	hasPoint=false
	temp_version_code=$new_version_code
	if [[ $bundleShortVersion =~ "." ]];then
	    hasPoint=true
	else
		hasPoint=false
	fi
	if [ "$hasPoint" == true ]; then
		temp_version_code=$(echo  $temp_version_code|awk  'BEGIN{FS=""}{print $1$2"."$3$4"."$5$6}')
	fi
	echo $schemeName old CFBundleShortVersionString,CFBundleVersion is: $bundleShortVersion , $bundleVersion
	echo $schemeName ipa new_version_code is: $temp_version_code 

    /usr/libexec/Plistbuddy -c "Set CFBundleVersion $temp_version_code" "${app_infoplist_path}"
    /usr/libexec/Plistbuddy -c "Set CFBundleShortVersionString $temp_version_code" "${app_infoplist_path}"
}

function build_release(){

	schemeName=$2
	project_path=$1/$schemeName".xcodeproj"

	#app文件中Info.plist文件路径
	app_infoplist_path=$1/$schemeName/$schemeName"-Info.plist"

	#ipa名称
	ipa_name=$schemeName"_"$(date +"%Y%m%d")

	#scheme路径
	target_ios_build_path=$ios_build_path/$schemeName

	#生成.app的路径
	target_ios_app_path=$target_ios_build_path".xcarchive/Products/Applications/*.app"

	#发布的ipa路径
	ipa_publish_path=$ios_ipa_build_path/${ipa_name}.ipa

	#替换Info.plist中的版本号
	replace_info_list $app_infoplist_path $schemeName
	
	if [  "$only_packge_ipa" == false ] ; then
		echo  xctool build begin...
		xctool -project $project_path -scheme $schemeName clean
		xctool -project $project_path -scheme $schemeName archive  -archivePath $target_ios_build_path 
	fi
	
	if [ -d $target_ios_app_path ] ; then
		xcrun -sdk iphoneos PackageApplication -v $target_ios_app_path -o  $ipa_publish_path
	fi
}

# 批量编译打包
for (( i=0;i<$dic_count;i=i+1))
do
	dic=${dicArray[$i]} #取目录
	scheme=${schemeArray[$i]} #取Scheme
	p_path=$dic
	if [ -d $p_path ] ; then
		build_release $p_path $scheme
	else
		echo "错误 -> 工程不存在:" $p_path
	fi
done
