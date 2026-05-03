import 'dart:convert';

enum ConversationMode {
  liveRecognition,
  textToSign,
  speechToText,
  learning,
}

class HistoryEntry {
  final String id;
  final ConversationMode mode;
  final String title;
  final String subtitle;
  final DateTime createdAt;
  final double? confidence;

  const HistoryEntry({
    required this.id,
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.createdAt,
    this.confidence,
  });

  String get modeLabel {
    switch (mode) {
      case ConversationMode.liveRecognition:
        return 'Live';
      case ConversationMode.textToSign:
        return 'Text to Sign';
      case ConversationMode.speechToText:
        return 'Speech';
      case ConversationMode.learning:
        return 'Learning';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mode': mode.name,
      'title': title,
      'subtitle': subtitle,
      'createdAt': createdAt.toIso8601String(),
      'confidence': confidence,
    };
  }

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      id: json['id'] as String,
      mode: ConversationMode.values.firstWhere(
        (mode) => mode.name == json['mode'],
        orElse: () => ConversationMode.liveRecognition,
      ),
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      confidence: (json['confidence'] as num?)?.toDouble(),
    );
  }

  static List<HistoryEntry> decodeList(String raw) {
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((item) =>
            HistoryEntry.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  static String encodeList(List<HistoryEntry> entries) {
    return jsonEncode(entries.map((entry) => entry.toJson()).toList());
  }
}
