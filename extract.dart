// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Extracts Mach-O section sizes from the binaries.

import 'dart:async';
import 'dart:io';

Future<int> totalSectionSize(String file) async {
  final result = await Process.run('objdump', ['-macho', '-all-headers', file]);
  final lines = result.stdout.split('\n');
  final sections = lines
      .skipWhile((l) => !l.startsWith('Sections:'))
      .skip(2)
      .takeWhile((l) => !l.startsWith('SYMBOL TABLE:'))
      .toList(growable: false);
  final whitespace = RegExp(r'\s+');

  var totalSize = 0;
  for (var s in sections) {
    final info = s.trim().split(whitespace).where((s) => !s.isEmpty).toList();
    if (info.isEmpty) continue;
    final size = int.parse(info[2], radix: 16);
    totalSize += size;
  }
  return totalSize;
}

class FileInfo {
  final int fileSize;
  final int totalSectionSize;
  FileInfo(this.fileSize, this.totalSectionSize);

  toString() => '$fileSize,$totalSectionSize';

  FileInfo operator-(FileInfo other) {
    return FileInfo(this.fileSize - other.fileSize, this.totalSectionSize - other.totalSectionSize);
  }
}

Future<FileInfo> getSizes(String fileName) async {
  final fileSize = (await File(fileName).stat()).size;
  final sectionsSize = await totalSectionSize(fileName);
  return FileInfo(fileSize, sectionsSize);
}

void main(List<String> args) async {
  final N = int.parse(args.first);
  Future<List<FileInfo>> collectInfo(String pattern) async {
    return Stream.fromIterable(
            List.generate(N+1, (i) => pattern.replaceAll('%i', i.toString())))
        .asyncMap(getSizes)
        .toList();
  }

  final objcInfo = await collectInfo('objc/test%i');
  final flutterInfoDefault = await
      collectInfo('flutter_project/App-ARM64-default.%i');
  final flutterInfoSizeopt = await
      collectInfo('flutter_project/App-ARM64-sizeopt.%i');

  for (var i = 0; i <= N; i++) {
    print('$i,${objcInfo[i]},${flutterInfoDefault[i]},${flutterInfoSizeopt[i]}');
  }

  print('''
| # added copies  | ObjC Mach-O growth | ObjC Sections growth | Flutter Default Mach-O growth | Flutter Default Sections growth | Flutter SizeOpt Mach-O growth | Flutter SizeOpt Sections growth |
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
''');
  for (var i = 1; i <= N; i++) {
    final objc = objcInfo[i]-objcInfo[i-1];
    final flutterDefault = flutterInfoDefault[i]-flutterInfoDefault[i-1];
    final flutterSizeopt = flutterInfoSizeopt[i]-flutterInfoSizeopt[i-1];
    print('|$i|${objc.toString().replaceAll(',', '|')}|'
          '${flutterDefault.toString().replaceAll(',','|')}|'
          '${flutterSizeopt.toString().replaceAll(',','|')}|');
  }
}
