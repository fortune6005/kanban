
class Task {
  String title;
  int status;
  int priority;
  bool rewarded;

  // status: 0=未着手, 1=作業中, 2=完了
  // priority: 0=高, 1=中, 2=低
  // rewarded: 植物の成長に反映済みかどうか

  Task(
    this.title, [
    this.status = 0,
    this.priority = 1,
    this.rewarded = false,
  ]);

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'status': status,
      'priority': priority,
      'rewarded': rewarded,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      json['title'] as String? ?? '',
      json['status'] as int? ?? 0,
      json['priority'] as int? ?? 1,
      json['rewarded'] as bool? ?? false,
    );
  }
}
