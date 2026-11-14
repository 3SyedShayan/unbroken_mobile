---
inject: true
before: part
to: "lib/ui/screens/<%= h.changeCase.snake(name) %>/<%= h.changeCase.snake(name) %>.dart"
skip_if: unbroken_mobile/utils/flash.dart
---
import 'package:unbroken_mobile/utils/flash.dart';
