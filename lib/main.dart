import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/notes_cubit.dart';
import 'cubit/notes_state.dart';
import 'models/note.dart';

void main() {
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF202A35);
    const teal = Color(0xFF197C72);

    return MaterialApp(
      title: 'Мои заметки',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F7F4),
        colorScheme: ColorScheme.fromSeed(
          seedColor: teal,
          primary: teal,
          onSurface: ink,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF6F7F4),
          foregroundColor: ink,
          centerTitle: false,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8F9F7),
          hintStyle: TextStyle(color: ink.withValues(alpha: 0.42)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE8ECE8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: teal, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFB3261E)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFB3261E), width: 1.5),
          ),
        ),
      ),
      home: BlocProvider(create: (_) => NotesCubit(), child: const NotesPage()),
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final cubit = context.read<NotesCubit>();
    final wasEditing = cubit.state.isEditing;
    final text = _textController.text.trim();
    if (wasEditing) {
      cubit.updateNote(text);
    } else {
      cubit.addNote(text);
    }
    _resetForm();
    _showMessage(wasEditing ? 'Изменения сохранены' : 'Заметка добавлена');
  }

  void _startEditing(Note note) {
    context.read<NotesCubit>().startEditing(note);
    _textController.text = note.text;
  }

  void _resetForm() {
    _textController.clear();
    _formKey.currentState?.reset();
  }

  void _deleteNote(Note note) {
    final cubit = context.read<NotesCubit>();
    final wasEditingDeletedNote = cubit.state.editingNoteId == note.id;
    final deleted = cubit.deleteNote(note.id);
    if (deleted == null) return;
    if (wasEditingDeletedNote) _resetForm();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Заметка удалена'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Отменить',
            onPressed: () => context.read<NotesCubit>().restoreNote(
              deleted.note,
              deleted.index,
            ),
          ),
        ),
      );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotesCubit, NotesState>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFDFF2EC),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.sticky_note_2_rounded,
                  color: Color(0xFF197C72),
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              const Text(
                'Мои заметки',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        body: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  _buildWelcomeHeader(state),
                  const SizedBox(height: 22),
                  _buildEditor(state),
                  const SizedBox(height: 28),
                  _buildNotesHeading(state),
                  const SizedBox(height: 12),
                  if (state.notes.isEmpty)
                    _buildEmptyState()
                  else
                    ...state.notes.map(_buildNoteCard),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(NotesState state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Записывайте важное',
                style: TextStyle(
                  color: Color(0xFF202A35),
                  fontSize: 25,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Все ваши мысли — в одном месте',
                style: TextStyle(
                  color: const Color(0xFF202A35).withValues(alpha: 0.62),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFE8ECE8)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.notes_rounded,
                size: 17,
                color: Color(0xFF197C72),
              ),
              const SizedBox(width: 6),
              Text(
                '${state.notes.length}',
                style: const TextStyle(
                  color: Color(0xFF202A35),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditor(NotesState state) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: const Color(0xFFE8ECE8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A202A35),
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  state.isEditing
                      ? Icons.edit_note_rounded
                      : Icons.add_circle_outline,
                  size: 20,
                  color: const Color(0xFF197C72),
                ),
                const SizedBox(width: 8),
                Text(
                  state.isEditing ? 'Редактирование' : 'Новая заметка',
                  style: const TextStyle(
                    color: Color(0xFF202A35),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _textController,
              minLines: 3,
              maxLines: 5,
              maxLength: 1000,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Напишите, что важно запомнить…',
                counterStyle: TextStyle(color: Color(0xFF7A858C), fontSize: 11),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Введите текст заметки';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (state.isEditing) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        context.read<NotesCubit>().cancelEditing();
                        _resetForm();
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        foregroundColor: const Color(0xFF42505A),
                        side: const BorderSide(color: Color(0xFFDDE4DF)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text('Отмена'),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  flex: state.isEditing ? 2 : 1,
                  child: FilledButton.icon(
                    onPressed: _saveNote,
                    icon: Icon(
                      state.isEditing
                          ? Icons.check_rounded
                          : Icons.save_rounded,
                    ),
                    label: const Text('Сохранить'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: const Color(0xFF197C72),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesHeading(NotesState state) {
    final count = state.notes.length;
    final label = switch (count % 10) {
      1 when count % 100 != 11 => 'заметка',
      2 || 3 || 4 when count % 100 < 12 || count % 100 > 14 => 'заметки',
      _ => 'заметок',
    };

    return Row(
      children: [
        const Expanded(
          child: Text(
            'Список заметок',
            style: TextStyle(
              color: Color(0xFF202A35),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          '$count $label',
          style: const TextStyle(color: Color(0xFF7A858C), fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF4EF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.edit_note_rounded,
              color: Color(0xFF197C72),
              size: 27,
            ),
          ),
          const SizedBox(height: 13),
          const Text(
            'Здесь пока пусто',
            style: TextStyle(
              color: Color(0xFF202A35),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Добавьте первую заметку — она появится в этом списке.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF202A35).withValues(alpha: 0.62),
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
    return Container(
      key: ValueKey(note.id),
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.fromLTRB(16, 15, 10, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE8ECE8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.text,
                  style: const TextStyle(
                    color: Color(0xFF28343C),
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: Color(0xFF8A9599),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _formatDate(note.updatedAt),
                      style: const TextStyle(
                        color: Color(0xFF8A9599),
                        fontSize: 11,
                      ),
                    ),
                    if (note.updatedAt != note.createdAt) ...[
                      const SizedBox(width: 5),
                      const Text(
                        '· изменено',
                        style: TextStyle(
                          color: Color(0xFF8A9599),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Column(
            children: [
              IconButton(
                tooltip: 'Редактировать',
                onPressed: () => _startEditing(note),
                icon: const Icon(Icons.edit_outlined, size: 19),
                color: const Color(0xFF197C72),
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                tooltip: 'Удалить',
                onPressed: () => _deleteNote(note),
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                color: const Color(0xFF9A6C65),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(date.day)}.${twoDigits(date.month)}.${date.year}, '
        '${twoDigits(date.hour)}:${twoDigits(date.minute)}';
  }
}
