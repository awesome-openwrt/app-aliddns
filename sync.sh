#!/usr/bin/env bash

# if error occured, then exit
set -e

# path
project_root_path=`pwd`
tmp_path="$project_root_path/.tmp"

if [ ! -d $tmp_path ]; then
    mkdir -p $tmp_path
fi

# git 同步 kenzok8/openwrt-packages 源码
if [ ! -d $tmp_path/kenzok8_packages ]; then
    mkdir -p $tmp_path/kenzok8_packages
    cd $tmp_path/kenzok8_packages
    git init
    git remote add origin https://github.com/kenzok8/openwrt-packages.git
    git config core.sparsecheckout true
fi
cd $tmp_path/kenzok8_packages
if [ ! -e .git/info/sparse-checkout ]; then
    touch .git/info/sparse-checkout
fi
if [ `grep -c "luci-app-aliddns" .git/info/sparse-checkout` -eq 0 ]; then
    echo "luci-app-aliddns" >> .git/info/sparse-checkout
fi
git pull --depth 1 origin master

############################################################################################

# luci-app-aliddns 同步更新
if [ -d $project_root_path/luci-app-aliddns ]; then
    rm -rf $project_root_path/luci-app-aliddns
fi
cp -R $tmp_path/kenzok8_packages/luci-app-aliddns $project_root_path/

# 提交
cd $tmp_path/kenzok8_packages
latest_commit_id=`git rev-parse HEAD`
latest_commit_msg=`git log --pretty=format:"%s" $current_git_branch_latest_id -1`
echo $latest_commit_id
echo $latest_commit_msg

cd $project_root_path
git add -A && git commit -m "$latest_commit_msg" && git push origin master
