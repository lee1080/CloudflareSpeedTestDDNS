# CloudflareSpeedTestDDNS
使用CloudflareSpeedTest工具优选IP后自动DDNS到Cloudflare

## 原理
使用Cloudflare的API，将CloudflareSpeedTest工具优选到的最快IP，自动更新到指定域名上。

## 使用教程
详细使用教程请参考[blog](https://blog.vbar.fun/archives/openwrt-ding-shi-you-xuan-cloudflareip-bing-geng-xin-dao-cloudflare)

## 存在问题
.tk .ml .ga .cf .gq这几个域名可能存在无法调用CloudflareAPI。

## 感谢
感谢[XIU2](https://github.com/XIU2)给大家提供了[CloudflareSpeedTest](https://github.com/XIU2/CloudflareSpeedTest)这么方便的优选IP的工具。
https://github.com/XIU2/CloudflareSpeedTest
