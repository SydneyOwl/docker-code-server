FROM debian:11

# set version label
ARG CODE_RELEASE
ARG GO_RELEASE

ARG TARGETARCH
LABEL maintainer="MrOwl"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV HOME="/config"
COPY go.tar.gz /tmp
RUN \
  case ${TARGETARCH} in \
  "arm") TARGETARCH=armv7l && GOARCH=src ;; \
  *) GOARCH="linux-"$TARGETARCH ;; \
  esac && \
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
    tar && \
  echo "**** install code-server ****" && \
  if [ -z ${CODE_RELEASE+x} ]; then \
  CODE_RELEASE=$(curl -sX GET https://api.github.com/repos/coder/code-server/releases/latest \
    | awk '/tag_name/{print $4;exit}' FS='[""]' | sed 's|^v||'); \
  fi && \
  mkdir -p /app/code-server && \
  curl -o \
    /tmp/code-server.tar.gz -L \
    "https://github.com/coder/code-server/releases/download/v${CODE_RELEASE}/code-server-${CODE_RELEASE}-linux-${TARGETARCH}.tar.gz" && \
  tar xf /tmp/code-server.tar.gz -C \
    /app/code-server --strip-components=1 && \
  echo "*** installing golang ***" && \
  if [ -z ${GO_RELEASE+x} ]; then \
    GO_RELEASE=$(curl -sX GET https://go.dev/VERSION?m=text); \
  fi && \
  if [ ${GOARCH} != "src" ];then \
    rm -rf /tmp/go.tar.gz && \
    curl -o /tmp/go.tar.gz -L https://go.dev/dl/${GO_RELEASE}.${GOARCH}.tar.gz ; \
  fi && \
  tar -C /usr/local -zxf /tmp/go.tar.gz && \
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
