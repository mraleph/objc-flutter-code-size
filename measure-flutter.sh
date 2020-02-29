#!/bin/sh

# Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

MAX=$1

dart generate-dart.dart 0 ${MAX} flutter_project/lib/main%i.dart

function compile() {
  local N=$1
  pushd flutter_project
  echo $N methods
  flutter clean > /dev/null
  flutter build aot --release -t lib/main${N}.dart \
          --target-platform ios                    \
          --ios-arch arm64                         \
          --extra-gen-snapshot-options=--print-snapshot-sizes,--obfuscate,--dwarf-stack-traces,--strip >>../build${N}.log 2>&1
  ls -al build/aot/App.framework/App
  lipo build/aot/App.framework/App -thin arm64 -output App-ARM64.${N}
  ls -al App-ARM64.${N}
  echo
  popd
}

for i in $(seq 0 ${MAX}); do
  compile $i
done
