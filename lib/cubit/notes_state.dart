import '../models/note.dart';

class NotesState {
  NotesState({required List<Note> notes, this.editingNoteId})
    : notes = List.unmodifiable(notes);

  final List<Note> notes;
  final int? editingNoteId;
  bool get isEditing => editingNoteId != null;

  NotesState copyWith({
    List<Note>? notes,
    int? editingNoteId,
    bool clearEditing = false,
  }) => NotesState(
    notes: notes ?? this.notes,
    editingNoteId: clearEditing ? null : editingNoteId ?? this.editingNoteId,
  );
}
