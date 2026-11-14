import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:unbroken_mobile/core/lifecycle/sign_out_cleanup_registry.dart';
import 'package:unbroken_mobile/shared/widgets/feedback/app_snackbars.dart';

/// Registers app-wide Provider services that must exist before any route.
class AppCoreBinding {
  const AppCoreBinding._();

  /// Core service providers mounted above [MaterialApp] in [MainMobileApp].
  static List<SingleChildWidget> get providers => [
    Provider<SignOutCleanupRegistry>.value(value: SignOutCleanupRegistry.ins),
    ChangeNotifierProvider<SnackbarService>.value(
      value: SnackbarService.instance,
    ),
  ];
}

