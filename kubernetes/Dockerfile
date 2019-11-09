FROM ubuntu:16.04
LABEL maintainer="openvidu@gmail.com"

# Install main components
RUN apt-get update && apt-get install --yes \
    --no-install-recommends \
    openjdk-8-jre \
    supervisor \
    jq \
    coturn \
    redis-server \
    software-properties-common \
    gnupg \
    curl \
    apt-transport-https \
    pwgen

# Installing kubectl
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && apt-get install -y kubectl

RUN mkdir -p /opt/openvidu/recordings
RUN mkdir -p /opt/openvidu/cluster/kubernetes
COPY ./openvidu_drop.sh /opt/openvidu/cluster/kubernetes
COPY ./openvidu_launch_kms.sh /opt/openvidu/cluster/kubernetes
COPY ./openvidu_autodiscover.sh /opt/openvidu/cluster/kubernetes
COPY ./entrypoint.sh /usr/local/bin
COPY ./supervisor.conf /etc/supervisor/conf.d/openvidu.conf
COPY ./openvidu-server.sh /usr/local/bin/openvidu-server.sh

CMD /usr/local/bin/entrypoint.sh