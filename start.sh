#!/bin/bash
# Default config file
config_file="config.conf"
# Source the default config file to get all default config
source "$config_file"
# Check if --cfg parameter is provided
for i in "$@"
do
    if [ "$i" == "--cfg" ]
    then
        # Get the next argument as the config file
        shift
        config_file="$1"
        # Source the config file given by user and modify the default
        source "$config_file"
    fi
done
# remove the result.csv if exists
rm cf_ddns/result.csv
source ./cf_ddns/cf_check.sh

case $DNS_PROVIDER in
    1)
        source ./cf_ddns/cf_ddns_cloudflare_multiple.sh
        ;;
    2)
        source ./cf_ddns/cf_ddns_dnspod.sh
        ;;
    *)
        echo "未选择任何DNS服务商"
        ;;
esac

# informlog中不能带空格，否则不能被识别
source ./cf_ddns/cf_push.sh

exit 0;
