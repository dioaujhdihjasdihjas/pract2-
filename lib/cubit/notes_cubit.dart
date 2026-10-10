import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/note.dart';
import 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  NotesCubit() : super(NotesState(notes: const []));

  int _nextId = 0;

  void addNote(String text) {
    final now = DateTime.now();
    emit(
      state.copyWith(
        notes: [
          Note(id: _nextId++, text: text, createdAt: now, updatedAt: now),
          ...state.notes,
        ],
        clearEditing: true,
      ),
    );
  }

  void startEditing(Note note) => emit(state.copyWith(editingNoteId: note.id));

  void updateNote(String text) {
    final id = state.editingNoteId;
    if (id == null) return;
    final now = DateTime.now();
    final notes = state.notes
        .map(
          (note) => note.id == id
              ? Note(
                  id: note.id,
                  text: text,
                  createdAt: note.createdAt,
                  updatedAt: now,
                )
              : note,
        )
        .toList();
    emit(state.copyWith(notes: notes, clearEditing: true));
  }

  void cancelEditing() => emit(state.copyWith(clearEditing: true));

  ({Note note, int index})? deleteNote(int id) {
    final index = state.notes.indexWhere((note) => note.id == id);
    if (index < 0) return null;
    final note = state.notes[index];
    final editingDeleted = state.editingNoteId == id;
    emit(
      state.copyWith(
        notes: [...state.notes]..removeAt(index),
        clearEditing: editingDeleted,
      ),
    );
    return (note: note, index: index);
  }

  void restoreNote(Note note, int index) {
    final notes = [...state.notes];
    notes.insert(index.clamp(0, notes.length).toInt(), note);
    emit(state.copyWith(notes: notes));
  }
}
