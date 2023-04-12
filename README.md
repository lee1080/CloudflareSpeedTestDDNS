# CloudflareSpeedTestDDNS
使用CloudflareSpeedTest工具优选IP后自动DDNS到Cloudflare

### 简易教程
#### 1.下载并解压脚本（载体可以是openwrt，或其他linux）
#### 2.填写`config.conf`配置文件
#### 3.运行脚本
```bash
bash start.sh
```

## ~~[教程过旧，待更新](https://blog.vbar.fun/archives/openwrt-ding-shi-you-xuan-cloudflareip-bing-geng-xin-dao-cloudflare)~~
~~详细使用教程请参考[详细教程](https://blog.vbar.fun/archives/openwrt-ding-shi-you-xuan-cloudflareip-bing-geng-xin-dao-cloudflare)~~

## Docker运行
https://hub.docker.com/r/lee1080/cfstddns

## 更新日志
### v2.2
#### 更改文件结构。
#### 新增了dnspod DNS服务商支持。
#### 新增了docker版。docker版不能自动停止路由器的科学插件，请将docker配置到没有科学环境的设备使用。
#### 增加了pushdeer推送、企业微信推送、Server酱、Synology Chat。
#### 增加了更新到hosts模式



### v2.1.1 
#### 新功能，支持更新优选完毕后推送至TG，再也不怕脚本没有成功运行了。
#### 新增openwrt专用`cf_RE.sh`文件，运行`cf_RE.sh`即可在openwrt安装`jq`和`timeout`两个扩展。

### v2.1 
#### 适配XIU2/CloudflareSpeedTest [v2.1.0](https://github.com/XIU2/CloudflareSpeedTest/releases/tag/v2.1.0) 修改ipv6测速策略

### v2.0 
#### 添加了多域名支持
可以在hostname中填入多个域名。使用[CloudflareSpeedTest](https://github.com/XIU2/CloudflareSpeedTest)工具得出优选IP列表后，脚本支持依次从速度最快的ip开始DDNS，域名数量可更具自己需求填写。
#### 优化科学上网插件重启时机

## 原理
使用Cloudflare的API，将CloudflareSpeedTest工具优选到的最快IP，自动更新到指定域名上。

## 存在问题
.tk .ml .ga .cf .gq这几个域名可能存在无法调用CloudflareAPI。

## 感谢
感谢[XIU2](https://github.com/XIU2)给大家提供了[CloudflareSpeedTest](https://github.com/XIU2/CloudflareSpeedTest)这么方便的优选IP的工具。
https://github.com/XIU2/CloudflareSpeedTest
