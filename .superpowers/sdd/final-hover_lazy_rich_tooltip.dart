import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hanigold_admin/src/widget/hover_tooltip_scope.widget.dart';

typedef HoverLoadCallback<T> = Future<T?> Function({bool forceRefresh});

const Duration kHoverTooltipHideDelay = Duration(milliseconds: 120);

/// Shared hover wrapper: [MouseRegion] + Flutter [Tooltip] + lazy [FutureBuilder].
///
/// Supports coordinated nested tooltips via [HoverTooltipScope] when [nestedId] is
/// set. Flutter handles viewport positioning, flip, margin clamping, and hover
/// bridge; this widget adds message-area tracking and hide-delay debouncing.
class HoverLazyRichTooltip<T> extends StatefulWidget {
  final Widget child;
  final HoverLoadCallback<T> loadData;
  final VoidCallback? onHoverEnd;
  final Widget Function(BuildContext context, AsyncSnapshot<T?> snapshot)
  messageBuilder;
  final Widget? waitingMessage;
  final bool preferBelow;
  final Duration showDuration;
  final double? messageMaxWidth;

  /// When set, this tooltip participates in [HoverTooltipScope] coordination.
  final String? nestedId;

  /// When true, pointer leave does not dismiss; only [HoverLazyRichTooltipState.forceDeactivate] closes.
  final bool stickyUntilDismissed;

  const HoverLazyRichTooltip({
    super.key,
    required this.child,
    required this.loadData,
    required this.messageBuilder,
    this.onHoverEnd,
    this.waitingMessage,
    this.preferBelow = false,
    this.showDuration = const Duration(seconds: 5),
    this.messageMaxWidth,
    this.nestedId,
    this.stickyUntilDismissed = false,
  });

  @override
  State<HoverLazyRichTooltip<T>> createState() =>
      HoverLazyRichTooltipState<T>();
}

class HoverLazyRichTooltipState<T> extends State<HoverLazyRichTooltip<T>> {
  final GlobalKey<TooltipState> _flutterTooltipKey = GlobalKey<TooltipState>();

  bool _isHovering = false;
  bool _isHoveringTarget = false;
  bool _isHoveringMessage = false;
  bool _hasRetainedScope = false;
  Future<T?>? _future;
  Timer? _hideTimer;
  HoverTooltipScopeState? _scope;

  bool get _scopeRetained =>
      HoverTooltipScopeData.maybeOf(context)?.isRetained ?? false;

  bool get _hasActiveNested =>
      widget.nestedId == null &&
          (HoverTooltipScopeData.maybeOf(context)?.activeNestedId != null);

  bool get _isActive {
    if (widget.stickyUntilDismissed && _isHovering) return true;
    if (widget.nestedId != null) {
      return _isHoveringTarget || _isHoveringMessage;
    }
    return _isHoveringTarget ||
        _isHoveringMessage ||
        _scopeRetained ||
        _hasActiveNested;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scope = HoverTooltipScope.maybeOf(context);
    // Rebuild when scope retention or active nested id changes.
    HoverTooltipScopeData.maybeOf(context);
    if (_isHovering && (_scopeRetained || _hasActiveNested)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _keepFlutterTooltipVisibleIfNeeded();
      });
    } else if (widget.nestedId == null &&
        _isHovering &&
        !_isHoveringTarget &&
        !_isHoveringMessage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_scopeRetained || _hasActiveNested) return;
        if (_isHoveringTarget || _isHoveringMessage) return;
        if (widget.stickyUntilDismissed && _isHovering) {
          _keepFlutterTooltipVisibleIfNeeded();
          return;
        }
        _scheduleHide();
      });
    }
  }

  void _keepFlutterTooltipVisibleIfNeeded() {
    if (!widget.stickyUntilDismissed &&
        !_scopeRetained &&
        !_hasActiveNested) {
      return;
    }
    _flutterTooltipKey.currentState?.ensureTooltipVisible();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _releaseScope(fromDispose: true);
    super.dispose();
  }

  void reload({bool forceRefresh = false}) {
    setState(() {
      _future = widget.loadData(forceRefresh: forceRefresh);
    });
  }

  void forceDeactivate() {
    _hideTimer?.cancel();
    _isHoveringTarget = false;
    _isHoveringMessage = false;
    _releaseScope();
    _deactivateIfIdle();
  }

  void _cancelHide() {
    _hideTimer?.cancel();
    _hideTimer = null;
  }

  void _scheduleHide() {
    _cancelHide();
    _hideTimer = Timer(kHoverTooltipHideDelay, () {
      _deactivateIfIdle();
    });
  }

  void _retainScope() {
    if (_hasRetainedScope || widget.nestedId == null) return;
    final scope = _scope;
    if (scope == null) return;
    _hasRetainedScope = true;
    scope.requestNestedActive(widget.nestedId!, forceDeactivate);
    scope.retain();
  }

  void _releaseScope({bool fromDispose = false}) {
    if (!_hasRetainedScope || widget.nestedId == null) return;
    final scope = _scope;
    if (scope == null) return;
    _hasRetainedScope = false;
    final nestedId = widget.nestedId!;

    if (fromDispose) {
      scope.releaseFromDispose();
      scope.clearNestedActiveFromDispose(nestedId);
      return;
    }

    if (scope.mounted) {
      scope.release();
      scope.clearNestedActive(nestedId);
    } else {
      scope.releaseFromDispose();
      scope.clearNestedActiveFromDispose(nestedId);
    }
  }

  void _deactivateIfIdle() {
    if (!mounted) return;

    final stillActive = widget.nestedId != null
        ? (_isHoveringTarget || _isHoveringMessage)
        : (_isHoveringTarget ||
        _isHoveringMessage ||
        _scopeRetained ||
        _hasActiveNested);

    if (stillActive) return;

    _releaseScope();
    if (_isHovering) {
      setState(() => _isHovering = false);
      widget.onHoverEnd?.call();
    }
  }

  void _activate() {
    _cancelHide();
    if (!_isHovering) {
      setState(() {
        _isHovering = true;
        _future ??= widget.loadData(forceRefresh: false);
      });
    } else {
      _future ??= widget.loadData(forceRefresh: false);
    }

    if (widget.nestedId != null &&
        (_isHoveringTarget || _isHoveringMessage)) {
      _retainScope();
    }
  }

  void _onTargetEnter(PointerEnterEvent _) {
    _isHoveringTarget = true;
    _activate();
  }

  void _onTargetExit(PointerExitEvent _) {
    _isHoveringTarget = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_isHoveringTarget || _isHoveringMessage) return;
      if (widget.stickyUntilDismissed && _isHovering) {
        _keepFlutterTooltipVisibleIfNeeded();
        return;
      }
      _scheduleHide();
    });
  }

  void _onMessageEnter(PointerEnterEvent _) {
    _isHoveringMessage = true;
    _cancelHide();
    if (!_isHovering) {
      _activate();
    }
  }

  void _onMessageExit(PointerExitEvent _) {
    _isHoveringMessage = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_isHoveringMessage || _isHoveringTarget) return;
      if (widget.stickyUntilDismissed && _isHovering) {
        _keepFlutterTooltipVisibleIfNeeded();
        return;
      }
      if (_scopeRetained || _hasActiveNested) {
        _keepFlutterTooltipVisibleIfNeeded();
        return;
      }
      _scheduleHide();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _onTargetEnter,
      onExit: _onTargetExit,
      child: Tooltip(
        key: _flutterTooltipKey,
        preferBelow: widget.preferBelow,
        showDuration: widget.showDuration,
        enableTapToDismiss: false,
        padding: EdgeInsets.zero,
        constraints: widget.messageMaxWidth != null
            ? BoxConstraints(maxWidth: widget.messageMaxWidth!)
            : const BoxConstraints(),
        richMessage: WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: MouseRegion(
            onEnter: _onMessageEnter,
            onExit: _onMessageExit,
            child: _isActive && _future != null
                ? FutureBuilder<T?>(
              future: _future,
              builder: widget.messageBuilder,
            )
                : widget.waitingMessage ??
                const SizedBox(
                  width: 1,
                  height: 1,
                ),
          ),
        ),
        child: widget.child,
      ),
    );
  }
}
