class Todo {
  final int id;
  final String title;
  final String? description;
  final bool finished;
  final DateTime dateTimeCreated;
  final DateTime? deadLine;
  final DateTime? dateTimeClosed;

  Todo({
    required this.id,
    required this.title,
    this.description,
    this.finished = false,
    required this.dateTimeCreated,
    this.deadLine,
    this.dateTimeClosed,
  });

  // copyWith function is for creating a new Todo instance with some fields modified
  Todo copyWith({
    int? id,
    String? title,
    String? description,
    bool? finished,
    DateTime? dateTimeCreated,
    DateTime? deadLine,
    DateTime? dateTimeClosed,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      finished: finished ?? this.finished,
      dateTimeCreated: dateTimeCreated ?? this.dateTimeCreated,
      deadLine: deadLine ?? this.deadLine,
      dateTimeClosed: dateTimeClosed ?? this.dateTimeClosed,
    );
  }

  // toMap function is for exporting Dart's data type to a standard format
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'finished': finished ? 1 : 0,
      'dateTimeCreated': dateTimeCreated.toIso8601String(),
      'deadLine': deadLine?.toIso8601String(),
      'dateTimeClosed': dateTimeClosed?.toIso8601String(),
    };
    if (id != 0) {
      map['id'] = id;
    }
    return map;
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
      dateTimeCreated: DateTime.parse(map['dateTimeCreated'] as String),
      deadLine: map['deadLine'] != null
          ? DateTime.parse(map['deadLine'] as String)
          : null,
      dateTimeClosed: map['dateTimeClosed'] != null
          ? DateTime.parse(map['dateTimeClosed'] as String)
          : null,
    );
  }
}
