#!/bin/bash

# rename-ext-sh install script

## use
# bash ./install.sh

PREFIX='/usr/local/'

git clone \
  https://github.com/dym-sh/rename-ext-sh.git \
  $PREFIX/src/rename-ext-sh/

chmod +x $PREFIX/src/rename-ext-sh/rename-ext.sh

ln -s $PREFIX/src/rename-ext-sh/rename-ext.sh \
      $PREFIX/bin/rename-ext
