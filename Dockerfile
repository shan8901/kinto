FROM golang:alpine AS builder
RUN apk update && apk add --no-cache git bash curl
WORKDIR /go/src/v2ray.com/core
RUN git clone --progress https://github.com/v2fly/v2ray-core.git . && \
    bash ./release/user-package.sh nosource noconf codename=$(git describe --tags) buildname=docker-fly abpathtgz=/tmp/v2ray.tgz

FROM alpine
ENV CONFIG=https://gist.githubusercontent.com/shan8901/5f20ce0e2a810e03e03868b5b1ee8341/raw/8b4f28e5535bcd29af78c7a7c378d955d82b11f1/config.json
COPY --from=builder /tmp/v2ray.tgz /tmp
RUN apk update && apk add --no-cache tor ca-certificates && \
    tar xvfz /tmp/v2ray.tgz -C /usr/bin && \
    rm -rf /tmp/v2ray.tgz
    
CMD nohup tor & \
    v2ray -config $CONFIG
