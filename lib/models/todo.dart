class Todo {
  final int id;
  final String title;
  final String? description;
  final bool finished;
  final DateTime dateCreated;
  final DateTime? dueDate;
  final DateTime? dateClosed;

  Todo({
    required this.id,
    required this.title,
    this.description,
    this.finished = false,
    required this.dateCreated,
    this.dueDate,
    this.dateClosed,
  });

  // copyWith function is for creating a new Todo instance with some fields modified
  Todo copyWith({
    int? id,
    String? title,
    String? description,
    bool? finished,
    DateTime? dateCreated,
    DateTime? dueDate,
    DateTime? dateClosed,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      finished: finished ?? this.finished,
      dateCreated: dateCreated ?? this.dateCreated,
      dueDate: dueDate ?? this.dueDate,
      dateClosed: dateClosed ?? this.dateClosed,
    );
  }

  // toMap function is for exporting Dart's data type to a standard format
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'finished': finished ? 1 : 0,
      'dateCreated': dateCreated.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'dateClosed': dateClosed?.toIso8601String(),
    };
  }

  // fromMap function is for importing standard format to Dart's data type
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String?,
      finished:
          map['finished'] ==
          1, //if the finished is 1 it's True but if it's not 1 it's False
      dateCreated: DateTime.parse(map['dateCreated'] as String),
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'] as String)
          : null,
      dateClosed: map['dateClosed'] != null
          ? DateTime.parse(map['dateClosed'] as String)
          : null,
    );
  }
}
