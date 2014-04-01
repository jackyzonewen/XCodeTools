#! /bin/bash
mv ~/Library/Developer/Xcode/UserData/CodeSnippets ~/Library/Developer/Xcode/UserData/CodeSnippets.backup

# rm ~/Library/Developer/Xcode/UserData/CodeSnippets
# ~/Library/Developer/Xcode/UserData/CodeSnippets 软链接指向当前目录下的CodeSnippets
SRC_HOME=`pwd`
ln -s ${SRC_HOME}/CodeSnippets ~/Library/Developer/Xcode/UserData/CodeSnippets
echo "setup done"

