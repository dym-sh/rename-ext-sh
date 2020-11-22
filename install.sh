#!/bin/bash

# rename-ext install script

## use
# bash ./install.sh

PREFIX='~/.local'

git clone --depth 1 \
  https://github.com/dym-sh/rename-ext.git \
  $PREFIX/src/rename-ext/

chmod +x $PREFIX/src/rename-ext/rename-ext.sh

ln -s $PREFIX/src/rename-ext/rename-ext.sh \
      $PREFIX/bin/rename-ext
