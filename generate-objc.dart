// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

final template1 = r"""
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CustomView1 : UILabel

- (instancetype)initWithString:(NSString *)text;

@end

@interface CustomView2 : UIImageView

- (instancetype)initWithImageName:(NSString *)imageName;

@end

@implementation CustomView1

- (instancetype)initWithString:(NSString *)text {
    if (self = [super init]) {
        self.text = text;
    }

    return self;
}

@end

@implementation CustomView2

- (instancetype)initWithImageName:(NSString *)imageName
{
    if (self = [super init]) {
        self.image = [UIImage imageNamed:imageName];
    }

    return self;
}

@end

@interface ViewController : NSObject
<interface>
@end


@implementation ViewController
<implementation>



- (void)viewDidLoad {
    //[super viewDidLoad];
    <invocation>
    // Do any additional setup after loading the view, typically from a nib.
}

@end

int main() {
    return 0;
}

""";

final template4 = r"""
[self func1_<suffix>];
[self func2_<suffix>];
[self func3_<suffix>];
""";

final template2 = r"""
- (UIView *)func1_<suffix>;
- (UIView *)func2_<suffix>;
- (UIView *)func3_<suffix>;
""";

final template3 = r"""
- (UIView *)func1_<suffix> {
    return [[CustomView1 alloc] initWithString:@"<suffix>"];
}

- (UIView *)func2_<suffix> {
    return [[CustomView1 alloc] initWithString:@"<suffix>"];
}

- (UIView *)func3_<suffix> {
    return [[UIStackView alloc] initWithArrangedSubviews:@[[[CustomView1 alloc] initWithString:@"<suffix>"],
                                                           [[CustomView1 alloc] initWithString:@"<suffix>"],
                                                           [[CustomView1 alloc] initWithString:@"<suffix>"],
                                                           [[CustomView2 alloc] initWithImageName:@"add"]]];
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
    final result = render(template1, {
      'interface': List.generate(N, (i) => render(template2, {"suffix": "$i"})).join('\n'),
      'implementation': List.generate(N, (i) => render(template3, {"suffix": "$i"})).join('\n'),
    });
    File(fileTemplate.replaceAll('%i', N.toString())).writeAsStringSync(result);
  }
}