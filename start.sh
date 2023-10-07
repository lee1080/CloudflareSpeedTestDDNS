#!/bin/bash
# Default config file
config_file="config.conf"

# Source the default config file to get all default config
source "$config_file"
# Check if --cfg parameter is provided
for i in "$@"
do
@@ -10,12 +11,11 @@ do
        # Get the next argument as the config file
        shift
        config_file="$1"
        # Source the config file given by user and modify the default
        source "$config_file"
    fi
done

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
