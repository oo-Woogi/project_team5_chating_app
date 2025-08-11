class User {
  final String id;
  final String name;
  final String aboutMe;
  final String position;
  final String? imgpath; // nullable로 추가

  User({
    required this.id,
    required this.name,
    required this.aboutMe,
    required this.position,
    this.imgpath,
  });

  User.fromJson(Map<String, dynamic> json, String id)
      : this(
          id: id,
          name: json['name'] ?? '',
          aboutMe: json['aboutMe'] ?? '',
          position: json['position'] ?? '',
          imgpath: json['imgpath'], // Firestore에 필드가 없으면 null
        );

  Map<String, dynamic> toJson() => {
        'name': name,
        'aboutMe': aboutMe,
        'position': position,
        if (imgpath != null) 'imgpath': imgpath,
      };
}
