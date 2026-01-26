class Cinema {
  final String id;
  final String name;

  Cinema({
    required this.id,
    required this.name,
  });

  factory Cinema.fromFirestore(Map<String, dynamic> data, String id) {
    return Cinema(
      id: id,
      name: data['name'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
    };
  }
}
