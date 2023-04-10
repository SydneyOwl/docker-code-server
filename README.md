This is a modified version of linux-server which removed support of s6-overlay and use debian as base image. See https://github.com/linuxserver/docker-code-server for more detail.

Armhf is no supported in this image right now.

This image is designed updateable so you won't lost your environment manually installed in the container. The updater is not released since it is still unstable. 

~~Python3.8 and~~Go1.18 environment and their vscode plugins are integrated in this image as well..

**THIS IS STILL A DRAFT AND IS NOT RECOMMANDED TO USE.**

## Build
If you want to pull and run image prebuild, just ignore this section

To build the image, use `docker build --pull --no-cache -t sydneymrcat/code-server .` This builds amd64 image by default!

## Run
First, Create a volume to put code-server base application: `docker volume create code-app`. This volume will be mounted to the updater container.

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
      - code-app:/app
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
  -v code-app:/app
  --restart unless-stopped \
  sydneymrcat/code-server:latest
```
Here's the explainations of the args ccording to linux-server's readme:

| Parameter | Function |
| :----: | --- |
| `-p 8443` | web gui |
| `-e PUID=1000` | for UserID - see below for explanation |
| `-e PGID=1000` | for GroupID - see below for explanation |
| `-e TZ=Etc/UTC` | specify a timezone to use, see this [list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List). |
| `-e SKIP_INIT=` | Set to 1 to Skip initializing the container. This is for debug usage only! |
| `-e PASSWORD=password` | Optional web gui password, if `PASSWORD` or `HASHED_PASSWORD` is not provided, there will be no auth. |
| `-e HASHED_PASSWORD=` | Optional web gui password, overrides `PASSWORD`, instructions on how to create it is below. |
| `-e SUDO_PASSWORD=password` | If this optional variable is set, user will have sudo access in the code-server terminal with the specified password. |
| `-e SUDO_PASSWORD_HASH=` | Optionally set sudo password via hash (takes priority over `SUDO_PASSWORD` var). Format is `$type$salt$hashed`. |
| `-e PROXY_DOMAIN=code-server.my.domain` | If this optional variable is set, this domain will be proxied for subdomain proxying. See [Documentation](https://github.com/cdr/code-server/blob/master/docs/FAQ.md#sub-domains) |
| `-e DEFAULT_WORKSPACE=/config/workspace` | If this optional variable is set, code-server will open this directory by default |
| `-v /config` | Contains all relevant configuration files. |
