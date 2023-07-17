#!/bin/bash
#         用于CloudflareSpeedTestDDNS运行环境检测和必要软件初始化安装。

#github下在CloudflareSpeedTest使用ghproxy代理
PROXY=https://ghproxy.com/

flag_file=".ran_before"
CloudflareST="./cf_ddns/CloudflareST"
informlog="./cf_ddns/informlog"
cf_push="./cf_ddns/cf_push.sh"

# 初始化推送
if [ -e ${informlog} ]; then
  rm ${informlog}
fi

# 检测是否配置DDNS或更新HOSTS任意一个
if [[ -z ${dnspod_token} ]]; then
  IP_TO_DNSPOD=0
else
  IP_TO_DNSPOD=1
fi

if [[ -z ${api_key} ]]; then
  IP_TO_CF=0
else
  IP_TO_CF=1
fi

if [ "$IP_TO_HOSTS" = "true" ]; then
  IP_TO_HOSTS=1
else
  IP_TO_HOSTS=0
fi

if [ $IP_TO_DNSPOD -eq 1 ] || [ $IP_TO_CF -eq 1 ] || [ $IP_TO_HOSTS -eq 1 ]
then
  echo "配置获取成功！"
else
  echo "HOSTS和cf_ddns均未配置！！！"
  echo "HOSTS和cf_ddns均未配置！！！" > $informlog
  source $cf_push;
  exit 1;
fi

# 如果是第一次运行的话，将进行初始化
if [ ! -e "$flag_file" ]; then
	# 初始化包列表
	packages=""

	# 检查bash是否安装
	if ! command -v bash &> /dev/null; then
	    echo "bash not found. Adding to the list of required packages."
	    packages="$packages bash"
	else
	    echo "bash is already installed."
	fi

	# 检查jq是否安装
	if ! command -v jq &> /dev/null; then
	    echo "jq not found. Adding to the list of required packages."
	    packages="$packages jq"
	else
	    echo "jq is already installed."
	fi
	
	# 检查wget是否安装
	if ! command -v wget &> /dev/null; then
	    echo "wget not found. Adding to the list of required packages."
	    packages="$packages wget"
	else
	    echo "wget is already installed."
	fi
	
	# 检查curl是否安装
	if ! command -v curl &> /dev/null; then
	    echo "curl not found. Adding to the list of required packages."
	    packages="$packages curl"
	else
	    echo "curl is already installed."
	fi
	
	# 检查tar是否安装
	if ! command -v tar &> /dev/null; then
	    echo "tar not found. Adding to the list of required packages."
	    packages="$packages tar"
	else
	    #由于有的设备有tar但版本过低还是无法正常解压，所以tar强制更新
	    packages="$packages tar"
	    echo "tar is already installed."
	fi
	
	# 检查sed是否安装
	if ! command -v sed &> /dev/null; then
	    echo "sed not found. Adding to the list of required packages."
	    packages="$packages sed"
	else
	    echo "sed is already installed."
	fi
	
	# 检查awk是否安装
	if ! command -v awk &> /dev/null; then
	    echo "awk not found. Adding to the list of required packages."
	    packages="$packages gawk"
	else
	    echo "awk is already installed."
	fi
	
	# 检查tr是否安装
	if ! command -v tr &> /dev/null; then
	    echo "tr not found. Adding to the list of required packages."
	    packages="$packages coreutils"
	else
	    echo "tr is already installed."
	fi

	# 判断系统进行安装
	if [ -n "$packages" ]; then
	    echo "The following packages are required: $packages"
	    if grep -qi "alpine" /etc/os-release; then
	        echo "Installing packages using apk..."
	        apk update
	        apk add $packages
	    elif grep -qi "openwrt" /etc/os-release; then
	        echo "Installing packages using opkg..."
	        opkg update
	        opkg install $packages
	        #openwrt没有安装timeout
	        opkg install coreutils-timeout
	    elif grep -qi "ubuntu\|debian" /etc/os-release; then
	        echo "Installing packages using apt-get..."
	        sudo apt-get update
	        sudo apt-get install $packages -y
	    elif grep -qi "centos\|red hat\|fedora" /etc/os-release; then
	        echo "Installing packages using yum..."
	        sudo yum install $packages -y
	    else
	        echo "未能检测出你的系统：$(uname)，请自行安装$packages这些软件。"
	        echo "未能检测出你的系统：$(uname)，请自行安装$packages这些软件。" > $informlog
	        source $cf_push;
	        exit 1
	    fi
	fi
# 检测CloudflareST是否安装
LATEST_URL=https://api.github.com/repos/XIU2/CloudflareSpeedTest/releases/latest

latest_version() {
  curl --silent $LATEST_URL | grep "tag_name" | cut -d '"' -f 4
}

VERSION=$(latest_version)

if [ -e ./cf_ddns/tmp/ ]; then
	rm -rf ./cf_ddns/tmp/
fi
if [ ! -f ${CloudflareST} ]; then
	get_arch=`uname -m`
	if [[ $get_arch =~ "x86_64" ]];then
	    echo "this is x86_64"
	    URL="https://github.com/XIU2/CloudflareSpeedTest/releases/download/$VERSION/CloudflareST_linux_amd64.tar.gz"
	    wget -P ./cf_ddns/tmp/ ${PROXY}$URL
	    tar -zxf ./cf_ddns/tmp/CloudflareST_linux_*.tar.gz -C ./cf_ddns/tmp/
	    mv ./cf_ddns/tmp/CloudflareST ./cf_ddns/tmp/ip.txt ./cf_ddns/tmp/ipv6.txt ./cf_ddns/
	    rm -rf ./cf_ddns/tmp/
	elif [[ $get_arch =~ "aarch64" ]];then
	    echo "this is arm64"
	    URL="https://github.com/XIU2/CloudflareSpeedTest/releases/download/$VERSION/CloudflareST_linux_arm64.tar.gz"
	    wget -P ./cf_ddns/tmp/ ${PROXY}$URL
	    tar -zxf ./cf_ddns/tmp/CloudflareST_linux_*.tar.gz -C ./cf_ddns/tmp/
	    mv ./cf_ddns/tmp/CloudflareST ./cf_ddns/tmp/ip.txt ./cf_ddns/tmp/ipv6.txt ./cf_ddns/
	    rm -rf ./cf_ddns/tmp/
	elif [[ $get_arch =~ "mips64" ]];then
	    echo "this is mips64"
	    URL="https://github.com/XIU2/CloudflareSpeedTest/releases/download/$VERSION/CloudflareST_linux_mips64.tar.gz"
	    wget -P ./cf_ddns/tmp/ ${PROXY}$URL
	    tar -zxf ./cf_ddns/tmp/CloudflareST_linux_*.tar.gz -C ./cf_ddns/tmp/
	    mv ./cf_ddns/tmp/CloudflareST ./cf_ddns/tmp/ip.txt ./cf_ddns/tmp/ipv6.txt ./cf_ddns/
	    rm -rf ./cf_ddns/tmp/
	else
	    echo "找不到匹配的CloudflareST程序，请自行下载'https://github.com/XIU2/CloudflareSpeedTest'，并解压至'./cf_ddns/'文件夹中。"
	    echo "找不到匹配的CloudflareST程序，请自行下载'https://github.com/XIU2/CloudflareSpeedTest'，并解压至'./cf_ddns/'文件夹中。" > $informlog
	    source $cf_push;
	    exit 1
	fi
fi
# 检测CloudflareST权限
if [[ ! -x ${CloudflareST} ]]; then
#   echo "${CloudflareST} 文件不可执行"
   chmod +x $CloudflareST
fi
touch "$flag_file"
echo "初始化完成！"
fi
