#!/bin/bash
#		版本：20231004
#         用于CloudflareST调用，更新hosts和更新cloudflare DNS。

ipv4Regex="((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])";

#获取空间id
zone_id=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$(echo ${hostname[0]} | cut -d "." -f 2-)" -H "X-Auth-Email: $x_email" -H "X-Auth-Key: $api_key" -H "Content-Type: application/json" | jq -r '.result[0].id' )

if [ "$IP_TO_CF" = "1" ]; then
  # 验证cf账号信息是否正确
  res=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${zone_id}" -H "X-Auth-Email:$x_email" -H "X-Auth-Key:$api_key" -H "Content-Type:application/json");
  resSuccess=$(echo "$res" | jq -r ".success");
  if [[ $resSuccess != "true" ]]; then
    echo "登陆错误，检查cloudflare账号信息填写是否正确!"
    echo "登陆错误，检查cloudflare账号信息填写是否正确!" > $informlog
    source $cf_push;
    exit 1;
  fi
  echo "Cloudflare账号验证成功";
else
  echo "未配置Cloudflare账号"
fi

# 获取域名填写数量
num=${#hostname[*]};

# 判断优选ip数量是否大于域名数，小于则让优选数与域名数相同
if [ "$CFST_DN" -le $num ] ; then
  CFST_DN=$num;
fi
CFST_P=$CFST_DN;

# 判断工作模式
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
  "2") CLIEN=passwall2;;
  *) CLIEN=passwall;;
esac

# 判断是否停止科学上网服务
if [ "$pause" = "false" ] ; then
  echo "按要求未停止科学上网服务";
else
  /etc/init.d/$CLIEN stop;
  echo "已停止$CLIEN";
fi

#判断是否配置测速地址
if [[ "$CFST_URL" == http* ]] ; then
  CFST_URL_R="-url $CFST_URL -tp $CFST_TP ";
else
  CFST_URL_R="";
fi

# 检查 cfcolo 变量是否为空
if [[ -n "$cfcolo" ]]; then
  cfcolo="-cfcolo $cfcolo"
fi

# 检查 httping_code 变量是否为空
if [[ -n "$httping_code" ]]; then
  httping_code="-httping-code $httping_code"
fi

# 检查 CFST_STM 变量是否为空
if [[ -n "$CFST_STM" ]]; then
  CFST_STM="-httping $httping_code $cfcolo"
fi

# 检查是否配置反代IP
if [ "$IP_PR_IP" = "1" ] ; then
  if [[ $(cat ./cf_ddns/.pr_ip_timestamp | jq -r ".pr1_expires") -le $(date -d "$(date "+%Y-%m-%d %H:%M:%S")" +%s) ]]; then
    curl -sSf -o ./cf_ddns/pr_ip.txt https://cf.vbar.fun/pr_ip.txt
    echo "{\"pr1_expires\":\"$(($(date -d "$(date "+%Y-%m-%d %H:%M:%S")" +%s) + 86400))\"}" > ./cf_ddns/.pr_ip_timestamp
    echo "已更新线路1的反向代理列表"
  fi
elif [ "$IP_PR_IP" = "2" ] ; then
  if [[ $(cat ./cf_ddns/.pr_ip_timestamp | jq -r ".pr2_expires") -le $(date -d "$(date "+%Y-%m-%d %H:%M:%S")" +%s) ]]; then
    curl -sSf -o ./cf_ddns/pr_ip.txt https://cf.vbar.fun/zip_baipiao_eu_org/pr_ip.txt
    echo "{\"pr2_expires\":\"$(($(date -d "$(date "+%Y-%m-%d %H:%M:%S")" +%s) + 86400))\"}" > ./cf_ddns/.pr_ip_timestamp
    echo "已更新线路2的反向代理列表"
  fi
fi

if [ "$IP_PR_IP" -ne "0" ] ; then
  $CloudflareST $CFST_URL_R -t $CFST_T -n $CFST_N -dn $CFST_DN -tl $CFST_TL -dt $CFST_DT -tp $CFST_TP -sl $CFST_SL -p $CFST_P -tlr $CFST_TLR $CFST_STM -f ./cf_ddns/pr_ip.txt -o ./cf_ddns/result.csv
elif [ "$IP_ADDR" = "ipv6" ] ; then
  #开始优选IPv6
  $CloudflareST $CFST_URL_R -t $CFST_T -n $CFST_N -dn $CFST_DN -tl $CFST_TL -dt $CFST_DT -tp $CFST_TP -tll $CFST_TLL -sl $CFST_SL -p $CFST_P -tlr $CFST_TLR $CFST_STM -f ./cf_ddns/ipv6.txt -o ./cf_ddns/result.csv
else
  #开始优选IPv4
  $CloudflareST $CFST_URL_R -t $CFST_T -n $CFST_N -dn $CFST_DN -tl $CFST_TL -dt $CFST_DT -tp $CFST_TP -tll $CFST_TLL -sl $CFST_SL -p $CFST_P -tlr $CFST_TLR $CFST_STM -f ./cf_ddns/ip.txt -o ./cf_ddns/result.csv
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
x=0
updateDNSRecords() {
  subdomain=$1
  domain=$2
  csv_file='./cf_ddns/result.csv'
  # Add new DNS records from results.csv
  if [[ -f $csv_file ]]; then
      # Delete existing DNS records
    url="https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records"
    params="name=${subdomain}.${domain}&type=A,AAAA"
    response=$(curl -sm10 -X GET "$url?$params" -H "X-Auth-Email: $x_email" -H "X-Auth-Key: $api_key")
    if [[ $(echo "$response" | jq -r '.success') == "true" ]]; then
      records=$(echo "$response" | jq -r '.result')
      if [[ $(echo "$records" | jq 'length') -gt 0 ]]; then
        for record in $(echo "$records" | jq -c '.[]'); do
          record_id=$(echo "$record" | jq -r '.id')
          delete_url="$url/$record_id"
          delete_response=$(curl -sm10 -X DELETE "$delete_url" -H "X-Auth-Email: $x_email" -H "X-Auth-Key: $api_key")
          if [[ $(echo "$delete_response" | jq -r '.success') == "true" ]]; then
            echo "成功删除DNS记录$(echo "$record" | jq -r '.name')"
          else
            echo "删除DNS记录失败"
          fi
        done
      else
        echo "没有找到相关DNS记录"
      fi
    else
      echo "没有拿到DNS记录"
    fi
    # Declare an array to hold the IPs with positive speed
    declare -a ips

    # Assuming num is the total number of IPs in result.csv
    num=$(awk -F, 'END {print NR-1}' ./cf_ddns/result.csv)  # Subtract 1 if there's a header line in result.csv

    x=0  # Initialize counter
    while [[ ${x} -lt ${num} ]]; do
      ipAddr=$(sed -n "$((x + 2)),1p" ./cf_ddns/result.csv | awk -F, '{print $1}')
      ipSpeed=$(sed -n "$((x + 2)),1p" ./cf_ddns/result.csv | awk -F, '{print $6}')

      if [[ $ipSpeed == "0.00" ]]; then
        echo "第$((x + 1))个---$ipAddr测速为0，跳过更新DNS，检查配置是否能正常测速！"
      else
#        echo "准备更新第$((x + 1))个---$ipAddr"
        # Append the IP address to the ips array
        ips+=("$ipAddr")
      fi

      x=$((x + 1))  # Increment counter
    done

    for ip in "${ips[@]}"; do
      url="https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records"
      if [[ "$ip" =~ ":" ]]; then
        record_type="AAAA"
      else
        record_type="A"
      fi
      data='{
          "type": "'"$record_type"'",
          "name": "'"$subdomain.$domain"'",
          "content": "'"$ip"'",
          "ttl": 60,
          "proxied": false
      }'
      response=$(curl -s -X POST "$url" -H "X-Auth-Email: $x_email" -H "X-Auth-Key: $api_key" -H "Content-Type: application/json" -d "$data")
      if [[ $(echo "$response" | jq -r '.success') == "true" ]]; then
        echo "${subdomain}.${domain}成功指向IP地址$ip"
      else
        echo "更新IP地址${ip}失败"
      fi
      sleep 1
    done
  else
    echo "CSV文件$csv_file不存在"
  fi
}

# Begin loop
echo "正在更新域名，请稍等"
x=0

# Check if hostname is an array and set subdomain and domain accordingly
if [[ ${#hostname[@]} -gt 1 ]]; then
    # If hostname is an array, extract the first subdomain and domain
    CDNhostname=${hostname[0]}
else
    # If hostname is not an array, use the current hostname
    CDNhostname=${hostname[$x]}
fi

# Split the hostname into subdomain and domain outside the loop
subdomain=$(echo "$CDNhostname" | cut -d '.' -f 1)
domain=$(echo "$CDNhostname" | cut -d '.' -f 2-)
updateDNSRecords $subdomain $domain > $informlog

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

