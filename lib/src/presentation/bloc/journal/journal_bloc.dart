import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/logger.dart';
import '../../../domain/entities/trade_note.dart';
import '../../../domain/use_cases/create_trade_note_usecase.dart';
import '../../../domain/use_cases/delete_trade_note_usecase.dart';
import '../../../domain/use_cases/get_trade_notes_usecase.dart';
import '../../../domain/use_cases/update_trade_note_usecase.dart';
import 'journal_event.dart';
import 'journal_state.dart';

class JournalBloc extends Bloc<JournalEvent, JournalState> {
  JournalBloc({
    required GetTradeNotesUseCase getTradeNotesUseCase,
    required CreateTradeNoteUseCase createTradeNoteUseCase,
    required UpdateTradeNoteUseCase updateTradeNoteUseCase,
    required DeleteTradeNoteUseCase deleteTradeNoteUseCase,
  }) : _getTradeNotesUseCase = getTradeNotesUseCase,
       _createTradeNoteUseCase = createTradeNoteUseCase,
       _updateTradeNoteUseCase = updateTradeNoteUseCase,
       _deleteTradeNoteUseCase = deleteTradeNoteUseCase,
       super(const JournalState.initial()) {
    on<LoadJournalNotes>(_onLoadNotes);
    on<AddJournalNote>(_onAddNote);
    on<UpdateJournalNote>(_onUpdateNote);
    on<DeleteJournalNote>(_onDeleteNote);
  }

  final GetTradeNotesUseCase _getTradeNotesUseCase;
  final CreateTradeNoteUseCase _createTradeNoteUseCase;
  final UpdateTradeNoteUseCase _updateTradeNoteUseCase;
  final DeleteTradeNoteUseCase _deleteTradeNoteUseCase;

  Future<void> _onLoadNotes(
    LoadJournalNotes event,
    Emitter<JournalState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final notes = await _getTradeNotesUseCase.execute(
        GetTradeNotesParams(
          userId: event.userId,
          symbol: event.symbol,
          limit: event.limit,
        ),
      );

      // Ordenar notas por fecha de entrada (más recientes primero)
      final sortedNotes = List<TradeNote>.from(notes)
        ..sort((a, b) => b.entryAt.compareTo(a.entryAt));

      emit(state.copyWith(notes: sortedNotes, isLoading: false, clearError: true));
    } catch (error, stackTrace) {
      AppLogger.error('Failed to load journal notes', error, stackTrace);
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'No se pudieron cargar las anotaciones',
        ),
      );
    }
  }

  Future<void> _onAddNote(
    AddJournalNote event,
    Emitter<JournalState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));

    try {
      final newNote = await _createTradeNoteUseCase.execute(
        CreateTradeNoteParams(
          symbol: event.symbol,
          entryPrice: event.entryPrice,
          entryAt: event.entryAt,
          side: event.side,
          exitPrice: event.exitPrice,
          exitAt: event.exitAt,
          size: event.size,
          notes: event.notes,
          tags: event.tags,
          alertId: event.alertId,
          userId: event.userId,
        ),
      );

      // Agregar nueva nota y ordenar por fecha de entrada (más recientes primero)
      final updatedNotes = [newNote, ...state.notes]
        ..sort((a, b) => b.entryAt.compareTo(a.entryAt));

      emit(
        state.copyWith(
          notes: updatedNotes,
          isSubmitting: false,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      AppLogger.error('Failed to add journal note', error, stackTrace);
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'No se pudo guardar la anotación',
        ),
      );
    }
  }

  Future<void> _onUpdateNote(
    UpdateJournalNote event,
    Emitter<JournalState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));

    try {
      final updated = await _updateTradeNoteUseCase.execute(
        UpdateTradeNoteParams(
          id: event.id,
          symbol: event.symbol,
          side: event.side,
          entryPrice: event.entryPrice,
          entryAt: event.entryAt,
          exitPrice: event.exitPrice,
          exitAt: event.exitAt,
          size: event.size,
          notes: event.notes,
          tags: event.tags,
          alertId: event.alertId,
          userId: event.userId,
        ),
      );

      if (updated == null) {
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage: 'La anotación ya no existe',
          ),
        );
        return;
      }

      // Actualizar nota y reordenar por fecha de entrada (más recientes primero)
      final updatedNotes = state.notes
          .map((note) => note.id == updated.id ? updated : note)
          .toList()
        ..sort((a, b) => b.entryAt.compareTo(a.entryAt));

      emit(
        state.copyWith(
          notes: updatedNotes,
          isSubmitting: false,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      AppLogger.error('Failed to update journal note', error, stackTrace);
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'No se pudo actualizar la anotación',
        ),
      );
    }
  }

  Future<void> _onDeleteNote(
    DeleteJournalNote event,
    Emitter<JournalState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));

    try {
      final deleted = await _deleteTradeNoteUseCase.execute(
        DeleteTradeNoteParams(id: event.id, userId: event.userId),
      );

      if (!deleted) {
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage: 'La anotación ya no existe',
          ),
        );
        return;
      }

      final updatedNotes = state.notes
          .where((note) => note.id != event.id)
          .toList(growable: false);

      emit(
        state.copyWith(
          notes: updatedNotes,
          isSubmitting: false,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      AppLogger.error('Failed to delete journal note', error, stackTrace);
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'No se pudo eliminar la anotación',
        ),
      );
    }
  }

  List<TradeNote> get currentNotes => state.notes;
}
