FROM ubuntu:10.04

RUN sed s/archive/old-releases/g /etc/apt/sources.list > /tmp/sources.list && \
    mv /tmp/sources.list /etc/apt/sources.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -yy && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        build-essential autoconf gcc-multilib g++-multilib libc6-dev-i386 libtool

COPY lib/*.sh /usr/local/share/
COPY jpeg/docker/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]