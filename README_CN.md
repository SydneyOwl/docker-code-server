# README

这是 [linux-server](https://github.com/linuxserver/docker-code-server) 的修改版本，已删除对 s6-overlay 的支持，并以 debian 为基础镜像。

目前仅支持 在amd64/arm64/armv7架构上运行；并且 arm64/armv7 镜像没有经过测试。

这个镜像被设计为可升级，即升级后不会失去已安装在容器中的环境。升级工具还在编写中，尚未上线！

CI每十分钟自动检查code-server以及golang是否有可用的稳定版的更新。如果有，则自动拉取并构建新的镜像。所以从sydneymrcat/code-server拉取的镜像始终具有最新的code-server和go版本

**警告：armhf 上的 Golang 是通过 `GOROOT_FINAL=/usr/local GOOS=linux GOARCH=arm GOARM=7 GOBIN="/home/abc/go/bin" ./make.bash` 从源代码编译而来，可能不兼容。请参见 .github/scripts/compile_go.sh 获取更多信息！**

## 手动构建

如果想要直接拉取构建好的镜像，直接跳过这一部分即可

构建命令：

```
docker build --pull --no-cache \
--build-arg CODE_RELEASE=`#可选;code_server的版本` \
--build-arg GO_RELEASE=`#可选；golang版本` \
-t sydneymrcat/code-server .
```

## 运行

首先，请创建一个用于存放code-server应用文件的卷`docker create volume code_app`。升级时，这个卷将被挂载到另一个容器中.

可以使用两种方式创建容器:

docker-compose

```docker
---
version: "2.1"
services:
  code-server:
    image: sydneymrcat/code-server:latest
    container_name: code-server
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - PASSWORD=password #optional
      - HASHED_PASSWORD= #optional
      - SUDO_PASSWORD=password #optional
      - SUDO_PASSWORD_HASH= #optional
      - PROXY_DOMAIN=code-server.my.domain #optional
      - DEFAULT_WORKSPACE=/config/workspace #optional
      - SKIP_INIT= # Debug only.
    volumes:
      - /path/to/appdata/config:/config
      - code_app:/app
    ports:
      - 8443:8443
    restart: unless-stopped
```

docker cli

```docker
docker run -d \
  --name=code-server \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Etc/UTC \
  -e PASSWORD=password `#optional` \
  -e HASHED_PASSWORD= `#optional` \
  -e SUDO_PASSWORD=password `#optional` \
  -e SUDO_PASSWORD_HASH= `#optional` \
  -e PROXY_DOMAIN=code-server.my.domain `#optional` \
  -e DEFAULT_WORKSPACE=/config/workspace `#optional` \
  -e SKIP_INIT= `# Debug only.` \
  -p 8443:8443 \
  -v /path/to/appdata/config:/config \
  -v code_app:/app
  --restart unless-stopped \
  sydneymrcat/code-server:latest
```

以下是参数说明

|                   参数                   | 功能                                                         |
| :--------------------------------------: | ------------------------------------------------------------ |
|                `-p 8443`                 | 网页界面端口                                                 |
|              `-e PUID=1000`              | 用户ID                                                       |
|              `-e PGID=1000`              | 用户组ID                                                     |
|             `-e TZ=Etc/UTC`              | 指定要使用的时区，参考[时区列表](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List)。 |
|             `-e SKIP_INIT=`              | 设置为1以跳过初始化容器。仅用于调试！                        |
|          `-e PASSWORD=password`          | 可选的网页界面密码，如果未提供`PASSWORD`或`HASHED_PASSWORD`，则不需要认证。 |
|          `-e HASHED_PASSWORD=`           | 可选的网页界面密码，覆盖`PASSWORD`，下面将介绍如何创建密码哈希值。 |
|       `-e SUDO_PASSWORD=password`        | 如果设置了此可选变量，则用户将具有终端中sudo访问权限，密码为指定的密码。 |
|         `-e SUDO_PASSWORD_HASH=`         | 可选地通过哈希设置sudo密码（优先于`SUDO_PASSWORD`变量）。格式为`$type$salt$hashed`。 |
| `-e PROXY_DOMAIN=code-server.my.domain`  | 如果设置了此可选变量，则此域将被代理进行子域代理。参见[文档](https://github.com/cdr/code-server/blob/master/docs/FAQ.md#sub-domains) |
| `-e DEFAULT_WORKSPACE=/config/workspace` | 如果设置了此可选变量，code-server将默认打开此目录。          |
|               `-v /config`               | 包含所有相关配置文件。                                       |

## 默认安装的环境

### Go及其code插件

位置:`/usr/local/go`

GOBIN: `/home/abc/go/bin`