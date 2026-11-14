import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/shared/widgets/headless/focus_handler.dart';

class Screen extends StatelessWidget {
  const Screen({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.keyboardHandler = false,
    this.resizeToAvoidBottomInset = false,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.scaffoldBackgroundColor,
    this.belowBuilders,
    this.overlayBuilders,
    this.initialFormValue,
    this.formKey,
    this.onBackPressed,
    this.canPop,
    this.appBar,
    this.bottomNavigationBar,
  });

  final Widget child;
  final EdgeInsets padding;
  final bool keyboardHandler;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? scaffoldBackgroundColor;
  final List<Widget>? belowBuilders; // listeners
  final List<Widget>? overlayBuilders; // builders
  final Map<String, dynamic>? initialFormValue;
  final GlobalKey<FormBuilderState>? formKey;
  final bool resizeToAvoidBottomInset;
  final void Function()? onBackPressed;
  final bool? canPop;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    App.init(context);

    var body = child;
    var onWillPop = onBackPressed;
    var canPopValue = canPop ?? true;

    if (formKey != null) {
      body = FormBuilder(
        key: formKey,
        initialValue: initialFormValue ?? {},
        child: body,
      );
    }

    if (keyboardHandler) {
      body = FocusHandler(child: body);
    }

    if (onWillPop != null || !canPopValue) {
      body = PopScope(
        canPop: canPopValue,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && onWillPop != null) {
            onWillPop();
          }
        },
        child: body,
      );
    }

    body = Padding(padding: padding, child: body);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarBrightness: Brightness.light, // for IOS
        statusBarIconBrightness: Brightness.dark, // for Android
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        backgroundColor: scaffoldBackgroundColor ?? AppTheme.c.background,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        appBar: appBar,
        bottomNavigationBar: bottomNavigationBar,
        body: Stack(
          fit: StackFit.expand,
          children: [
            ...?belowBuilders,
            Positioned.fill(child: body),
            ...?overlayBuilders,
          ],
        ),
      ),
    );
  }
}