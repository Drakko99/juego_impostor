class Category {
  final int? id;
  final String name;
  final bool enabled;
  final bool isCustom;
  final bool isAdult;

  Category({
    this.id,
    required this.name,
    this.enabled = true,
    this.isCustom = false,
    this.isAdult = false,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      enabled: (map['enabled'] as int) == 1,
      isCustom: (map['is_custom'] as int) == 1,
      isAdult: (map['is_adult'] as int?) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'enabled': enabled ? 1 : 0,
      'is_custom': isCustom ? 1 : 0,
      'is_adult': isAdult ? 1 : 0,
    };
  }
}