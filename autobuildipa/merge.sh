#!/bin/bash
#
# 介绍：
# 这个脚本全部自动化编译各指令集静态库后合并。现在支持指令集有armv7 armv7s arm64 i386 x86_64
#  
# 使用：
#  首先cd 到xcode工程目录 然后运行 "sh ./build.sh"  PS:xcode不能含有xcodebuild的Runscript切记！
# 
# 验证:
#  cd 到静态库目录  然后 "lipo -info 静态库名称.a "
# 
# TODO :
# 1.完成宏定义，解决多次修改工程名字的问题
# 2.增加SVN、GIT版本号
# 3.增加Buildnotes
# 4.完成规范化命名
#

#工程的名字 
MY_PROJECT_NAME="ProjectName.xcodeproj"
#编译target的名字
MY_TARGET_NAME="ProjectName"
#LIB名字
MY_STATIC_LIB="lib${PROJECT_NAME}.a"
#编译路径
# 编译静态库名称路径
LIB_DIR = 'tmp/'
#合并静态库文件路径
LIB_FINAL_PATH= "${LIB_DIR}/FinalLib"

#如果目标文件不存在则创建
if [ ! -d "${LIB_DIR}" ]; then
  mkdir -p "${LIB_DIR}"
fi 
if [ ! -d "${LIB_FINAL_NAME}" ]; then
  mkdir -p "${LIB_FINAL_NAME}"
fi

# armv7 armv7s

MY_ARMV7_BUILD_PATH='temp/armv7'
MY_CURRENT_BUILD_PATH="${MY_ARMV7_BUILD_PATH}"

xcodebuild -project "${MY_PROJECT_NAME}" -target "${MY_TARGET_NAME}" -configuration 'Release'  -sdk 'iphoneos7.0' CONFIGURATION_BUILD_DIR="${MY_CURRENT_BUILD_PATH}" ARCHS='armv7 armv7s'  VALID_ARCHS='armv7 armv7s' IPHONEOS_DEPLOYMENT_TARGET='5.0' clean build

MY_ARMV7S_BUILD_PATH='temp/armv7S'
MY_CURRENT_BUILD_PATH="${MY_ARMV7S_BUILD_PATH}"

xcodebuild -project "${MY_PROJECT_NAME}" -target "${MY_TARGET_NAME}" -configuration 'Release'  -sdk 'iphoneos7.0' CONFIGURATION_BUILD_DIR="${MY_CURRENT_BUILD_PATH}" ARCHS='armv7s'  VALID_ARCHS='armv7s' IPHONEOS_DEPLOYMENT_TARGET='5.0' clean build

# arm64  代码未修改所以报错

MY_ARM64_BUILD_PATH='temp/arm64'
MY_CURRENT_BUILD_PATH="${MY_ARM64_BUILD_PATH}"

xcodebuild -project "${MY_PROJECT_NAME}" -target "${MY_TARGET_NAME}" -configuration 'Release' -sdk 'iphoneos7.0' CONFIGURATION_BUILD_DIR="${MY_CURRENT_BUILD_PATH}" ARCHS='arm64' IPHONEOS_DEPLOYMENT_TARGET='7.0'  clean build
 
# i386
MY_I386_BUILD_PATH='temp/i386'
MY_CURRENT_BUILD_PATH="${MY_I386_BUILD_PATH}"

xcodebuild -project "${MY_PROJECT_NAME}" -target "${MY_TARGET_NAME}" -configuration 'Release' -sdk 'iphonesimulator7.0' CONFIGURATION_BUILD_DIR="${MY_CURRENT_BUILD_PATH}" ARCHS='i386' VALID_ARCHS='i386' IPHONEOS_DEPLOYMENT_TARGET='5.0' clean build

# x86_64 代码未兼容所以报错

MY_X86_64_BUILD_PATH='temp/x86_64'
MY_CURRENT_BUILD_PATH="${MY_X86_64_BUILD_PATH}"

xcodebuild -project "${MY_PROJECT_NAME}" -target "${MY_TARGET_NAME}" -configuration 'Release' -sdk 'iphonesimulator7.0' CONFIGURATION_BUILD_DIR="${MY_CURRENT_BUILD_PATH}" ARCHS='x86_64' VALID_ARCHS='x86_64' IPHONEOS_DEPLOYMENT_TARGET='7.0' clean build


# #####################
# 
# # # 需要重新设置编译target的名字，
# 
# #####################
# TARGET 名字
MY_TARGET_NAME="AudioService"
#LIB名字
MY_STATIC_LIB="lib${MY_TARGET_NAME}.a"

#最终静态库路径
MY_FINAL_BUILD_PATH='lib/'
#最终静态库名字
MY_FINAL_STATIC_LIB="AudioService.a"
if [ ! -d "${MY_FINAL_BUILD_PATH}" ]; then
  mkdir -p "${MY_FINAL_BUILD_PATH}"
fi

# 合并不同版本的编译库 
lipo -create "${MY_ARMV7_BUILD_PATH}/${MY_STATIC_LIB}" "${MY_ARMV7S_BUILD_PATH}/${MY_STATIC_LIB}" "${MY_ARM64_BUILD_PATH}/${MY_STATIC_LIB}" "${MY_I386_BUILD_PATH}/${MY_STATIC_LIB}" "${MY_X86_64_BUILD_PATH}/${MY_STATIC_LIB}" -output "${MY_FINAL_BUILD_PATH}${MY_FINAL_STATIC_LIB}"

# lipo -create "${MY_ARM_BUILD_PATH}/${MY_STATIC_LIB}" "${MY_I386_BUILD_PATH}/${MY_STATIC_LIB}" -output "${MY_FINAL_BUILD_PATH}${MY_FINAL_STATIC_LIB}"
      
   
# rm -rf 'temp'
# rm -rf 'build'

open "${MY_FINAL_BUILD_PATH}"