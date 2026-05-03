class SignToken {
  final String type;
  final String value;

  const SignToken({
    required this.type,
    required this.value,
  });

  factory SignToken.fromJson(Map<String, dynamic> json) {
    return SignToken(
      type: json['type'] as String? ?? 'char',
      value: json['value'] as String? ?? '',
    );
  }

  bool get isWord => type == 'word';
}
