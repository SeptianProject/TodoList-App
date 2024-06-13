class Todo {
  final String id;
  final String title;
  final String description;
  final String priority;
  final String dueDate;
  final String status;
  final String attachments;
  final List<String> tags;

  Todo(
      {required this.id,
      required this.title,
      required this.description,
      required this.priority,
      required this.dueDate,
      required this.status,
      required this.attachments,
      required this.tags});

  @override
  String toString() {
    return "id=$id,title=$title";
  }
}
