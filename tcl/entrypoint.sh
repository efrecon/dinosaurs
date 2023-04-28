#!/bin/sh

set -e

TCL_INSTALL_DIR=${TCL_INSTALL_DIR:-"${1:-"/usr/local"}"}

cd unix
autoconf
./configure --enable-gcc --prefix="$TCL_INSTALL_DIR"
make
make install-binaries install-libraries
make distclean
