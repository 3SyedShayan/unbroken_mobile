import 'package:flutter/material.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/features/core/goals/domain/goal_cadence.dart';
import 'package:unbroken_mobile/features/core/goals/models/goal_folder.dart';
import 'package:unbroken_mobile/features/core/goals/viewmodel/cubit.dart';
import 'package:unbroken_mobile/shared/widgets/core/buttons/button.dart';
import 'package:unbroken_mobile/shared/widgets/core/screen/screen.dart';

part 'widgets/_body.dart';
part 'widgets/_pickers.dart';

class FolderFormScreen extends StatelessWidget {
  final GoalFolder? folder;

  const FolderFormScreen({super.key, this.folder});

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return _Body(folder: folder);
  }
}
