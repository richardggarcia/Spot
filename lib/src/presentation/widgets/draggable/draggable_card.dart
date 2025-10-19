import 'package:flutter/material.dart';
import '../../managers/card_position_manager.dart';
import '../../theme/app_colors.dart';

/// Widget base para tarjetas arrastrables con animaciones y persistencia
class DraggableCard extends StatefulWidget {

  const DraggableCard({
    super.key,
    required this.child,
    required this.cardId,
    this.initialPosition = Offset.zero,
    this.onTap,
    this.onDoubleTap,
    this.isDraggable = true,
    this.isResizable = false,
    this.initialSize,
    this.elevation = 4.0,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
    this.bringToFrontOnDrag = true,
    this.onPositionChanged,
    this.onDragStart,
    this.onDragEnd,
  });
  final Widget child;
  final String cardId;
  final Offset initialPosition;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final bool isDraggable;
  final bool isResizable;
  final Size? initialSize;
  final double elevation;
  final Duration animationDuration;
  final Curve animationCurve;
  final bool bringToFrontOnDrag;
  final void Function(String cardId, Offset position)? onPositionChanged;
  final void Function(String cardId)? onDragStart;
  final void Function(String cardId)? onDragEnd;

  @override
  State<DraggableCard> createState() => _DraggableCardState();
}

class _DraggableCardState extends State<DraggableCard>
    with TickerProviderStateMixin {
  Offset position = Offset.zero;
  Size size = const Size(300, 200);
  bool isDragging = false;
  bool isHovered = false;
  int zIndex = 0;

  late AnimationController _dragAnimationController;
  late AnimationController _hoverAnimationController;
  late Animation<double> _dragAnimation;
  late Animation<double> _hoverAnimation;

  @override
  void initState() {
    super.initState();
    _loadPosition();
    _loadSize();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _dragAnimationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _hoverAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _dragAnimation = Tween<double>(begin: 1, end: 1.05).animate(
      CurvedAnimation(
        parent: _dragAnimationController,
        curve: widget.animationCurve,
      ),
    );

    _hoverAnimation = Tween<double>(begin: 1, end: 1.02).animate(
      CurvedAnimation(
        parent: _hoverAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _loadPosition() async {
    final savedPosition = await CardPositionManager.getPosition(widget.cardId);
    if (savedPosition != null) {
      setState(() {
        position = savedPosition;
      });
    } else {
      setState(() {
        position = widget.initialPosition;
      });
    }
  }

  Future<void> _loadSize() async {
    if (widget.initialSize != null) {
      setState(() {
        size = widget.initialSize!;
      });
    }
  }

  Future<void> _savePosition() async {
    await CardPositionManager.savePosition(widget.cardId, position);
  }

  void _handleDragStart(DragStartDetails details) {
    if (!widget.isDraggable) return;

    setState(() {
      isDragging = true;
      if (widget.bringToFrontOnDrag) {
        zIndex = 1000; // Bring to front
      }
    });

    _dragAnimationController.forward();
    widget.onDragStart?.call(widget.cardId);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!widget.isDraggable) return;

    setState(() {
      position += details.delta;
    });

    widget.onPositionChanged?.call(widget.cardId, position);
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!widget.isDraggable) return;

    setState(() {
      isDragging = false;
      zIndex = 0; // Reset z-index
    });

    _dragAnimationController.reverse();
    _savePosition();
    widget.onDragEnd?.call(widget.cardId);
  }

  void _handleTap() {
    if (!isDragging) {
      widget.onTap?.call();
    }
  }

  void _handleDoubleTap() {
    if (!isDragging) {
      widget.onDoubleTap?.call();
    }
  }

  void _handleHover(bool isHovering) {
    if (isHovering != isHovered) {
      setState(() {
        isHovered = isHovering;
      });

      if (isHovering && !isDragging) {
        _hoverAnimationController.forward();
      } else {
        _hoverAnimationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) => Positioned(
      left: position.dx,
      top: position.dy,
      child: AnimatedBuilder(
        animation: Listenable.merge([_dragAnimation, _hoverAnimation]),
        builder: (context, child) {
          final scale = isDragging
              ? _dragAnimation.value
              : (isHovered ? _hoverAnimation.value : 1.0);

          final currentElevation = isDragging
              ? widget.elevation + 4
              : widget.elevation;

          return Transform.scale(
            scale: scale,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: isDragging ? 0.8 : 1.0,
              child: MouseRegion(
                onEnter: (_) => _handleHover(true),
                onExit: (_) => _handleHover(false),
                child: GestureDetector(
                  onTap: _handleTap,
                  onDoubleTap: _handleDoubleTap,
                  onPanStart: _handleDragStart,
                  onPanUpdate: _handleDragUpdate,
                  onPanEnd: _handleDragEnd,
                  child: AnimatedContainer(
                    duration: widget.animationDuration,
                    curve: widget.animationCurve,
                    width: size.width,
                    height: size.height,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(77),
                          blurRadius: currentElevation * 2,
                          offset: Offset(0, currentElevation),
                        ),
                        if (isDragging)
                          BoxShadow(
                            color: AppColors.darkAccentPrimary.withAlpha(51),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                      ],
                    ),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

  @override
  void dispose() {
    _dragAnimationController.dispose();
    _hoverAnimationController.dispose();
    super.dispose();
  }
}
