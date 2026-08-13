import '../models/message_model.dart';

class ChatService {
  final List<MessageModel> _messages = [];

  List<MessageModel> get messages => List.unmodifiable(_messages);

  Future<void> sendMessage({
    required String senderId,
    required String message,
  }) async {
    if (message.trim().isEmpty) return;

    final newMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: senderId,
      message: message.trim(),
      timestamp: DateTime.now(),
    );

    _messages.add(newMessage);
  }

  Future<List<MessageModel>> getMessages() async {
    return List.unmodifiable(_messages);
  }

  void clearMessages() {
    _messages.clear();
  }
}