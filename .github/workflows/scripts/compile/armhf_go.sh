#!/bin/bash
cd /tmp
mkdir compile_dist
# get latest verson of golang
GO_RELEASE=$(curl -sX GET https://go.dev/VERSION?m=text)
wget https://go.dev/dl/${GO_RELEASE}.src.tar.gz
tar -zxf ${GO_RELEASE}.src.tar.gz
# start build
cd /tmp/go/src
chmod +x make.bash
GOROOT_FINAL=/usr/local GOOS=linux GOARCH=arm GOARM=7 GOBIN="/home/abc/go/bin" ./make.bash
cd /tmp/go
mv bin/linux_arm/* bin/
# remove unnessary files
rmdir bin/linux_arm/
rm -rf pkg/linux_amd64/ pkg/tool/linux_amd64/
# Re-enter compile dist dir
cd /tmp
# tar and ready to pass artifact
tar -czf go.tar.gz go