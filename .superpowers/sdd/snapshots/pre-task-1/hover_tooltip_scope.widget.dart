import 'package:flutter/material.dart';

/// Coordinates parent and nested hover tooltips so the parent stays open while
/// the pointer moves between the parent panel, nested triggers, and nested panels.
class HoverTooltipScope extends StatefulWidget {
  final Widget child;

  const HoverTooltipScope({super.key, required this.child});

  static HoverTooltipScopeState? maybeOf(BuildContext context) {
    return context
        .findAncestorStateOfType<HoverTooltipScopeState>();
  }

  @override
  State<HoverTooltipScope> createState() => HoverTooltipScopeState();
}

class HoverTooltipScopeState extends State<HoverTooltipScope> {
  int _retainCount = 0;
  String? _activeNestedId;
  final Map<String, VoidCallback> _nestedDismissHandlers = {};

  bool get isRetained => _retainCount > 0;

  String? get activeNestedId => _activeNestedId;

  void retain() {
    if (!mounted) return;
    setState(() => _retainCount++);
  }

  void release() {
    if (_retainCount <= 0) return;
    _retainCount--;
    if (mounted) setState(() {});
  }

  /// Releases retention without requiring an active [BuildContext] lookup.
  void releaseFromDispose() {
    if (_retainCount <= 0) return;
    _retainCount--;
  }

  /// Clears nested active state without requiring an active [BuildContext] lookup.
  void clearNestedActiveFromDispose(String id) {
    if (_activeNestedId != id) return;
    _activeNestedId = null;
    _nestedDismissHandlers.remove(id);
  }

  /// Activates [id] and dismisses any other nested tooltip in this scope.
  void requestNestedActive(String id, VoidCallback onDismiss) {
    if (_activeNestedId != null && _activeNestedId != id) {
      _nestedDismissHandlers[_activeNestedId]?.call();
    }
    _activeNestedId = id;
    _nestedDismissHandlers[id] = onDismiss;
    setState(() {});
  }

  void clearNestedActive(String id) {
    if (_activeNestedId != id) return;
    _activeNestedId = null;
    _nestedDismissHandlers.remove(id);
    setState(() {});
  }

  void dismissNested(String id) {
    _nestedDismissHandlers[id]?.call();
  }

  @override
  Widget build(BuildContext context) {
    // Build the inherited data HERE so setState() in retain/release/
    // requestNestedActive recreates it with fresh values. Previously this
    // returned widget.child and the data was built by a separate Builder in
    // HoverTooltipScopeHost; because that Builder was an identical child
    // widget across rebuilds, Flutter's identical-child optimization skipped
    // it, leaving isRetained/activeNestedId permanently stale — so parent
    // tooltips never saw nested retention and tore down their message subtree,
    // disposing the just-opened nested panel.
    return HoverTooltipScopeData(
      isRetained: isRetained,
      activeNestedId: activeNestedId,
      child: widget.child,
    );
  }
}

/// Inherited signal so [HoverLazyRichTooltip] rebuilds when retention changes.
class HoverTooltipScopeData extends InheritedWidget {
  final bool isRetained;
  final String? activeNestedId;

  const HoverTooltipScopeData({
    super.key,
    required this.isRetained,
    required this.activeNestedId,
    required super.child,
  });

  static HoverTooltipScopeData? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<HoverTooltipScopeData>();
  }

  @override
  bool updateShouldNotify(HoverTooltipScopeData oldWidget) {
    return isRetained != oldWidget.isRetained ||
        activeNestedId != oldWidget.activeNestedId;
  }
}

/// Wraps [HoverTooltipScope], which now exposes retention/active-nested state
/// to descendants via [HoverTooltipScopeData] directly from its [State.build].
class HoverTooltipScopeHost extends StatelessWidget {
  final Widget child;

  const HoverTooltipScopeHost({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return HoverTooltipScope(child: child);
  }
}

/// Identifiers for nested tooltips inside the today-payment report panel.
abstract final class HoverTooltipNestedIds {
  static const withdraw = 'withdraw-request-report';
  static const deposit = 'deposit-request-report';
}
