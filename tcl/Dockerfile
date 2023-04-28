FROM ubuntu:10.04

RUN sed s/archive/old-releases/g /etc/apt/sources.list > /tmp/sources.list
RUN mv /tmp/sources.list /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y build-essential autoconf curl

COPY entrypoint.sh /usr/local/bin/