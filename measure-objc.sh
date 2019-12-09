#!/bin/sh

# Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

MAX=50

dart generate-objc.dart 0 ${MAX} objc/test%i.m

function compile() {
  pushd objc
  local N=$1
  xcrun -sdk iphoneos clang -arch arm64 -miphoneos-version-min=6.0 -framework Foundation -framework UIKit -g -Oz test${N}.m -o test${N}
  strip -S test${N}
  file test${N}
  ls -al test${N}
  popd
}

for i in $(seq 0 ${MAX}); do
  compile $i
done


# ls -ltr objc/test? objc/test?? | awk '{echo $5}'
