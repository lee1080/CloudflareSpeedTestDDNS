#!/bin/bash
#		版本：V2.2
#         用于CloudflareST调用，更新hosts和更新dnspod DNS。

#set -euo pipefail
ipv4Regex="((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])";

networks=('电信' '联通' '移动' '铁通' '广电' '教育网' '境内' '境外')
RECORD_LINE=${networks[LINE-1]}

if [ "$IP_TO_DNSPOD" = "1" ]; then
  # 发送请求并获取响应
  response=$(curl -sSf -X POST "https://dnsapi.cn/Domain.List" \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -d "login_token=${dnspod_token}&format=json&offset=0&length=20")

  # 解析json响应并检查状态码
  if [[ $(echo ${response} | jq -r '.status.code') == 1 ]]; then
    echo "dnspod Token有效"
  else
    echo "dnspod Token无效"
    echo "登陆错误,检查dnspod Token信息填写是否正确！" > $informlog
    source $cf_push;
    exit 1;
  fi
  echo "dnspod Token验证成功";
else
  echo "未配置dnspod Token"
fi

#获取域名填写数量
num=${#hostname[*]};

#判断优选ip数量是否大于域名数，小于则让优选数与域名数相同
if [ "$CFST_DN" -le $num ] ; then
  CFST_DN=$num;
fi
CFST_P=$CFST_DN;

#判断工作模式
if [ "$IP_ADDR" = "ipv6" ] ; then
  if [ ! -f "./cf_ddns/ipv6.txt" ]; then
    echo "当前工作模式为ipv6，但该目录下没有【ipv6.txt】，请配置【ipv6.txt】。下载地址：https://github.com/XIU2/CloudflareSpeedTest/releases";
    exit 2;
  else
    echo "当前工作模式为ipv6";
  fi
else
  echo "当前工作模式为ipv4";
fi

#读取配置文件中的客户端
case $clien in
  "6") CLIEN=bypass;;
  "5") CLIEN=openclash;;
  "4") CLIEN=clash;;
  "3") CLIEN=shadowsocksr;;
  "2") CLIEN=paswall2;;
  *) CLIEN=passwall;;
esac

#判断是否停止科学上网服务
if [ "$pause" = "false" ] ; then
  echo "按要求未停止科学上网服务";
else
  /etc/init.d/$CLIEN stop;
  echo "已停止$CLIEN";
fi

#判断是否配置测速地址 
if [[ "$CFST_URL" == http* ]] ; then
  CFST_URL_R="-url $CFST_URL";
else
  CFST_URL_R="";
fi

if [ "$IP_PR_IP" = "true" ] ; then
  curl -sSf -o ./cf_ddns/pr_ip.txt https://cf.vbar.fun/pr_ip.txt
  $CloudflareST $CFST_URL_R -t $CFST_T -n $CFST_N -dn $CFST_DN -tl $CFST_TL  -sl $CFST_SL -p $CFST_P -f ./cf_ddns/pr_ip.txt -o ./cf_ddns/result.csv
  rm ./cf_ddns/pr_ip.txt
elif [ "$IP_ADDR" = "ipv6" ] ; then
  #开始优选IPv6
  $CloudflareST $CFST_URL_R -t $CFST_T -n $CFST_N -dn $CFST_DN -tl $CFST_TL -tll $CFST_TLL -sl $CFST_SL -p $CFST_P -f ./cf_ddns/ipv6.txt -o ./cf_ddns/result.csv
else
  #开始优选IPv4
  $CloudflareST $CFST_URL_R -t $CFST_T -n $CFST_N -dn $CFST_DN -tl $CFST_TL -tll $CFST_TLL -sl $CFST_SL -p $CFST_P -f ./cf_ddns/ip.txt -o ./cf_ddns/result.csv
fi
echo "测速完毕";

#判断是否重启科学服务
if [ "$pause" = "false" ] ; then
  echo "按要求未重启科学上网服务";
  sleep 3s;
else
  /etc/init.d/$CLIEN restart;
  echo "已重启$CLIEN";
  echo "等待${sleepTime}秒后开始更新DNS！"
  sleep ${sleepTime}s;
fi

# 开始循环
echo "正在更新域名，请稍后...";
x=0;
while [[ ${x} -lt $num ]]; do
  CDNhostname=${hostname[$x]};
  
  # 获取优选后的ip地址 
  ipAddr=$(sed -n "$((x + 2)),1p" ./cf_ddns/result.csv | awk -F, '{print $1}');
  
  if [ "$IP_TO_HOSTS" = 1 ]; then
    echo $ipAddr $CDNhostname >> ./cf_ddns/hosts_new
    # else
    # echo "未配置hosts"
  fi
  
  if [ "$IP_TO_DNSPOD" = 1 ]; then
    echo "开始更新第$((x + 1))个---$ipAddr";
    
    # 开始DDNS
    if [[ $ipAddr =~ $ipv4Regex ]]; then
      recordType="A";
    else
      recordType="AAAA";
    fi

    # split domain and subdomain by .
    IFS='.' read -ra arr <<< "$CDNhostname"
    # count the number of elements in the array
    len=${#arr[@]}

    # if there is only 1 element, it means the domain is the full domain and subdomain should be "@"
    if [ $len -eq 1 ]; then
      domain="$CDNhostname"
      sub_domain="@"
    elif [ $len -eq 2 ]; then
      domain="$CDNhostname"
      sub_domain="@"
    else
      # check if the domain ends with "eu.org"
      if [ "${arr[$len-2]}.${arr[$len-1]}" = "eu.org" ]; then
        # get the domain by joining the last three elements with .
        domain="${arr[$len-3]}.${arr[$len-2]}.${arr[$len-1]}"
        # get the subdomain by joining all elements except the last three with .
        if [ $len -eq 3 ]; then
          sub_domain="@"
        else
          sub_domain="$(IFS='.'; echo "${arr[*]:0:$len-3}")"
        fi
      else
        # get the domain by joining the last two elements with .
        domain="${arr[$len-2]}.${arr[$len-1]}"
        # get the subdomain by joining all elements except the last two with .
        sub_domain="$(IFS='.'; echo "${arr[*]:0:$len-2}")"
      fi
    fi
    
    DOMAIN_NAME=$domain
    SUBDOMAIN=$sub_domain
    
    ## DNS新建与更新
    # call DNSPod API to get the domain ID and record ID
    RESPONSE=$(curl -sX POST https://dnsapi.cn/Record.List -d "login_token=$dnspod_token&format=json&domain=$DOMAIN_NAME&sub_domain=$SUBDOMAIN")

    # check if the domain exists
    STATUS=$(echo "$RESPONSE" | jq -r '.status.code')
    if [ "$STATUS" == "1" ]; then
      # extract domain ID and record ID from the API response
      RECORD_ID=$(echo "$RESPONSE" | jq -r '.records[0].id')
      # update DNS record with the current IP address
      RESPONSE=$(curl -sX POST https://dnsapi.cn/Record.Modify -d "login_token=$dnspod_token&format=json&domain=$DOMAIN_NAME&record_id=$RECORD_ID&sub_domain=$SUBDOMAIN&record_line=$RECORD_LINE&record_type=$recordType" -d "value=$ipAddr")

      # check if the update was successful
      STATUS=$(echo "$RESPONSE" | jq -r '.status.code')
      if [ "$STATUS" == "1" ]; then
        echo "$CDNhostname更新成功"
      else
        echo "$CDNhostname更新失败"
      fi
    else
      # add DNS record for the domain
      RESPONSE=$(curl -sX POST https://dnsapi.cn/Record.Create -d "login_token=$dnspod_token&format=json&domain=$DOMAIN_NAME&sub_domain=$SUBDOMAIN&record_line=$RECORD_LINE&record_type=$recordType" -d "value=$ipAddr")

      # check if the creation was successful
      STATUS=$(echo "$RESPONSE" | jq -r '.status.code')
      if [ "$STATUS" == "1" ]; then
        echo "$CDNhostname添加成功"
      else
        echo "$CDNhostname添加失败"
      fi
    fi

  fi

  ((x++))
    sleep 3s;
done > $informlog

if [ "$IP_TO_HOSTS" = 1 ]; then
  if [ ! -f "/etc/hosts.old_cfstddns_bak" ]; then
    cp /etc/hosts /etc/hosts.old_cfstddns_bak
    cat ./cf_ddns/hosts_new >> /etc/hosts
  else
    rm /etc/hosts
    cp /etc/hosts.old_cfstddns_bak /etc/hosts
    cat ./cf_ddns/hosts_new >> /etc/hosts
    echo "hosts已更新"
    echo "hosts已更新" >> $informlog
    rm ./cf_ddns/hosts_new
  fi
fi
#判断是否重启科学服务
if [ "$pause" = "false" ] ; then
  echo "按要求未重启科学上网服务";
  sleep 3s;
else
  /etc/init.d/$CLIEN restart;
  echo "已重启$CLIEN";
  echo "等待${sleepTime}秒后开始更新DNS！"
  sleep ${sleepTime}s;
fi