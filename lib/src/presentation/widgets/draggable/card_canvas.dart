import 'package:flutter/material.dart';
import 'draggable_card.dart';
import '../../theme/app_colors.dart';

/// Widget contenedor para tarjetas arrastrables
class CardCanvas extends StatefulWidget {
  final List<Widget> children;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final bool allowOverflow;
  final Function(String cardId)? onCardTap;
  final Function(String cardId)? onCardDoubleTap;
  final Function(String cardId, Offset position)? onCardPositionChanged;
  final Function(String cardId)? onCardDragStart;
  final Function(String cardId)? onCardDragEnd;

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
    for (int i = 0; i < widget.children.length; i++) {
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
  Widget build(BuildContext context) {
    return Container(
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
            onPositionChanged: (id, pos) => _handleCardPositionChanged(id, pos),
            onDragStart: (id) => _handleCardDragStart(id),
            onDragEnd: (id) => _handleCardDragEnd(id),
            child: child,
          );
        }).toList(),
      ),
    );
  }

  /// Obtiene la posición actual de una tarjeta específica
  Offset? getCardPosition(String cardId) {
    return _cardPositions[cardId];
  }

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
      for (int i = 0; i < widget.children.length; i++) {
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
      for (int i = 0; i < widget.children.length; i++) {
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
      for (int i = 0; i < widget.children.length; i++) {
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
      for (int i = 0; i < widget.children.length; i++) {
        final cardId = 'card_$i';
        _cardPositions[cardId] = Offset(centerX, startY + (i * 220.0));
      }
    });
  }
}

/// Widget de conveniencia para crear un canvas de tarjetas fácilmente
class DraggableCardCanvas extends StatelessWidget {
  final List<Widget> cards;
  final Function(String cardId)? onCardTap;
  final Function(String cardId)? onCardDoubleTap;
  final Color? backgroundColor;

  const DraggableCardCanvas({
    super.key,
    required this.cards,
    this.onCardTap,
    this.onCardDoubleTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CardCanvas(
      backgroundColor: backgroundColor,
      onCardTap: onCardTap,
      onCardDoubleTap: onCardDoubleTap,
      children: cards,
    );
  }
}
