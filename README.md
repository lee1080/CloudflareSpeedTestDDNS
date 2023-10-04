# CloudflareSpeedTestDDNS
使用CloudflareSpeedTest工具优选IP后自动DDNS到Cloudflare

### 简易教程
#### 1.下载并解压脚本（载体可以是openwrt，或其他linux）
#### 2.填写`config.conf`配置文件
#### 3.运行脚本
```bash
bash start.sh
```

## ~~[教程过旧，待更新](https://blog.vbar.fun/archives/openwrt%E5%AE%9A%E6%97%B6%E4%BC%98%E9%80%89cloudflareip%E5%B9%B6%E6%9B%B4%E6%96%B0%E5%88%B0dnspod)~~
~~详细使用教程请参考[详细教程](https://blog.vbar.fun/archives/openwrt%E5%AE%9A%E6%97%B6%E4%BC%98%E9%80%89cloudflareip%E5%B9%B6%E6%9B%B4%E6%96%B0%E5%88%B0dnspod)~~

## Docker运行
https://hub.docker.com/r/lee1080/cfstddns

## 更新日志

### 20231004
#### 优化测速指定端口判断。
#### 优化cloudflare配置。
#### 新增单个IP下载测速最长时间配置。
#### 修复反代IP线路并新增一条线路。

### 更早的更新日志
<details>
<summary><code><strong>「 点击展开 查看更早的更新日志 」</strong></code></summary>

****

### V2.3
#### 适配XIU2/CloudflareSpeedTest:v2.2.4 | 新增自定义测速地址端口支持
#### 新增PushPlus推送。
#### 优化更新规则，测速为0则跳过域名更新。

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


</details>

****


## 原理
使用Cloudflare的API，将CloudflareSpeedTest工具优选到的最快IP，自动更新到指定域名上。

## 存在问题
.tk .ml .ga .cf .gq这几个域名可能存在无法调用CloudflareAPI。

## 感谢
* 感谢[XIU2](https://github.com/XIU2)给大家提供了[CloudflareSpeedTest](https://github.com/XIU2/CloudflareSpeedTest)这么方便的优选IP的工具。 https://github.com/XIU2/CloudflareSpeedTest
* 感谢[ip-scanner](https://github.com/ip-scanner)[cloudflare](https://github.com/ip-scanner/cloudflare)项目提供的反代地址。
* 感谢[CF中转IP发布](https://t.me/cf_push)提供反代地址。

#### 感谢以下小伙伴一起更正和完善代码
* [Jason6111](https://github.com/Jason6111)
* [Nigel-NI](https://github.com/Nigel-NI)
* [linntt88](https://github.com/linntt88)
* [stephenzwj](https://github.com/stephenzwj)
