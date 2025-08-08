class Chat {
  final String sender;
  final String senderId;
  final String address;
  final String message;
  final String createdAt;

  Chat({
    required this.sender,
    required this.senderId,
    required this.address,
    required this.message,
    required this.createdAt,
  });

  Chat.fromJson(Map<String, dynamic> json)
    : this(
        sender: json['sender'],
        senderId: json['senderId'],
        address: json['address'],
        message: json['message'],
        createdAt: json['createdAt'],
      );

  Map<String, dynamic> toJson() => {
    'sender': sender,
    'senderId': senderId,
    'address': address,
    'message': message,
    'createdAt': createdAt,
  };
}
