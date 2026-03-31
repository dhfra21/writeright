class ChildProfile {
  final String id;
  final String name;
  final int age;
  final String? avatarEmoji;

  const ChildProfile({
    required this.id,
    required this.name,
    required this.age,
    this.avatarEmoji,
  });

  factory ChildProfile.fromJson(Map<String, dynamic> json) {
    return ChildProfile(
      id: json['id'] as String,
      name: json['child_name'] as String,
      age: (json['age'] as num?)?.toInt() ?? 5,
      avatarEmoji: json['avatar_url'] as String?,
    );
  }
}
