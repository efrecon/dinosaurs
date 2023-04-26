#!/bin/sh

autoconf
# TODO: fix prefix so we install to proper location
./configure --enable-gcc
make
make install
