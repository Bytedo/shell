# shell

常用脚本命令

## 服务器测试相关

#### 查看CPU信息

```bash
cat /proc/cpuinfo
```

#### 查看 25 端口是否开放

```bash
telnet smtp.aol.com 25
```

#### 测试 IPv4 优先还是 IPv6 优先

```bash
curl ip.p3terx.com
```



#### 单线程测试

```bash
bash <(curl -Lso- https://bench.im/hyperspeed)
```

#### 最全测速脚本

```bash
curl -fsL https://ilemonra.in/LemonBenchIntl | bash -s fast
```

#### superbench

```bash
wget -qO- git.io/superbench.sh | bash
```

#### Bench.sh

```bash
wget -qO- bench.sh | bash
```

#### 显示延迟、抖动

```bash
bash <(wget -qO- https://bench.im/hyperspeed)
```

#### 直接显示回程线路

```bash
curl https://raw.githubusercontent.com/zhucaidan/mtr_trace/main/mtr_trace.sh|bash

wget -q route.f2k.pub -O route && bash route
```

#### 四网测速

```bash
wget -O jcnf.sh https://raw.githubusercontent.com/Netflixxp/jcnfbesttrace/main/jcnf.sh

bash jcnf.sh
```

#### 三网测速

```bash
bash <(curl -Lso- https://git.io/superspeed_uxh)
```

带快速四网测试版本：

```bash
bash <(curl -Lso- https://dl.233.mba/d/sh/speedtest.sh)
bash <(curl -Lso- https://git.io/J1SEh)
```

#### 检测服务器内存

CentOS / RHEL

```
yum install wget -y
yum groupinstall "Development Tools" -y
wget https://raw.githubusercontent.com/FunctionClub/Memtester/master/memtester.cpp
gcc -l stdc++ memtester.cpp
./a.out
```

Ubuntu / Debian

```
apt-get update
apt-get install wget build-essential -y
wget https://raw.githubusercontent.com/FunctionClub/Memtester/master/memtester.cpp
gcc -l stdc++ memtester.cpp
./a.out
```



### OPENAI 相关

检测是否可以访问 ChatGPT 

```bash
bash <(curl -Ls https://raw.githubusercontent.com/missuo/OpenAI-Checker/main/openai.sh)
```

## 服务器软件

#### 安装 wget
CentOS

```bash
yum install wget -y
```

Ubuntu / Debian

```bash
apt-get install wget -y
```


#### Aria2一键安装脚本

```bash
wget -N git.io/aria2.sh && chmod +x aria2.sh && ./aria2.sh
```

#### Cloudflare warp一键脚本

```bash
wget -N https://raw.githubusercontent.com/fscarmen/warp/main/menu.sh && bash menu.sh [option] [lisence]
```

作者github：[https://github.com/fscarmen/warp](https://github.com/fscarmen/warp)

WARP

```bash
wget -N --no-check-certificate https://cdn.jsdelivr.net/gh/YG-tsj/CFWarp-Pro/multi.sh && chmod +x multi
bash multi.sh // 启动
```

#### 删除腾讯云监控

```bash
sudo -i
systemctl stop tat_agent
systemctl disable tat_agent
/usr/local/qcloud/stargate/admin/uninstall.sh
/usr/local/qcloud/YunJing/uninst.sh
/usr/local/qcloud/monitor/barad/admin/uninstall.sh
rm -f /etc/systemd/system/tat_agent.service
rm -rf /usr/local/qcloud
rm -rf /usr/local/sa
rm -rf /usr/local/agenttools
rm -rf /usr/local/qcloud
process=(sap100 secu-tcs-agent sgagent64 barad_agent agent agentPlugInD pvdriver )
for i in ${process[@]}
do
  for A in $(ps aux | grep $i | grep -v grep | awk '{print $2}')
  do
    kill -9 $A
  done
done
```

#### X-UI

```bash
bash <(curl -Ls https://raw.githubusercontent.com/FranzKafkaYu/x-ui/master/install.sh)
```
#### 缝合工具箱

```bash
wget -O box.sh https://raw.githubusercontent.com/BlueSkyXN/SKY-BOX/main/box.sh && chmod +x box.sh && clear && ./box.sh
```
