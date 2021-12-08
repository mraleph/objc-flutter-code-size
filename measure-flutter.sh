#!/bin/sh

# Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

set -e

MAX=$1

dart generate-dart.dart 0 ${MAX} flutter_project/lib/main%i.dart

function compile() {
  local NAME=$1
  local N=$2
  local GEN_SNAPSHOT_OPTIONS=$3
  pushd flutter_project
  echo $N methods
  flutter clean > /dev/null
  flutter build ios --release -t lib/main${N}.dart \
          --extra-gen-snapshot-options=$GEN_SNAPSHOT_OPTIONS >>../build${N}-$NAME.log 2>&1
  lipo build/ios/Release-iphoneos/App.framework/App -thin arm64 -output App-ARM64-$NAME.${N}
  ls -al App-ARM64-$NAME.${N}
  echo
  popd
}

for i in $(seq 0 ${MAX}); do
  compile default $i --print-snapshot-sizes
  compile sizeopt $i --print-snapshot-sizes,--obfuscate,--dwarf-stack-traces,--strip
done
