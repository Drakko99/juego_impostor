class WordItem {
  final int? id;
  final String text;
  final int categoryId;

  WordItem({
    this.id,
    required this.text,
    required this.categoryId,
  });

  factory WordItem.fromMap(Map<String, dynamic> map) {
    return WordItem(
      id: map['id'] as int?,
      text: map['text'] as String,
      categoryId: map['category_id'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'category_id': categoryId,
    };
  }
}
