import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hanigold_admin/src/widget/hover_floating_panel.widget.dart';
import 'package:hanigold_admin/src/widget/hover_lazy_rich_tooltip.widget.dart';
import 'package:hanigold_admin/src/widget/hover_tooltip_scope.widget.dart';

const Duration kNestedPanelShowDelay = Duration(milliseconds: 100);
const Duration kNestedPanelHideDelay = Duration(milliseconds: 400);
const double kNestedPanelBridgeGap = 12;
const double kNestedPanelDefaultMaxHeight = 420;

enum _Side { start, end, above, below }

/// Scope-coordinated overlay sub-panel for nested hovers inside a parent tooltip.
///
/// Uses global positioning (not [CompositedTransformFollower]) so the panel can
/// render in the root overlay while the trigger lives inside a parent tooltip.
class HoverNestedPanel<T> extends StatefulWidget {
  final String nestedId;
  final Widget child;
  final double panelWidth;
  final double panelMaxHeight;
  final HoverLoadCallback<T> loadData;
  final Widget Function(BuildContext context, AsyncSnapshot<T?> snapshot)
  panelBuilder;
  final VoidCallback? onHide;

  const HoverNestedPanel({
    super.key,
    required this.nestedId,
    required this.child,
    required this.panelWidth,
    required this.loadData,
    required this.panelBuilder,
    this.panelMaxHeight = kNestedPanelDefaultMaxHeight,
    this.onHide,
  });

  @override
  State<HoverNestedPanel<T>> createState() => HoverNestedPanelState<T>();
}

class HoverNestedPanelState<T> extends State<HoverNestedPanel<T>>
    with SingleTickerProviderStateMixin {
  final GlobalKey _targetKey = GlobalKey();

  OverlayEntry? _overlayEntry;
  Timer? _showTimer;
  Timer? _hideTimer;
  Future<T?>? _future;
  bool _isHoveringTarget = false;
  bool _isHoveringOverlay = false;
  bool _hasRetainedScope = false;
  HoverTooltipScopeState? _scope;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  _Side _side = _Side.start;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: kHoverPanelAnimationDuration,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scope = HoverTooltipScope.maybeOf(context);
    HoverTooltipScopeData.maybeOf(context);
  }

  @override
  void dispose() {
    _showTimer?.cancel();
    _hideTimer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;
    _releaseScope(fromDispose: true);
    _animationController.dispose();
    super.dispose();
  }

  void reload({bool forceRefresh = false}) {
    _future = widget.loadData(forceRefresh: forceRefresh);
    _overlayEntry?.markNeedsBuild();
    _cancelHide();
  }

  void hidePanel() => _removeOverlay();

  void _cancelHide() {
    _hideTimer?.cancel();
    _hideTimer = null;
  }

  void _scheduleHide() {
    _cancelHide();
    _hideTimer = Timer(kNestedPanelHideDelay, () {
      if (!_isHoveringTarget && !_isHoveringOverlay && mounted) {
        _removeOverlay();
      }
    });
  }

  // The overlay wraps the entire trigger+bridge+panel area in a SINGLE
  // MouseRegion. Moving anywhere inside it fires onHover (never onExit); only
  // leaving the whole area fires onExit. This is local hit-testing, so it is
  // immune to the app's UI scaling (responsive_framework / ZoomWrapper).
  void _onOverlayPointerDown(PointerDownEvent _) {
    _cancelHide();
    _isHoveringOverlay = true;
  }

  void _onOverlayEnter(PointerEnterEvent _) {
    _cancelHide();
    _isHoveringOverlay = true;
  }

  void _onOverlayHover(PointerHoverEvent _) {
    _cancelHide();
    _isHoveringOverlay = true;
  }

  void _onOverlayExit(PointerExitEvent _) {
    _isHoveringOverlay = false;
    _scheduleHide();
  }

  void _retainScope() {
    if (_hasRetainedScope) return;
    final scope = _scope;
    if (scope == null) return;
    _hasRetainedScope = true;
    scope.requestNestedActive(widget.nestedId, hidePanel);
    scope.retain();
  }

  void _releaseScope({bool fromDispose = false}) {
    if (!_hasRetainedScope) return;
    final scope = _scope;
    if (scope == null) return;
    _hasRetainedScope = false;
    if (fromDispose) {
      scope.releaseFromDispose();
      scope.clearNestedActiveFromDispose(widget.nestedId);
    } else if (scope.mounted) {
      scope.release();
      scope.clearNestedActive(widget.nestedId);
    } else {
      scope.releaseFromDispose();
      scope.clearNestedActiveFromDispose(widget.nestedId);
    }
  }

  void _onTargetEnter(PointerEnterEvent _) {
    _isHoveringTarget = true;
    _cancelHide();
    _showTimer?.cancel();
    _showTimer = Timer(kNestedPanelShowDelay, () {
      if (_isHoveringTarget && mounted) _showOverlay();
    });
  }

  void _onTargetExit(PointerExitEvent _) {
    _isHoveringTarget = false;
    _showTimer?.cancel();
    // Once the overlay is shown it covers (occludes) the trigger, so this exit
    // fires once at open time — closing is then governed solely by the
    // overlay's single MouseRegion onExit. If the overlay never opened,
    // cancelling the show timer above is enough; there is nothing to hide.
  }

  RenderBox? get _targetBox =>
      _targetKey.currentContext?.findRenderObject() as RenderBox?;

  _Side _resolveSide(BuildContext overlayContext) {
    final box = _targetBox;
    if (box == null || !box.hasSize) return _Side.start;

    final screen = MediaQuery.sizeOf(overlayContext);
    final padding = MediaQuery.paddingOf(overlayContext);
    final leaderTL = box.localToGlobal(Offset.zero);
    final leaderSize = box.size;
    final panelWidth = widget.panelWidth;
    final panelHeight = widget.panelMaxHeight;

    final spaceStart = leaderTL.dx - padding.left;
    final spaceEnd =
        screen.width - padding.right - leaderTL.dx - leaderSize.width;
    final spaceAbove = leaderTL.dy - padding.top;
    final spaceBelow =
        screen.height - padding.bottom - leaderTL.dy - leaderSize.height;

    if (spaceStart >= panelWidth + kNestedPanelBridgeGap) return _Side.start;
    if (spaceEnd >= panelWidth + kNestedPanelBridgeGap) return _Side.end;
    if (spaceAbove >= panelHeight + kNestedPanelBridgeGap) return _Side.above;
    if (spaceBelow >= panelHeight + kNestedPanelBridgeGap) return _Side.below;
    return spaceAbove >= spaceBelow ? _Side.above : _Side.below;
  }

  Rect _computePanelRect(BuildContext overlayContext) {
    final box = _targetBox;
    final screen = MediaQuery.sizeOf(overlayContext);
    final padding = MediaQuery.paddingOf(overlayContext);

    if (box == null || !box.hasSize) {
      return Rect.fromLTWH(padding.left, padding.top, widget.panelWidth, 200);
    }

    final leaderTL = box.localToGlobal(Offset.zero);
    final leaderSize = box.size;
    final panelWidth = widget.panelWidth;
    final panelHeight = widget.panelMaxHeight;
    final gap = kNestedPanelBridgeGap;

    double left;
    double top;

    switch (_side) {
      case _Side.start:
        left = leaderTL.dx - panelWidth - gap;
        top = leaderTL.dy + leaderSize.height / 2 - panelHeight / 2;
      case _Side.end:
        left = leaderTL.dx + leaderSize.width + gap;
        top = leaderTL.dy + leaderSize.height / 2 - panelHeight / 2;
      case _Side.above:
        left = leaderTL.dx + leaderSize.width / 2 - panelWidth / 2;
        top = leaderTL.dy - panelHeight - gap;
      case _Side.below:
        left = leaderTL.dx + leaderSize.width / 2 - panelWidth / 2;
        top = leaderTL.dy + leaderSize.height + gap;
    }

    left = left.clamp(
      padding.left,
      screen.width - padding.right - panelWidth,
    );
    top = top.clamp(
      padding.top,
      screen.height - padding.bottom - panelHeight,
    );

    return Rect.fromLTWH(left, top, panelWidth, panelHeight);
  }

  Rect _computeBridgeRect(Rect panelRect, Rect leaderRect) {
    final gap = kNestedPanelBridgeGap;
    switch (_side) {
      case _Side.start:
        return Rect.fromLTWH(
          panelRect.right,
          leaderRect.top,
          gap,
          leaderRect.height,
        );
      case _Side.end:
        return Rect.fromLTWH(
          leaderRect.right,
          leaderRect.top,
          gap,
          leaderRect.height,
        );
      case _Side.above:
        return Rect.fromLTWH(
          leaderRect.left,
          panelRect.bottom,
          leaderRect.width,
          gap,
        );
      case _Side.below:
        return Rect.fromLTWH(
          leaderRect.left,
          leaderRect.bottom,
          leaderRect.width,
          gap,
        );
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    final box = _targetBox;
    if (box == null || !box.hasSize) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_isHoveringTarget && mounted && _overlayEntry == null) {
          _showOverlay();
        }
      });
      return;
    }

    _future ??= widget.loadData(forceRefresh: false);
    _retainScope();

    // The panel only opens while the pointer is on the trigger, and the
    // overlay's contiguous hover region covers the trigger. So the pointer is
    // definitionally inside the overlay region at open time. Assert it here
    // instead of waiting for the OS mouse tracker to dispatch an enter event
    // for a region appearing under a stationary pointer — that dispatch is
    // unreliable and caused the panel to close right after opening.
    _isHoveringOverlay = true;

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        _side = _resolveSide(overlayContext);
        final box = _targetBox;
        if (box == null || !box.hasSize) return const SizedBox.shrink();

        final leaderRect = Rect.fromPoints(
          box.localToGlobal(Offset.zero),
          box.localToGlobal(
            Offset(box.size.width, box.size.height),
          ),
        );
        final panelRect = _computePanelRect(overlayContext);
        final bridgeRect = _computeBridgeRect(panelRect, leaderRect);
        // Contiguous hover region: trigger + bridge + panel, so there is no
        // dead zone anywhere between the icon and the panel. Because this
        // overlay covers the trigger, the trigger's own MouseRegion is
        // occluded once the panel is shown; from that point the overlay's
        // MouseRegion is the single source of truth (see _showOverlay, which
        // asserts _isHoveringOverlay=true on open to avoid depending on a
        // cross-overlay enter/exit race).
        final hoverRect = panelRect
            .expandToInclude(bridgeRect)
            .expandToInclude(leaderRect);

        return Stack(
          children: [
            Positioned.fromRect(
              rect: hoverRect,
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: _onOverlayPointerDown,
                onPointerSignal: (event) {
                  if (event is PointerScrollEvent) {
                    _cancelHide();
                    _isHoveringOverlay = true;
                  }
                },
                child: MouseRegion(
                  onEnter: _onOverlayEnter,
                  onHover: _onOverlayHover,
                  onExit: _onOverlayExit,
                  hitTestBehavior: HitTestBehavior.opaque,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: bridgeRect.left - hoverRect.left,
                        top: bridgeRect.top - hoverRect.top,
                        width: bridgeRect.width,
                        height: bridgeRect.height,
                        child: const SizedBox.shrink(),
                      ),
                      Positioned(
                        left: panelRect.left - hoverRect.left,
                        top: panelRect.top - hoverRect.top,
                        width: panelRect.width,
                        height: panelRect.height,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            alignment: _alignmentForSide(_side),
                            child: Material(
                              color: Colors.transparent,
                              child: SizedBox(
                                width: panelRect.width,
                                height: panelRect.height,
                                child: FutureBuilder<T?>(
                                  future: _future,
                                  builder: widget.panelBuilder,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    _animationController.forward(from: 0);
  }

  Alignment _alignmentForSide(_Side side) {
    return switch (side) {
      _Side.start => Alignment.centerRight,
      _Side.end => Alignment.centerLeft,
      _Side.above => Alignment.bottomCenter,
      _Side.below => Alignment.topCenter,
    };
  }

  void _removeOverlay({bool notify = true, bool fromDispose = false}) {
    _showTimer?.cancel();
    _cancelHide();
    _isHoveringOverlay = false;
    _isHoveringTarget = false;

    final entry = _overlayEntry;
    _overlayEntry = null;
    _releaseScope(fromDispose: fromDispose);
    if (entry == null) return;
    entry.remove();
    if (notify && !fromDispose) widget.onHide?.call();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _targetKey,
      child: MouseRegion(
        onEnter: _onTargetEnter,
        onExit: _onTargetExit,
        cursor: SystemMouseCursors.click,
        child: widget.child,
      ),
    );
  }
}
