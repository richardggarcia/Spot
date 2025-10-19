import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'draggable_card.dart';

/// Widget contenedor para tarjetas arrastrables
class CardCanvas extends StatefulWidget {

  const CardCanvas({
    super.key,
    required this.children,
    this.backgroundColor,
    this.padding,
    this.allowOverflow = true,
    this.onCardTap,
    this.onCardDoubleTap,
    this.onCardPositionChanged,
    this.onCardDragStart,
    this.onCardDragEnd,
  });
  final List<Widget> children;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final bool allowOverflow;
  final void Function(String cardId)? onCardTap;
  final void Function(String cardId)? onCardDoubleTap;
  final void Function(String cardId, Offset position)? onCardPositionChanged;
  final void Function(String cardId)? onCardDragStart;
  final void Function(String cardId)? onCardDragEnd;

  @override
  State<CardCanvas> createState() => _CardCanvasState();
}

class _CardCanvasState extends State<CardCanvas> {
  final Map<String, GlobalKey> _cardKeys = {};
  final Map<String, Offset> _cardPositions = {};

  @override
  void initState() {
    super.initState();
    _initializeCards();
  }

  void _initializeCards() {
    for (var i = 0; i < widget.children.length; i++) {
      final cardId = 'card_$i';
      _cardKeys[cardId] = GlobalKey();
      _cardPositions[cardId] = _getInitialPosition(i);
    }
  }

  Offset _getInitialPosition(int index) {
    // Organizar en cuadrícula si no hay posición guardada
    const cardWidth = 300.0;
    const cardHeight = 200.0;
    const spacing = 20.0;

    final columns =
        (MediaQuery.of(context).size.width - 100) ~/ (cardWidth + spacing);
    final row = index ~/ columns;
    final col = index % columns;

    return Offset(
      50.0 + col * (cardWidth + spacing),
      50.0 + row * (cardHeight + spacing),
    );
  }

  void _handleCardPositionChanged(String cardId, Offset position) {
    setState(() {
      _cardPositions[cardId] = position;
    });
    widget.onCardPositionChanged?.call(cardId, position);
  }

  void _handleCardTap(String cardId) {
    widget.onCardTap?.call(cardId);
  }

  void _handleCardDoubleTap(String cardId) {
    widget.onCardDoubleTap?.call(cardId);
  }

  void _handleCardDragStart(String cardId) {
    widget.onCardDragStart?.call(cardId);
  }

  void _handleCardDragEnd(String cardId) {
    widget.onCardDragEnd?.call(cardId);
  }

  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      height: double.infinity,
      color: widget.backgroundColor ?? AppColors.darkBackground,
      padding: widget.padding ?? const EdgeInsets.all(16),
      child: Stack(
        clipBehavior: widget.allowOverflow ? Clip.none : Clip.hardEdge,
        children: widget.children.asMap().entries.map((entry) {
          final index = entry.key;
          final child = entry.value;
          final cardId = 'card_$index';
          final initialPosition =
              _cardPositions[cardId] ?? _getInitialPosition(index);

          return DraggableCard(
            key: _cardKeys[cardId],
            cardId: cardId,
            initialPosition: initialPosition,
            onTap: () => _handleCardTap(cardId),
            onDoubleTap: () => _handleCardDoubleTap(cardId),
            onPositionChanged: _handleCardPositionChanged,
            onDragStart: _handleCardDragStart,
            onDragEnd: _handleCardDragEnd,
            child: child,
          );
        }).toList(),
      ),
    );

  /// Obtiene la posición actual de una tarjeta específica
  Offset? getCardPosition(String cardId) => _cardPositions[cardId];

  /// Establece la posición de una tarjeta específica
  void setCardPosition(String cardId, Offset position) {
    setState(() {
      _cardPositions[cardId] = position;
    });
  }

  /// Reorganiza todas las tarjetas en cuadrícula
  void reorganizeInGrid() {
    const cardWidth = 300.0;
    const cardHeight = 200.0;
    const spacing = 20.0;

    final columns =
        (MediaQuery.of(context).size.width - 100) ~/ (cardWidth + spacing);

    setState(() {
      for (var i = 0; i < widget.children.length; i++) {
        final cardId = 'card_$i';
        final row = i ~/ columns;
        final col = i % columns;

        _cardPositions[cardId] = Offset(
          50.0 + col * (cardWidth + spacing),
          50.0 + row * (cardHeight + spacing),
        );
      }
    });
  }

  /// Apila todas las tarjetas en el centro
  void stackInCenter() {
    final centerX = MediaQuery.of(context).size.width / 2 - 150;
    final centerY = MediaQuery.of(context).size.height / 2 - 100;

    setState(() {
      for (var i = 0; i < widget.children.length; i++) {
        final cardId = 'card_$i';
        _cardPositions[cardId] = Offset(
          centerX + (i * 10), // Ligero desplazamiento para ver todas
          centerY + (i * 10),
        );
      }
    });
  }

  /// Distribuye las tarjetas horizontalmente
  void distributeHorizontally() {
    final totalWidth =
        widget.children.length * 320.0; // 300px card + 20px spacing
    final startX = (MediaQuery.of(context).size.width - totalWidth) / 2;
    final centerY = MediaQuery.of(context).size.height / 2 - 100;

    setState(() {
      for (var i = 0; i < widget.children.length; i++) {
        final cardId = 'card_$i';
        _cardPositions[cardId] = Offset(startX + (i * 320.0), centerY);
      }
    });
  }

  /// Distribuye las tarjetas verticalmente
  void distributeVertically() {
    final totalHeight =
        widget.children.length * 220.0; // 200px card + 20px spacing
    final startY = (MediaQuery.of(context).size.height - totalHeight) / 2;
    final centerX = MediaQuery.of(context).size.width / 2 - 150;

    setState(() {
      for (var i = 0; i < widget.children.length; i++) {
        final cardId = 'card_$i';
        _cardPositions[cardId] = Offset(centerX, startY + (i * 220.0));
      }
    });
  }
}

/// Widget de conveniencia para crear un canvas de tarjetas fácilmente
class DraggableCardCanvas extends StatelessWidget {

  const DraggableCardCanvas({
    super.key,
    required this.cards,
    this.onCardTap,
    this.onCardDoubleTap,
    this.backgroundColor,
  });
  final List<Widget> cards;
  final void Function(String cardId)? onCardTap;
  final void Function(String cardId)? onCardDoubleTap;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) => CardCanvas(
      backgroundColor: backgroundColor,
      onCardTap: onCardTap,
      onCardDoubleTap: onCardDoubleTap,
      children: cards,
    );
}
