---
layout: post
title:  "PingCAP 面试：Jenkins 和 Kubernetes"
author: metal A-wing
date:   2021-01-27 17:00:00 +0800
comments: true
categories: kubernetes
---

看我给你表演一个绝活，12 个小时之内完成

> 题目：给定三台香港的机器（4C8G），搭建一个单 master 节点的 k8s 集群，并搭建 Jenkins ，
> 并且使用 k8s 作为 Jenkins 的 Work Node 自动调度，完成 Nginx/TiDB 的自动化发布（通过一个 Job）
>
> 时间是一周，机器我们可以提供，你什么时候开始小作业可以提前跟我说，我让同事把机器给你开了

## 本篇是以面试者的第一视角来纪录，可以当小说看，本文超长，建议闲着无聊时看～

作为一个开发码农，kubernetes 我是一点也不了解，看到题目一堆未知都东西。
jenkins 倒是玩过一点，jenkins  可以调 shell，写个脚本检测一下进城和 cpu 使用率，把 docker 塞给固定的机器。
ok，完美。先看一下 kubernetes 文档，看看 kubernetes 都能干啥

[找到了这篇](https://pingcap.com/meetup/meetup-84-20181220/)

哦，kubernetes 可以实现自动调度，连脚本都不用写了，然后发现还有这个插件[Kubernetes plugin for Jenkins](https://plugins.jenkins.io/kubernetes/)

这不一会就搞定！然后我就去和 HR 小姐姐说：

> 看我给你表演一个绝活，12 个小时之内完成

然后她竟然要我表演一个 2h 的

![草](/assets/img/jenkins_and_kubernetes/sticker_cao.jpg)

看到这里你肯定想问我面的是那个职位，管他那，干就完了（其实我也不知道我面的是啥）

之后我就在第二天提前下了个班，开始了我的地狱 12 小时之旅（

解释一下：我为什么不在当天就开始，原因是，我昨天晚上去打包 iredis 了，一晚上没睡

<blockquote class="twitter-tweet"><p lang="zh" dir="ltr">为了学习 redis 我把 iredis 打包到 archlinuxcn 仓库。然后看到原来 aur 上的是 bin 包。研究了一晚上 iredis 的构建流程。顺便也把用的打包工具 pyoxidizer 也打包了。。最后把体积减少了一半多，让它走了系统库<br><br>好了，我现在可以愉快的使用 redis 的命令行了。。折腾一晚上，redis 还一点没学（ <a href="https://t.co/VTkjd47t6N">pic.twitter.com/VTkjd47t6N</a></p>&mdash; 新一 (@_a_wing) <a href="https://twitter.com/_a_wing/status/1350937185957113857?ref_src=twsrc%5Etfw">January 17, 2021</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

* * *

<br/>

## 奥利给：真正的全栈可以解决任何问题

### 准备工作

![Start time](/assets/img/jenkins_and_kubernetes/screenshot_2021-01-19_19-59-38.png)

养成习惯，第一件事，看一下是哪个版本系统

```bash
cat /etc/os-release
NAME="CentOS Linux"
VERSION="7 (Core)"
ID="centos"
ID_LIKE="rhel fedora"
VERSION_ID="7"
PRETTY_NAME="CentOS Linux 7 (Core)"
ANSI_COLOR="0;31"
CPE_NAME="cpe:/o:centos:centos:7"
HOME_URL="https://www.centos.org/"
BUG_REPORT_URL="https://bugs.centos.org/"

CENTOS_MANTISBT_PROJECT="CentOS-7"
CENTOS_MANTISBT_PROJECT_VERSION="7"
REDHAT_SUPPORT_PRODUCT="centos"
REDHAT_SUPPORT_PRODUCT_VERSION="7"
```

完蛋了，我没用过 CentOS 系统，不过问题不大，记住这三个字母就行了 `yum`

查看基本信息备忘:

- 版本 `cat /etc/os-release`
- 时间 时区 `timedatectl status` （这个不同发行版可能不同）
- 语言 `echo $LANG`
- 网络 `ip addr`
- 镜像站 `cat /etc/yum.repos.d/CentOS-Base.repo`
- cpu `cat /proc/cpuinfo`
- 内存 `cat /proc/meminfo && free -h`

然后在 `/etc/motd` 留下笔记的链接（我就默认你们知道 `motd`（message of the day） 是干啥用的了）

更新：`yum upgrade`

* * *

<br/>

[首选看 kubernetes 文档，这篇是最关键的](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)

了解了这三个模块

- `kubeadm`: 这是一个启动器
- `kubelet`: 这玩意就是 kubernetes 的本体
- `kubectl`: 命令行控制程序

`kubelet` 每个都要有，但是 kubernetes 是个集群，启动的过程有些复杂，所以需要 `kubeadm` 来帮助我们来启动的集群

`kubectl` 就是仅仅只是一个命令行客户端，在不在服务器上无所谓

kubernetes 的运行时 CRI （Container Runtimes Interface）

[官方文档指定了三个](https://kubernetes.io/docs/setup/production-environment/container-runtimes/)

- containerd
- CRI-O
- Docker

鉴于 `containerd` 和 `CRI-O` 完全没听说过，我们直接从 `Docker` 开始

### 设置网桥

```bash
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system
```

### Docker

安装 Docker ，没什么值得注意的，直接照着官方文档复制粘贴就行

唯一值得注意的是

```base
mkdir -p /etc/systemd/system/docker.service.d
```

不设置 Docker 参数，这个是没用的。可以参照这两篇：

[Docker daemon/systemd](https://docs.docker.com/config/daemon/systemd/)

[wiki.archlinux Systemd](https://wiki.archlinux.org/index.php/Systemd#Drop-in_files)

### 准备工作都做完了：安装 kubernetes

直接照着官方文档来：

```bash
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

# Set SELinux in permissive mode (effectively disabling it)
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

sudo systemctl enable --now kubelet
```

由于对版本有要求，所以那个软件源禁用了那三个包（防止 `upgrade` 时挂掉）

不要在意 `systemctl status kubelet` 的错误，因为：

```bash
[root@10-8-19-173 ~]# systemctl cat kubelet
# /usr/lib/systemd/system/kubelet.service
[Unit]
Description=kubelet: The Kubernetes Node Agent
Documentation=https://kubernetes.io/docs/
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/bin/kubelet
Restart=always
StartLimitInterval=0
RestartSec=10

[Install]
WantedBy=multi-user.target

# /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
# Note: This dropin only works with kubeadm and kubelet v1.11+
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
# This is a file that "kubeadm init" and "kubeadm join" generates at runtime, populating the KUBELET_KUBEADM_ARGS variable dynamically
EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env
# This is a file that the user can use for overrides of the kubelet args as a last resort. Preferably, the user should use
# the .NodeRegistration.KubeletExtraArgs object in the configuration files instead. KUBELET_EXTRA_ARGS should be sourced from this file.
EnvironmentFile=-/etc/sysconfig/kubelet
ExecStart=
ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS
```

在 master 上执行

```bash
kubeadm init
```

根据提示在两个 slave 上都执行

```bash
kubeadm join 10.8.19.173:6443 --token yv1ecz.8g7j4d1hztx3cnf6 \
    --discovery-token-ca-cert-hash sha256:dc1778180a75dbf321463dd17897d2357fde5c69756342671cef5048eaf01249
```

然后按照提示在 master 配置 `kubectl` 都配置文件

```bash
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
```

![Uptime](/assets/img/jenkins_and_kubernetes/screenshot_2021-01-20_00-07-57.png)

#### **跑起来了，跑起来了！！！此时已经是到了凌晨了**

现在可以看到状态是 `NotReady`

是因为缺少 CNI （Container Network Interface）

网络使用这个，因为可以不用设置

```bash
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

虽然官方使用 `Calico` 来测试的

[有迁移办法方法问题不大](https://docs.projectcalico.org/getting-started/kubernetes/flannel/migration-from-flannel)

`kubeadm init` 设置参数有问题，忘记设置网络了

在全部的机器上执行 `kubeadm reset`，关闭集群

人生重来，重新开始

```bash
kubeadm init --pod-network-cidr 192.168.0.0/16
```

每次生成的 `/etc/kubernetes/admin.conf` 里面的内容都是不同的，reset 之后要重新设置

```bash
# To start using your cluster, you need to run the following as a regular user:

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

![Ready](/assets/img/jenkins_and_kubernetes/screenshot_2021-01-20_02-06-02.png)

看集群状态：

```bash
kubectl get pods --all-namespaces
```

## Jenkins

[安装 Jenkins，直接照着官方文档](https://www.jenkins.io/doc/book/installing/linux/#red-hat-centos)

```bash
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum upgrade
sudo yum install jenkins java-1.8.0-openjdk-devel
sudo systemctl daemon-reload
sudo systemctl start jenkins
```

之后初始化 Jenkins，填入初始密码，然后一路下一步

```bash
cat /var/lib/jenkins/secrets/initialAdminPassword
```

新建的管理员用户的密码可以使用随机生成的密码

```bash
hexdump -v -n 16 -e '1/1 "%02x"' /dev/urandom
```

### Kubernetes plugin for Jenkins

安装 Jenkins 的插件

使用 Secret File (kubeconfig file)

配置 Kubernetes 地址 `localhost:6443`

## 好，build 开始

发现问题：

```bash
[root@10-8-19-173 ~]# kubectl logs -f pods/tidb2-6-0132h-p44wx-86k7l jnlp
Jan 19, 2021 9:06:17 PM hudson.remoting.jnlp.Main createEngine
INFO: Setting up agent: tidb2-6-0132h-p44wx-86k7l
Jan 19, 2021 9:06:17 PM hudson.remoting.jnlp.Main$CuiListener <init>
INFO: Jenkins agent is running in headless mode.
Jan 19, 2021 9:06:17 PM hudson.remoting.Engine startEngine
INFO: Using Remoting version: 4.3
Jan 19, 2021 9:06:17 PM org.jenkinsci.remoting.engine.WorkDirManager initializeWorkDir
INFO: Using /home/jenkins/agent/remoting as a remoting work directory
Jan 19, 2021 9:06:17 PM org.jenkinsci.remoting.engine.WorkDirManager setupLogging
INFO: Both error and output logs will be printed to /home/jenkins/agent/remoting
Jan 19, 2021 9:06:17 PM hudson.remoting.jnlp.Main$CuiListener status
INFO: Locating server among [http://152.32.240.177:8080/]
Jan 19, 2021 9:06:47 PM hudson.remoting.jnlp.Main$CuiListener error
SEVERE: Failed to connect to http://152.32.240.177:8080/tcpSlaveAgentListener/: connect timed out
java.io.IOException: Failed to connect to http://152.32.240.177:8080/tcpSlaveAgentListener/: connect timed out
        at org.jenkinsci.remoting.engine.JnlpAgentEndpointResolver.resolve(JnlpAgentEndpointResolver.java:217)
        at hudson.remoting.Engine.innerRun(Engine.java:693)
        at hudson.remoting.Engine.run(Engine.java:518)
Caused by: java.net.SocketTimeoutException: connect timed out
        at java.net.PlainSocketImpl.socketConnect(Native Method)
        at java.net.AbstractPlainSocketImpl.doConnect(AbstractPlainSocketImpl.java:350)
        at java.net.AbstractPlainSocketImpl.connectToAddress(AbstractPlainSocketImpl.java:206)
        at java.net.AbstractPlainSocketImpl.connect(AbstractPlainSocketImpl.java:188)
        at java.net.SocksSocketImpl.connect(SocksSocketImpl.java:392)
        at java.net.Socket.connect(Socket.java:607)
        at sun.net.NetworkClient.doConnect(NetworkClient.java:175)
        at sun.net.www.http.HttpClient.openServer(HttpClient.java:463)
        at sun.net.www.http.HttpClient.openServer(HttpClient.java:558)
        at sun.net.www.http.HttpClient.<init>(HttpClient.java:242)
        at sun.net.www.http.HttpClient.New(HttpClient.java:339)
        at sun.net.www.http.HttpClient.New(HttpClient.java:357)
        at sun.net.www.protocol.http.HttpURLConnection.getNewHttpClient(HttpURLConnection.java:1226)
        at sun.net.www.protocol.http.HttpURLConnection.plainConnect0(HttpURLConnection.java:1162)
        at sun.net.www.protocol.http.HttpURLConnection.plainConnect(HttpURLConnection.java:1056)
        at sun.net.www.protocol.http.HttpURLConnection.connect(HttpURLConnection.java:990)
        at org.jenkinsci.remoting.engine.JnlpAgentEndpointResolver.resolve(JnlpAgentEndpointResolver.java:214)
        ... 2 more
```

目前产生了一个问题：

- Jenkins → Kubernetes （正常）
- Kubernetes → Jenkins（迷之 connect timed out）

改变 Jenkins 设置

这个插件的工作原理是这样的：

在 Kubernetes 创建一个 pods，这个 pods 里面有两个容器。
一个是构建用的，另一个是负责收集构建容器输出的日志传回 Jenkins 主程序

收集日志的容器会主动链接主程序，可以使用 `http`, `websocket`, `tcp` 来通信

这几种方式我都测试过了，然后也把 Jenkins 都权限一路开到最大，仍然无法通信

一路把权限开到最大还是不行。。。我真的怀疑这个容器的网有问题

## 验证 Kubernetes 的内部网络

先在宿主机上安装 nc 工具。（`netcat`）

随便起一个 Tcp server

```bash
nc -l 8877
```

把 jenkins kubernetes 的插件设置改到刚开到那个端口（ 8877 那个 ），要用 http 的方式（当然 websocket 也可以）

根据 http 1.x 的原理，http 是明文传输，是可以在 nc 起的 server 里面看到 http 头的
`websocket` 也是先发个 http 包，之后 Upgrade

你可以用这两条来验证我说的：

```bash
nc -l 8877
curl localhost:8877
```

测试结果

![netcat](/assets/img/jenkins_and_kubernetes/screenshot_2021-01-20_06-27-35.png)

收集日志的容器网不通

根据这个插件原理：

这个是日志收集容器 [Docker Hub](https://hub.docker.com/r/jenkins/inbound-agent)

照着这个文件画瓢 [`https://k8s.io/examples/application/shell-demo.yaml`](https://k8s.io/examples/application/shell-demo.yaml)

```bash
cat > jenkins.yaml << EOF
apiVersion: v1
kind: Pod
metadata:
  name: jenkins-demo
spec:
  volumes:
  - name: shared-data
    emptyDir: {}
  containers:
  - name: agent
    image: jenkins/inbound-agent
  hostNetwork: true
  dnsPolicy: Default
EOF
```

起个容器

```bash
kubectl create -f jenkins.yaml

# 然后就挂了
[root@10-8-19-173 ~]# kubectl get pods
NAME                         READY   STATUS             RESTARTS   AGE
jenkins-demo                 0/1     CrashLoopBackOff   7          13m
shell-demo                   1/1     Running            0          98m
tidb2-13-dn3zw-tsdqp-6l0z6   1/2     Terminating        0          43s
tidb2-13-dn3zw-tsdqp-qmrjn   2/2     Running            0          3s
tidb2-13-dn3zw-tsdqp-vtmxg   0/2     Terminating        0          2m3s
[root@10-8-19-173 ~]#
```

这个东西有四个变量。。。啊，不知道该怎么传变量啊。。。

找到这篇文档

[https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/)

[Define Environment Variables for a Container](https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-container/)

看日志。。。这该死的容器好像不听我的。。。

```bash
kubectl logs -f pods/jenkins-demo agent
```

查看 Jenkins 起动的 pods 的环境变量

`kubectl describe pods/tidb2-13-dn3zw-tsdqp-ms1l`

```bash
    Environment:
      JENKINS_SECRET:         fe2e12708ad3b3daa74f5c7e253ab1e8620901255927238ad7444aba650a3e3e
      JENKINS_AGENT_NAME:     tidb2-13-dn3zw-tsdqp-ms1ls
      JENKINS_NAME:           tidb2-13-dn3zw-tsdqp-ms1ls
      JENKINS_AGENT_WORKDIR:  /home/jenkins/agent
      JENKINS_URL:            http://152.32.240.177:8877/
```

加上变量，故技重施

改成一样的参数也是可以好使的。。。。

```bash
[root@10-8-19-173 ~]# cat jenkins.yaml
apiVersion: v1
kind: Pod
metadata:
  name: jenkins-demo
spec:
  volumes:
  - name: shared-data
    emptyDir: {}
  containers:
  - name: agent
    image: jenkins/inbound-agent
    env:
    - name:  JENKINS_SECRET
      value: fe2e12708ad3b3daa74f5c7e253ab1e8620901255927238ad7444aba650a3e3e
    - name:  JENKINS_AGENT_NAME
      value: tidb2-13-dn3zw-tsdqp-ms1ls
    - name:  JENKINS_NAME
      value: tidb2-13-dn3zw-tsdqp-ms1ls
    - name:  JENKINS_AGENT_WORKDIR
      value: /home/jenkins/agent
    - name:  JENKINS_URL
      value: http://152.32.240.177:8877/
  hostNetwork: true
  dnsPolicy: Default
```

![jenkins network](/assets/img/jenkins_and_kubernetes/screenshot_2021-01-20_07-23-51.png)

这个是好用的。我人傻了。。。

对比环境变量，完全一致

`kubectl describe pods/jenkins-demo`

`kubectl describe pods/tidb2-13-dn3zw-tsdqp-ms1l`

## **然后我该怎么处理。。。。没思路了**

我好菜啊，还剩最后一步，不知道该怎么解决了。。。

- 搭建 Kubernetes 花了四个小时
- 在 Jenkins 那个接口上花了尽五个小时
- 加上剩下的总计花费了十二个小时

此时已经是早上八点了，不搞了，去睡觉

![current](/assets/img/jenkins_and_kubernetes/screenshot_2021-01-20_07-52-08.png)

* * *
<br/>
* * *
<br/>
* * *
<br/>

睡了一觉，一觉醒来

仔细看了配置，发现

```yaml
hostNetwork: true
dnsPolicy: Default
```

Jenkins 的 manifest 和我拉下来测试的 manifest 网络部分有不一样的地方

经过测试是 `hostNetwork: true` 的影响

`hostNetwork` 这个参数是 [使用本机的网络](https://kubernetes.io/docs/concepts/policy/pod-security-policy/#host-namespaces)

这说明我 Kubernetes 目前是没法联网的

### 写构建过程

```groovy
podTemplate(yaml: '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: golang
    image: golang:1.13.0
    command:
    - sleep
    args:
    - infinity
  hostNetwork: true
  dnsPolicy: Default
''') {
    node(POD_LABEL) {
        stage('Build TiDB') {
            git url: 'https://github.com/pingcap/tidb.git'
            container('golang') {
                stage('Build a TiDB') {
                    sh """
                    make server

                    cd bin
                    sha1sum tidb-server > tidb-server.sha1sum
                    sha512sum tidb-server > tidb-server.sha512sum
                    """
                }
            }
            archiveArtifacts 'bin/*'
        }

    }
}
```

![Kubernetes](/assets/img/jenkins_and_kubernetes/screenshot_2021-01-20_13-51-20.png)

![Jenkins](/assets/img/jenkins_and_kubernetes/screenshot_2021-01-20_13-48-15.png)

如果重点是：

> k8s 作为 Jenkins 的 Work Node 自动调度

我觉得我已经完成了（作为一个 demo 来说），虽然 Jenkins 还需要手动点 build （重点不在这吧），构建结果只提供了 linux x86_64 的 bin 包

![power](/assets/img/jenkins_and_kubernetes/sticker_power.png)

- 预计花费时间 12h
- 总计花费时间 14h

完成时间 `Wed Jan 20 13:49:15 CST 2021`

# 之后的思考

### 尝试在自己笔记本上远程控制

启动时要指定连接 ip 。vps 是 basic nat 转换的，拿到的 ip  是私有地址

```bash
# 在自己的笔记本安装 kubectl
mkdir -p $HOME/.kube
scp root@152.32.240.177:/etc/kubernetes/admin.conf $HOME/.kube/config

kubectl get nodes
Unable to connect to the server: x509: certificate is valid for 10.96.0.1, 10.8.19.173, not 152.32.240.177

# 可以跳过证书。（逃
kubectl --insecure-skip-tls-verify get nodes
```

发动技能，“人生重来“，`reset` 之后再 `init` 加上这个参数

```bash
kubeadm init --apiserver-advertise-address 152.32.240.177 --pod-network-cidr 192.168.0.0/16
```

[kubeadm init](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/#options)

问题来了。。。我能不能不 `reset` 再 `init`

[Unable to connect to the server: x509: certificate is valid for](https://stackoverflow.com/questions/52915110/unable-to-connect-to-the-server-x509-certificate-is-valid-for)

不过大体思路是有的：自己生成一个 tls 证书，把公共的 ip 写进去

这个地方是由 `/etc/kubernetes/manifests/kube-apiserver.yaml` 文件起的 pod

修改这个，然后再 apply ，应该可行

```bash
kubectl apply -f /etc/kubernetes/manifests/kube-apiserver.yaml
```

[不过 `apiserver` 似乎并不生成证书](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/)

后来又翻到了这篇：

[Invalid x509 certificate for kubernetes master](https://stackoverflow.com/questions/46360361/invalid-x509-certificate-for-kubernetes-master)

直接两行解决

```bash
rm /etc/kubernetes/pki/apiserver.*
kubeadm init phase certs all --apiserver-advertise-address 152.32.240.177
```

肯定会有人有疑问。。。`/etc/kubernetes/admin.conf` 更新了吗？

没有，那里面写的是根证书

根证书在这里：`/etc/kubernetes/pki/ca.crt`

`/etc/kubernetes/admin.conf` 里的 clusters `certificate-authority-data` 可以通过这条命令生成

```bash
# certificate-authority-data
cat /etc/kubernetes/pki/ca.crt | base64 -w 0
```

当然，用 `openssl x509` 去生成一个证书应该也是可行的

## 面试

之后就是和面试官聊了

我专门找 HR 确认了，面试官不是出题人，应该不会谈面试题

我很慌，万一考了 `动态规划` 和 `图论` 我估计就挂了

然后，倒是没聊什么技术，就聊了聊产品和原来做的东西。。。。

然后我就挂了

> 面试官内心 OS：这家伙说话声音难听，语速又贼快，随便编个理由把它挂了吧
>
> 理由就叫：就叫没讲清楚你干了啥吧

我：？？？？？？？

![太奇怪了，准备用脑子想](/assets/img/jenkins_and_kubernetes/sticker_think.jpg)

等着，这就去学伪声（x

> 这就和面试进门先迈哪只脚一样，反正看你不爽，你先迈哪只脚都不对（

## 总结

我觉得我被莫名其妙拉过去面试，然后又莫名其妙挂掉了

可能是我不够 Match 。我也觉得我不 Match，毕竟我原来做的东西和 PingCAP 做的东西基本上没啥相关性

不过，没啥相关性别拉我过去做题啊。（我每天忙的要死

啊，对了。我还不知道我面的是啥岗位那（

挂掉这一面没有问技术是我最出乎意料掉一点，昨天晚上我还在研究会问什么题那（x

还有就是所属行业不同，我没有交代清楚背景，和为什么要这么做。

~~最后的总结就是：**PingCAP 这家不按套路出牌** 和 **我的吹牛技术还不够资深**~~

面试题我和 HR 确认过了，是可以发 blog 的

## 反省

我挂掉是我的问题，我不应该假定别人有相应的基础知识。

上次去分享 WebRTC 的时候也是，我假定大家都懂 NAT （我不该这么假定）

一上来就讲原理，大家甚至都不知道这个东西是什么，也不知这东西有什么用

讲的内容又过于硬核，语速又超快
（之后被朋友批评了一顿，又在同一个地方栽跟头了）

还有这篇文章，我又双叒叕的假定了大家都知道 `/etc/motd` 是干什么用的

> `/etc/motd` 内容的会在用户成功登录后由 Unix 登录命令显示，
>
> 整个过程发生在 shell 登录之前。

立个 Flag 吧：我要让你们都知道，我这几年干了啥！

