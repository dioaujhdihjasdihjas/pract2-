class Note {
  const Note({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;
}
