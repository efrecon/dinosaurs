FROM ubuntu:10.04

RUN sed s/archive/old-releases/g /etc/apt/sources.list > /tmp/sources.list && \
    mv /tmp/sources.list /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y build-essential autoconf

COPY entrypoint.sh /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]