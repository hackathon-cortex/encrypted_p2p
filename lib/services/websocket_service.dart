class WebSocketService {
  bool _isConnected = true;
  int _connectedPeersCount = 4;
  String _networkLatency = '18 ms';
  final String _meshTopology = 'P2P Decentralized Mesh';

  bool get isConnected => _isConnected;
  int get connectedPeersCount => _connectedPeersCount;
  String get networkLatency => _networkLatency;
  String get meshTopology => _meshTopology;

  Future<void> connect(String url) async {
    _isConnected = true;
    _connectedPeersCount = 4;
    _networkLatency = '18 ms';
  }

  void sendMessage(String message) {
    if (!_isConnected) return;
  }

  Future<void> disconnect() async {
    _isConnected = false;
    _connectedPeersCount = 0;
    _networkLatency = 'Offline';
  }

  void setConnectedPeers(int count) {
    _connectedPeersCount = count;
  }
}