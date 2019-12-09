import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

@pragma('vm:never-inline')
Widget func1_0() {
 return Text('0');
}

@pragma('vm:never-inline')
Widget func2_0() {
 return Text('0');
}

@pragma('vm:never-inline')
Widget func3_0() {
 return Column(children: [
   Text('0'),
   Text('0'),
   Text('0'),
   Icon(Icons.add),
 ],);
}


void main() {
  func1_0();
func2_0();
func3_0();

  runApp(const Center(child: Text('Hello, world!', textDirection: TextDirection.ltr)));
}
