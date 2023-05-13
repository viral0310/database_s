class Student {
  final int id;
  final String name;
  final String dob;

  Student({required this.id, required this.name, required this.dob});

  factory Student.fromMap(Map<String, dynamic> data) {
    return Student(
      id: data['id'],
      name: data['name'],
      dob: data['dob'],
    );
  }
}
