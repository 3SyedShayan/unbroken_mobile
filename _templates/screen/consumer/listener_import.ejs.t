---
inject: true
after: "import 'package:unbroken_mobile/utils/flash.dart';"
to: "lib/ui/screens/<%= h.changeCase.snake(name) %>/<%= h.changeCase.snake(name) %>.dart"
---
part 'listeners/_<%= h.changeCase.snake(arg.state) %>.dart';
