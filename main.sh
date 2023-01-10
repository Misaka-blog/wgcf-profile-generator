#!/bin/sh

red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}

green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}

yellow(){
    echo -e "\033[33m\033[01m$1\033[0m"
}

rm -f wgcf-account.toml wgcf-profile.conf
echo | ./wgcf register
chmod +x wgcf-account.toml

clear
yellow "获取CloudFlare WARP账号密钥信息方法: "
green "电脑: 下载并安装CloudFlare WARP→设置→偏好设置→账户→复制密钥到脚本中"
green "手机: 下载并安装1.1.1.1 APP→菜单→账户→复制密钥到脚本中"
echo ""
yellow "重要：请确保手机或电脑的1.1.1.1 APP的账户状态为WARP+！"
read -rp "输入WARP账户许可证密钥 (26个字符):" warpkey
until [[ -z $warpkey || $warpkey =~ ^[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}$ ]]; do
  red "WARP账户许可证密钥格式输入错误，请重新输入！"
  read -rp "输入WARP账户许可证密钥 (26个字符): " warpkey
done
if [[ -n $warpkey ]]; then
  sed -i "s/license_key.*/license_key = \"$warpkey\"/g" wgcf-account.toml
  read -rp "请输入自定义设备名，如未输入则使用默认随机设备名: " devicename
  green "注册WARP+账户中, 如下方显示:400 Bad Request, 则使用WARP免费版账户"
  if [[ -n $devicename ]]; then
    wgcf update --name $(echo $devicename | sed s/[[:space:]]/_/g) > /etc/wireguard/info.log 2>&1
  else
    wgcf update
  fi
else
  red "未输入WARP账户许可证密钥，将使用WARP免费账户"
fi

./wgcf generate

clear
green "Wgcf的WireGuard配置文件已生成成功！"
yellow "下面是配置文件内容："
cat wgcf-profile.conf
yellow "下面是配置文件分享二维码："
qrencode -t ansiutf8 < wgcf-profile.conf