---
inject: true
before: part
to: "lib/ui/screens/<%= h.changeCase.snake(name) %>/<%= h.changeCase.snake(name) %>.dart"
skip_if: unbroken_mobile/ui/widgets/core/loader/full_screen_loader.dart
---
import 'package:unbroken_mobile/ui/widgets/core/loader/full_screen_loader.dart';
