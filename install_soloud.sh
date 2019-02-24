#!/usr/bin/env bash

SOLOUD_LIB_PATH=priv/lib/libsoloud_static.a
SOLOUD_DIRECTORY=jarikomppa-soloud-64dd662
SOLOUD_DOWNLOAD_URL=https://api.github.com/repos/jarikomppa/soloud/tarball/RELEASE_20181119
GENIE_DOWNLOAD_URL=https://github.com/bkaradzic/bx/raw/master/tools/bin/linux/genie

if [ -f $SOLOUD_LIB_PATH ]; then
   echo "All set! You are ready to use SoLoudEx."
else
  BASE_DIR=$(pwd)

  echo "Preparing..."
  mkdir -p $BASE_DIR/priv/lib

  echo "Retrieving SoLoud from GitHub..."
  wget -O soloud.tar.gz $SOLOUD_DOWNLOAD_URL

  echo "Unpacking..."
  tar -xzf soloud.tar.gz

  cd $BASE_DIR/$SOLOUD_DIRECTORY/build

  if [ "$TRAVIS" = "true" ]; then
    echo "Making adjustments for CI..."
    cat genie.lua | sed -e "s/WITH_ALSA = 1/WITH_ALSA = 0/" | sed -e "s/WITH_OSS = 1/WITH_OSS = 0/" > new_genie.lua
    mv new_genie.lua genie.lua
  fi

  echo "Fetching GENie from GitHub..."
  wget -O $BASE_DIR/$SOLOUD_DIRECTORY/build/genie $GENIE_DOWNLOAD_URL
  chmod +x genie

  echo "Generating Makefile..."
  ./genie gmake

  cd $BASE_DIR/$SOLOUD_DIRECTORY/build/gmake
  echo "Running Makefile..."
  make SoloudStatic

  cd $BASE_DIR/$SOLOUD_DIRECTORY
  echo "Cleaning up..."
  mv lib/libsoloud_static.a ../priv/lib/libsoloud_static.a

  cd $BASE_DIR
  rm -rf $SOLOUD_DIRECTORY
  rm soloud.tar.gz
fi
