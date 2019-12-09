#!/bin/sh

MAX=50

dart generate-dart.dart 0 ${MAX} flutter_project/lib/main%i.dart

function compile() {
  local N=$1
  pushd flutter_project
  echo $N methods
  flutter clean > /dev/null
  flutter build ios --release -t lib/main${N}.dart >../build${N}.log 2>&1
  ls -al build/ios/iphoneos/Runner.app/Frameworks/App.framework/App
  lipo build/ios/iphoneos/Runner.app/Frameworks/App.framework/App -thin arm64 -output App-ARM64.${N}
  ls -al App-ARM64.${N}
  # flutter build aot --release -t lib/main${N}.dart --target-platform ios --ios-arch arm64 --extra-gen-snapshot-options=--print-snapshot-sizes,--print-snapshot-sizes-verbose,--obfuscate,--write-v8-snapshot-profile-to=main${N}.snapshot.json >>../build${N}.log 2>&1
  echo
  popd
}

for i in $(seq 0 ${MAX}); do
  compile $i
done
