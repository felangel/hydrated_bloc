import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

ScrollController useScrollController({
  double initialScrollOffset = 0.0,
  bool keepScrollOffset = true,
  List<Object> keys,
}) =>
    Hook.use(
      _ScrollControllerHook(initialScrollOffset, keepScrollOffset, keys),
    );

class _ScrollControllerHook extends Hook<ScrollController> {
  final double initialScrollOffset;
  final bool keepScrollOffset;
  const _ScrollControllerHook(
    this.initialScrollOffset,
    this.keepScrollOffset, [
    List<Object> keys,
  ]) : super(keys: keys);

  @override
  _ScrollControllerHookState createState() {
    return _ScrollControllerHookState();
  }
}

class _ScrollControllerHookState
    extends HookState<ScrollController, _ScrollControllerHook> {
  ScrollController _scrollController;

  @override
  void initHook() {
    super.initHook();
    _scrollController = ScrollController(
      initialScrollOffset: hook.initialScrollOffset ?? 0.0,
      keepScrollOffset: hook.keepScrollOffset ?? true,
    );
  }

  @override
  ScrollController build(BuildContext context) => _scrollController;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
