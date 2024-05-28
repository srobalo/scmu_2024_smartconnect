

class Capabilities {
  final String userId;
  final List<String> actions;
  final List<String> triggers;

  Capabilities({
    required this.userId,
    required this.actions,
    required this.triggers,
  });

  // Convert a Capabilities object into a Map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'actions': actions,
      'triggers': triggers,
    };
  }

  // Create a Capabilities object from a Map
  factory Capabilities.fromMap(Map<String, dynamic> map) {
    return Capabilities(
      userId: map['userId'],
      actions: List<String>.from(map['actions']),
      triggers: List<String>.from(map['triggers']),
    );
  }
}
