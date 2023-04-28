#!/bin/sh

TCL_INSTALL_DIR=${TCL_INSTALL_DIR:-"/usr/local"}

autoconf
./configure --enable-gcc --prefix="$TCL_INSTALL_DIR"
make
make install
