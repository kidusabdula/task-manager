class Task {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final bool isHighPriority;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.isHighPriority,
  });

  Task copyWith({String? title, String? description, DateTime? date, bool? isHighPriority}) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      isHighPriority: isHighPriority ?? this.isHighPriority,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'date': date.toIso8601String(),
        'isHighPriority': isHighPriority,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        date: DateTime.parse(json['date']),
        isHighPriority: json['isHighPriority'],
      );
}
