import 'package:equatable/equatable.dart';

import '../../../domain/entities/trade_note.dart';

class JournalState extends Equatable {
  const JournalState({
    required this.notes,
    required this.isLoading,
    required this.isSubmitting,
    this.errorMessage,
  });

  const JournalState.initial()
    : this(notes: const [], isLoading: true, isSubmitting: false);

  final List<TradeNote> notes;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;

  JournalState copyWith({
    List<TradeNote>? notes,
    bool? isLoading,
    bool? isSubmitting,
    bool clearError = false,
    String? errorMessage,
  }) => JournalState(
    notes: notes ?? this.notes,
    isLoading: isLoading ?? this.isLoading,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [notes, isLoading, isSubmitting, errorMessage];
}
