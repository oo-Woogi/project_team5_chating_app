class User {
  final String id;
  final String name;
  final String aboutMe;
  final String position;

  User({
    required this.id,
    required this.name,
    required this.aboutMe,
    required this.position,
  });

  User.fromJson(Map<String, dynamic> json, String id)
      : this(
          id: id,
          name: json['name'] ?? '',
          aboutMe: json['aboutMe'] ?? '',
          position: json['position'] ?? '',
        );

  Map<String, dynamic> toJson() => {
        'name': name,
        'aboutMe': aboutMe,
        'position': position,
      };
}
