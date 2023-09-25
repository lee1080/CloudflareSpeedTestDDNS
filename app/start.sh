#!/bin/bash
if [ ! -e ".ran_before" ]; then
  cp ./cf_ddns/config.conf.bak ./config/config.conf
fi
source ./config/config.conf;
source ./cf_ddns/cf_check.sh;
source ./cf_ddns/crontab.sh;
case $DNS_PROVIDER in
    1)
        source ./cf_ddns/cf_ddns_cloudflare.sh
        ;;
    2)
        source ./cf_ddns/cf_ddns_dnspod.sh
        ;;
    *)
        echo "未选择任何DNS服务商"
        ;;
esac
source ./cf_ddns/cf_push.sh;
#tail -f /dev/null;
exit 0;