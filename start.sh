#!/bin/bash
# Default config file
config_file="config.conf"

# Check if --cfg parameter is provided
for i in "$@"
do
    if [ "$i" == "--cfg" ]
    then
        # Get the next argument as the config file
        shift
        config_file="$1"
    fi
done

# Source the config file
source "$config_file"

source ./cf_ddns/cf_check.sh

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

source ./cf_ddns/cf_push.sh

exit 0;
