---
inject: true
before: part
to: "lib/ui/screens/<%= h.changeCase.snake(name) %>/<%= h.changeCase.snake(name) %>.dart"
skip_if: <%= h.changeCase.snake(arg.bloc) %>/cubit.dart
---
import 'package:unbroken_mobile/blocs/<%= h.changeCase.snake(arg.bloc) %>/cubit.dart';
