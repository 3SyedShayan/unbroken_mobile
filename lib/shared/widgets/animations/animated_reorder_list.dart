import 'package:flutter/material.dart';

class AnimatedReorderList<T> extends StatefulWidget {
  final List<T> items;
  final Object Function(T item) itemKey;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? separator;
  final double separatorHeight;
  final Duration duration;
  final Curve curve;

  const AnimatedReorderList({
    super.key,
    required this.items,
    required this.itemKey,
    required this.itemBuilder,
    this.separator,
    this.separatorHeight = 12.0,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeInOutCubic,
  });

  @override
  State<AnimatedReorderList<T>> createState() => _AnimatedReorderListState<T>();
}

class _AnimatedReorderListState<T> extends State<AnimatedReorderList<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  List<Object> _previousKeys = [];
  final Map<Object, double> _currentDeltas = {};
  final Map<Object, GlobalKey> _itemGlobalKeys = {};
  double _measuredStride = 82.0;

  @override
  void initState() {
    super.initState();
    _previousKeys = widget.items.map(widget.itemKey).toList();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);

    WidgetsBinding.instance.addPostFrameCallback((_) => _measureStride());
  }

  void _measureStride() {
    if (!mounted) return;
    for (final key in _itemGlobalKeys.values) {
      final box = key.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize && box.size.height > 10) {
        _measuredStride = box.size.height + widget.separatorHeight;
        break;
      }
    }
  }

  @override
  void didUpdateWidget(AnimatedReorderList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldKeys = _previousKeys;
    final newKeys = widget.items.map(widget.itemKey).toList();

    if (!_areKeysIdentical(oldKeys, newKeys)) {
      final isStillRunning = _controller.isAnimating;
      final currentProgress = isStillRunning ? (1.0 - _animation.value) : 0.0;

      final newDeltas = <Object, double>{};
      var hasMovement = false;

      for (var newIdx = 0; newIdx < newKeys.length; newIdx++) {
        final key = newKeys[newIdx];
        final oldIdx = oldKeys.indexOf(key);

        if (oldIdx != -1 && oldIdx != newIdx) {
          final indexDifference = oldIdx - newIdx;
          final targetDelta = indexDifference * _measuredStride;
          final residual = isStillRunning ? ((_currentDeltas[key] ?? 0.0) * currentProgress) : 0.0;
          newDeltas[key] = targetDelta + residual;
          hasMovement = true;
        } else if (isStillRunning && _currentDeltas.containsKey(key)) {
          final residual = (_currentDeltas[key] ?? 0.0) * currentProgress;
          if (residual.abs() > 0.5) {
            newDeltas[key] = residual;
            hasMovement = true;
          }
        }
      }

      _currentDeltas
        ..clear()
        ..addAll(newDeltas);
      _previousKeys = List<Object>.from(newKeys);

      if (hasMovement) {
        _controller.forward(from: 0.0);
      } else {
        _controller.value = 1.0;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _measureStride());
  }

  bool _areKeysIdentical(List<Object> a, List<Object> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final progress = (1.0 - _animation.value);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < widget.items.length; i++) ...[
              if (i > 0 && widget.separator != null) widget.separator!,
              _buildItem(widget.items[i], i, progress),
            ],
          ],
        );
      },
    );
  }

  Widget _buildItem(T item, int index, double progress) {
    final key = widget.itemKey(item);
    final delta = _currentDeltas[key] ?? 0.0;
    final dy = delta * progress;

    final gKey = _itemGlobalKeys.putIfAbsent(key, GlobalKey.new);

    final child = KeyedSubtree(
      key: gKey,
      child: widget.itemBuilder(context, item, index),
    );

    if (dy.abs() < 0.1) {
      return child;
    }

    return Transform.translate(
      offset: Offset(0.0, dy),
      child: child,
    );
  }
}
