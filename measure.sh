#!/bin/sh

N=$1

echo "Generating data for Flutter"
./measure-flutter.sh $N

echo "Generating data for Obj C"
./measure-objc.sh $N

dart extract.dart $N