// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

final template1 = r"""
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

<implementation>

void main() {
  <interface>
  runApp(const Center(child: Text('Hello, world!', textDirection: TextDirection.ltr)));
}
""";

final template2 = r"""
func1_<suffix>();
func2_<suffix>();
func3_<suffix>();
""";

final template3 = r"""
@pragma('vm:never-inline')
Widget func1_<suffix>() {
 return Text('<suffix>');
}

@pragma('vm:never-inline')
Widget func2_<suffix>() {
 return Text('<suffix>');
}

@pragma('vm:never-inline')
Widget func3_<suffix>() {
 return Column(children: <Widget>[
   Text('<suffix>'),
   Text('<suffix>'),
   Text('<suffix>'),
   Icon(Icons.add),
 ],);
}
""";

String render(String template, Map<String, String> substitutions) {
  return template.replaceAllMapped(RegExp(r"<(\w+)>"), (m) {
    return substitutions[m[1]] ?? "";
  });
}

void main(List<String> args) {
  final min = int.parse(args[0]);
  final max = int.parse(args[1]);
  final fileTemplate = args[2];

  for (var N = min; N <= max; N++) {
    final result = (render(template1, {
      'interface': List.generate(N, (i) => render(template2, {"suffix": "$i"})).join('\n'),
      'implementation': List.generate(N, (i) => render(template3, {"suffix": "$i"})).join('\n'),
    }));
    File(fileTemplate.replaceAll('%i', N.toString())).writeAsStringSync(result);
  }
}