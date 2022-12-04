#!/bin/bash
##用于openwrt安装jq和timeout，确保CloudflareSpeedTestDDNS运行正常。
opkg update
opkg install jq coreutils-timeout
opkg list-installed | grep jq
opkg list-installed | grep coreutils-timeout