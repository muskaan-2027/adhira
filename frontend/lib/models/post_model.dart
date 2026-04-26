class PostModel {
  final String id;
  final String content;
  final bool isAnonymous;
  final String distressLevel;
  final DateTime? createdAt;

  const PostModel({
    required this.id,
    required this.content,
    required this.isAnonymous,
    required this.distressLevel,
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['_id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      isAnonymous: json['isAnonymous'] == true,
      distressLevel: json['distressLevel']?.toString() ?? 'normal',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }
}
