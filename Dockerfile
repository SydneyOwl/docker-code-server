FROM debian:11

# set version label
ARG CODE_RELEASE
ARG 
LABEL maintainer="MrOwl"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV HOME="/config"

RUN \
  echo "**** install runtime dependencies ****" && \
  apt-get update && \
  apt-get install -y \
    git \
    jq \
    libatomic1 \
    nano \
    net-tools \
    netcat \
    sudo \
    curl \
    wget \
    tar && \
  echo "**** install code-server ****" && \
  if [ -z ${CODE_RELEASE+x} ]; then \
    CODE_RELEASE=$(curl -sX GET https://api.github.com/repos/coder/code-server/releases/latest \
      | awk '/tag_name/{print $4;exit}' FS='[""]' | sed 's|^v||'); \
  fi && \
  mkdir -p /app/code-server && \
  curl -o \
    /tmp/code-server.tar.gz -L \
    "https://github.com/coder/code-server/releases/download/v${CODE_RELEASE}/code-server-${CODE_RELEASE}-linux-amd64.tar.gz" && \
  tar xf /tmp/code-server.tar.gz -C \
    /app/code-server --strip-components=1 && \
  echo "*** installing golang ***" && \
  wget https://golang.google.cn/dl/go1.18.9.linux-amd64.tar.gz -O /tmp/go1.18.9.linux-amd64.tar.gz && \
  tar -C /usr/local -zxvf /tmp/go1.18.9.linux-amd64.tar.gz && \
  echo "export PATH=$PATH:/usr/local/go/bin" >> /etc/profile && \
  /app/code-server/bin/code-server --install-extension golang.Go && \
  echo "**** clean up ****" && \
  apt-get clean && \
  rm -rf \
    /config/* \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 8443
ENTRYPOINT ["/bin/bash", "/etc/scripts/startup.sh"]
