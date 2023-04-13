# README

![GitHub Workflow Status (with branch)](https://img.shields.io/github/actions/workflow/status/SydneyOwl/docker-code-server/ci.yml?style=for-the-badge) ![Docker Pulls](https://img.shields.io/docker/pulls/sydneymrcat/code-server?style=for-the-badge) ![GitHub](https://img.shields.io/github/license/sydneyowl/docker-code-server?style=for-the-badge)

[中文文档](./README_CN.md)


This is a modified version of [linux-server](https://github.com/linuxserver/docker-code-server) which removed support of s6-overlay and use debian as base image. 

Only amd64/arm64/armv7 are supported; And arm64/armv7 images are not being tested.

This image is designed to be upgradeable (upgrading will not lose the environment already installed in the container). The upgrade tool is still being developed and has not yet been launched.

This image embeds Golang and go vscode plugins. The Go version is the version at the time of the push. For details, please refer to the [version log](#VersionLog).

**warning:golang in armhf is compiled through `GOROOT_FINAL=/usr/local GOOS=linux GOARCH=arm GOARM=7 GOBIN="/home/abc/go/bin" ./make.bash` from source and may not be compatible. See .github/scripts/compile_go.sh for more!!**

**THIS IS STILL A DRAFT AND IS NOT RECOMMANDED TO USE.**

## Build
If you want to directly pull the built image, you can skip this section.

If you need to build an armv7l image, you need to download the compiled golang dist from release and replace the go.tar.gz in the repository

To build the image：

```
docker build --pull --no-cache \
--build-arg CODE_RELEASE=`#optional;version of code_server` \
--build-arg GO_RELEASE=`#optional;version of golang` \
-t sydneymrcat/code-server .
```

## Run
First, please create a volume using `docker create volume code_app` to store the code-server application files. During the upgrade, this volume will be mounted into another container.

You can use either docker-cli or docker-compose to run the container.

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
  -v code_app:/app \
  --restart unless-stopped \
  sydneymrcat/code-server:latest
```
Here are the parameter descriptions:

| Parameter | Function |
| :----: | --- |
| `-p 8443` | web gui |
| `-e PUID=1000` | for UserID |
| `-e PGID=1000` | for GroupID |
| `-e TZ=Etc/UTC` | specify a timezone to use, see this [list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List). |
| `-e SKIP_INIT=` | Set to 1 to Skip initializing the container. This is for debug usage only! |
| `-e PASSWORD=password` | Optional web gui password, if `PASSWORD` or `HASHED_PASSWORD` is not provided, there will be no auth. |
| `-e HASHED_PASSWORD=` | Optional web gui password, overrides `PASSWORD`. |
| `-e SUDO_PASSWORD=password` | If this optional variable is set, user will have sudo access in the code-server terminal with the specified password. |
| `-e SUDO_PASSWORD_HASH=` | Optionally set sudo password via hash (takes priority over `SUDO_PASSWORD` var). Format is `$type$salt$hashed`. |
| `-e PROXY_DOMAIN=code-server.my.domain` | If this optional variable is set, this domain will be proxied for subdomain proxying. See [Documentation](https://github.com/cdr/code-server/blob/master/docs/FAQ.md#sub-domains) |
| `-e DEFAULT_WORKSPACE=/config/workspace` | If this optional variable is set, code-server will open this directory by default |
| `-v /config` | Contains all relevant configuration files. |
## Default installed environment
### Go and vscode plugin
 location:`/usr/local/go`

GOBIN: `/home/abc/go/bin`

## VersionLog

v0.2.0-beta: Bug fix: Cannot create necessary directories. Integrated go1.20.3 and code4.11.

v0.2.0-alpha: Bug fix: Cannot chown. Integrated go1.20.3 and code4.11. **Not Rcommanded to use.**

v0.1.x: Not Rcommanded to use.