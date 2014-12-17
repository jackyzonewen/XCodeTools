#!/bin/bash
SHELL_DIR=$(cd `dirname $0`; pwd)
 
	# 1.修改配置文件（buildsetting.plist）配置内容，具体修改如下
	# 	1）sdk*
	# 		当前你可以编译sdk版本（使用xcodebuild -showsdks）
	# 	2）arch
	# 		cpu架构（armv7）
	# 	3）target*
	# 		你工程的target是什么名字就填什么名字
	# 	4）configuration
	# 		目前使用Release, 可以为Debug,AdHoc,Release,Distribution
	# 	5）CODE_SIGN_IDENTITY*
	# 		你的工程对应的签名id，（xcode点击工程文件，再点击target，选择build setting，单击Code Signing Identity的键值，选择Other，选择出现的字符串）
	# 	6）PROVISIONING_PROFILE*
	# 		你的工程授权文件的id值，（xcode点击工程文件，再点击target，选择build setting，单击Provisioning Profile的键值，选择Other，选择出现的字符串）
	# 	7）GCC_PREPROCESSOR_DEFINITIONS
	# 		如果有需要预处理的宏定义，需要在这里指定

	# 2.修改本文件的SOURCE_CODE_FOLDER,xcodepro所在目录

	# 3.修改本文件的XCODE_BUILD_FOLDER，编译临时路径

	# 4.修改本文件的STORE_IPA_PATH存储路径

#代码路径（xcodeproj所在的目录）
SOURCE_CODE_FOLDER="/Users/jackyzonewen/Repository/SVN/NewManager/IOS/zhanggui"

#xcode编译临时文件的存储路径
XCODE_BUILD_FOLDER="/Users/jackyzonewen/Desktop/enterprise/xcodebuildcache"

#生成ipa的位置
APP_BUILD_TIME=$(date +%Y%m%d%H%M) #编译时间
STORE_IPA_PATH="/Users/jackyzonewen/Desktop/enterprise/zhanggui_$APP_BUILD_TIME/zhanggui_adhoc.ipa"

#自动编译并且打包签名
COMPILE_IPA_PATH="$SHELL_DIR/zhanggui-buildsetting.plist" #编译配置文件
sh $SHELL_DIR/autobuildipa.sh $SOURCE_CODE_FOLDER $STORE_IPA_PATH $COMPILE_IPA_PATH $XCODE_BUILD_FOLDER

#分目录
IPA_OUT_FOLDER="$(dirname "$STORE_IPA_PATH")"

DSYM_OUT_FOLDER="$(dirname "$STORE_IPA_PATH")_dSYM"

if [ ! -d $DSYM_OUT_FOLDER ]; then
	mkdir $DSYM_OUT_FOLDER
fi

mv $IPA_OUT_FOLDER/*.dSYM $DSYM_OUT_FOLDER

echo "自动打包服务执行结束！！"



