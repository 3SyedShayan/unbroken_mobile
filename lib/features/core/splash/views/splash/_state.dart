part of 'splash.dart';

class _ScreenState extends ChangeNotifier {
  static _ScreenState s(BuildContext context, [bool listen = false]) =>
      Provider.of<_ScreenState>(context, listen: listen);

  _ScreenState(BuildContext context) {
    _init(context);
  }

  Future<void> _init(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (context.mounted) {
      AppRoutes.home.pushReplace(context);
    }
  }
}

