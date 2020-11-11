FROM golang:1.12-alpine3.10 AS build
COPY . /usr/local/src
WORKDIR /usr/local/src
RUN apk --no-cache add build-base && make

FROM centos:latest

##
# ---------- env settings ----------
##
# --build-arg timezone=Asia/Shanghai
ARG timezone

ENV TIMEZONE=${timezone:-"Asia/Shanghai"} \
    COMPOSER_VERSION=1.9.0 \
    APP_ENV=prod

RUN yum -y update \
install -y git yum-utils device-mapper-persistent-data

RUN yum-config-manager \
        --add-repo \
        https://mirrors.ustc.edu.cn/docker-ce/linux/centos/docker-ce.repo \
sudo sed -i 's/download.docker.com/mirrors.ustc.edu.cn\/docker-ce/g' /etc/yum.repos.d/docker-ce.repo \
sudo yum install docker-ce --nobest -y \
sudo systemctl enable docker \
sudo systemctl start docker \
sudo curl -L https://github.com/docker/compose/releases/download/1.26.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose \
sudo chmod +x /usr/local/bin/docker-compose \
sudo mkdir -p /etc/docker \
sudo tee /etc/docker/daemon.json <<-'EOF' { "registry-mirrors": ["https://7ta50vdn.mirror.aliyuncs.com"] } EOF \
sudo systemctl daemon-reload \
sudo systemctl restart docker

WORKDIR /syncd
COPY --from=build /usr/local/src/output /syncd

EXPOSE 8878
CMD [ "/syncd/bin/syncd" ]
