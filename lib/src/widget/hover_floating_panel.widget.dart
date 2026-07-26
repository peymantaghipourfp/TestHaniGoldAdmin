import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hanigold_admin/src/config/const/app_color.dart';
import 'package:hanigold_admin/src/config/const/app_text_style.dart';

const double kHoverPanelBorderRadius = 18;
const Duration kHoverPanelAnimationDuration = Duration(milliseconds: 200);

/// Glassmorphism shell shared by hover report panels.
class FloatingPanelShell extends StatelessWidget {
  final double width;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const FloatingPanelShell({
    super.key,
    required this.width,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(kHoverPanelBorderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: width,
          padding: padding,
          decoration: BoxDecoration(
            color: AppColor.secondaryColor.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(kHoverPanelBorderRadius),
            border: Border.all(
              color: AppColor.textColor.withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Status card for loading / error / empty states inside hover panels.
class FloatingPanelStatusCard extends StatelessWidget {
  final double width;
  final Widget child;

  const FloatingPanelStatusCard({
    super.key,
    required this.width,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingPanelShell(width: width, child: child);
  }
}

/// Scrollable list for tooltip overlays — uses an explicit [ScrollController]
/// because [PrimaryScrollController] is unavailable inside tooltip overlays.
class TooltipScrollableList extends StatefulWidget {
  final double maxHeight;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double separatorHeight;

  const TooltipScrollableList({
    super.key,
    required this.maxHeight,
    required this.itemCount,
    required this.itemBuilder,
    this.separatorHeight = 8,
  });

  @override
  State<TooltipScrollableList> createState() => _TooltipScrollableListState();
}

class _TooltipScrollableListState extends State<TooltipScrollableList> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : widget.maxHeight;
        final listHeight = maxHeight.clamp(0.0, widget.maxHeight);

        return SizedBox(
          height: listHeight,
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: ListView.separated(
              controller: _scrollController,
              primary: false,
              physics: const ClampingScrollPhysics(),
              itemCount: widget.itemCount,
              separatorBuilder: (_, __) =>
                  SizedBox(height: widget.separatorHeight),
              itemBuilder: widget.itemBuilder,
            ),
          ),
        );
      },
    );
  }
}

/// Pulsing skeleton placeholders for lazy-loaded hover panels.
class TooltipSkeletonList extends StatefulWidget {
  final double width;
  final int itemCount;
  final Color accentColor;

  const TooltipSkeletonList({
    super.key,
    required this.width,
    this.itemCount = 3,
    this.accentColor = AppColor.secondary2Color,
  });

  @override
  State<TooltipSkeletonList> createState() => _TooltipSkeletonListState();
}

class _TooltipSkeletonListState extends State<TooltipSkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingPanelShell(
      width: widget.width,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final opacity = 0.35 + (_controller.value * 0.35);
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _skeletonBox(height: 14, width: 160, opacity: opacity),
              const SizedBox(height: 12),
              _skeletonBox(height: 48, opacity: opacity),
              const SizedBox(height: 10),
              for (var i = 0; i < widget.itemCount; i++) ...[
                _skeletonBox(height: 72, opacity: opacity),
                if (i < widget.itemCount - 1) const SizedBox(height: 8),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _skeletonBox({
    required double height,
    double? width,
    required double opacity,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: widget.accentColor.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

/// Retry button row for error states.
class FloatingPanelRetryRow extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const FloatingPanelRetryRow({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          style: AppTextStyle.labelText.copyWith(fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: onRetry,
          child: Text(
            'تلاش مجدد',
            style: AppTextStyle.labelText.copyWith(
              fontSize: 12,
              color: AppColor.secondary3Color,
            ),
          ),
        ),
      ],
    );
  }
}
