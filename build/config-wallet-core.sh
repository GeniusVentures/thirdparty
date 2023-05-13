#/bin/bash

pushd $1
mkdir -p build/local/bin
mkdir -p build/local/include
mkdir -p build/local/lib
if [ ! -f src/Generated/CoinInfoData.cpp ]; then
  tools/generate-files
fi
popd