class WebSocketService {
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  Future<void> connect(String url) async {
    // WebSocket connection will be connected here.
    _isConnected = true;
  }

  void sendMessage(String message) {
    if (!_isConnected) return;

    // Send message through WebSocket here.
  }

  Future<void> disconnect() async {
    _isConnected = false;
  }
}