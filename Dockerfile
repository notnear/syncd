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

RUN yum -y update
RUN yum install -y git yum-utils device-mapper-persistent-data lvm2 sudo wget

#RUN yum-config-manager   --add-repo   https://mirrors.ustc.edu.cn/docker-ce/linux/centos/docker-ce.repo
#RUN sed -i 's/download.docker.com/mirrors.ustc.edu.cn/docker-ce/g' /etc/yum.repos.d/docker-ce.repo
RUN wget -O /etc/yum.repos.d/docker-ce.repo https://download.docker.com/linux/centos/docker-ce.repo
RUN sed -i 's+download.docker.com+mirrors.tuna.tsinghua.edu.cn/docker-ce+' /etc/yum.repos.d/docker-ce.repo
RUN yum install -y docker-ce docker-ce-cli containerd.io
RUN curl -L https://github.com/docker/compose/releases/download/1.26.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose
RUN mkdir -p /etc/docker

WORKDIR /syncd
COPY --from=build /usr/local/src/output /syncd

EXPOSE 8878
CMD [ "/syncd/bin/syncd","systemctl enable docker","systemctl daemon-reload","systemctl restart docker" ]