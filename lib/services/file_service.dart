import 'package:file_picker/file_picker.dart';
import '../models/file_item_model.dart';

class FileService {
  final List<FileItemModel> _files = [];

  List<FileItemModel> get files => List.unmodifiable(_files);

  FileService() {
    _seedDemoFiles();
  }

  void _seedDemoFiles() {
    final now = DateTime.now();

    _files.addAll([
      FileItemModel(
        id: 'file_01',
        name: 'Operation_Vanguard_Tactical_Plan.pdf.enc',
        sizeBytes: 3450000,
        senderId: 'usr_cortex_01',
        senderName: 'Alex Morgan (You)',
        recipientId: 'p_01',
        recipientName: 'Sarah Khan',
        hashSha256: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
        status: FileTransferStatus.completed,
        timestamp: now.subtract(const Duration(minutes: 45)),
        accessPermission: FileAccessPermission.restrictedClearance,
        mimeType: 'application/pdf',
      ),
      FileItemModel(
        id: 'file_02',
        name: 'Sector4_Perimeter_Telemetry.json.enc',
        sizeBytes: 520000,
        senderId: 'p_02',
        senderName: 'Daniel Lee',
        recipientId: 'usr_cortex_01',
        recipientName: 'Alex Morgan (You)',
        hashSha256: '8f434346648f6b96df89dda901c5176b10a6d83961dd3c1ac88b59b2dc327aa4',
        status: FileTransferStatus.completed,
        timestamp: now.subtract(const Duration(hours: 2)),
        accessPermission: FileAccessPermission.fullAccess,
        mimeType: 'application/json',
      ),
      FileItemModel(
        id: 'file_03',
        name: 'Satellite_Thermal_Overlay_Alpha.png.enc',
        sizeBytes: 8120000,
        senderId: 'p_03',
        senderName: 'Elena Rostova',
        recipientId: 'usr_cortex_01',
        recipientName: 'Alex Morgan (You)',
        hashSha256: 'ca978112ca1bbdcafac231b39a23dc4da7860814965f7471e3a123bca23c6041',
        status: FileTransferStatus.completed,
        timestamp: now.subtract(const Duration(hours: 5)),
        accessPermission: FileAccessPermission.oneTimeDownload,
        mimeType: 'image/png',
      ),
      FileItemModel(
        id: 'file_04',
        name: 'Legacy_Comms_KeyArchive.tar.enc',
        sizeBytes: 12400000,
        senderId: 'usr_cortex_01',
        senderName: 'Alex Morgan (You)',
        recipientId: 'p_01',
        recipientName: 'Sarah Khan',
        hashSha256: '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8',
        status: FileTransferStatus.expired,
        timestamp: now.subtract(const Duration(days: 2)),
        isRevoked: true,
        accessPermission: FileAccessPermission.readOnly,
        mimeType: 'application/x-tar',
      ),
    ]);
  }

  Future<FilePickerResult?> selectFile() async {
    try {
      final result = await FilePicker.pickFiles();
      return result;
    } catch (_) {
      return null;
    }
  }

  Future<FileItemModel> sendFile({
    required String fileName,
    required int fileSize,
    required String senderId,
    required String senderName,
    required String recipientId,
    required String recipientName,
    String? localPath,
    FileAccessPermission permission = FileAccessPermission.readOnly,
    Duration expiry = const Duration(hours: 24),
  }) async {
    // Deterministic demo SHA-256 hash based on filename & timestamp
    final hashSha256 = 'SHA256-${(fileName.hashCode.abs()).toRadixString(16).padLeft(8, '0')}-'
        '${(DateTime.now().millisecondsSinceEpoch).toRadixString(16).padLeft(8, '0')}';

    final newFile = FileItemModel(
      id: 'file_${DateTime.now().millisecondsSinceEpoch}',
      name: fileName.endsWith('.enc') ? fileName : '$fileName.cortex.enc',
      sizeBytes: fileSize,
      senderId: senderId,
      senderName: senderName,
      recipientId: recipientId,
      recipientName: recipientName,
      hashSha256: hashSha256,
      encryptionAlgorithm: 'AES-256-GCM',
      status: FileTransferStatus.transferring,
      progress: 0.1,
      timestamp: DateTime.now(),
      expiryDuration: expiry,
      localPath: localPath,
      accessPermission: permission,
    );

    _files.insert(0, newFile);
    return newFile;
  }

  void updateTransferProgress(String fileId, double progress) {
    final idx = _files.indexWhere((f) => f.id == fileId);
    if (idx != -1) {
      final status = progress >= 1.0 ? FileTransferStatus.completed : FileTransferStatus.transferring;
      _files[idx] = _files[idx].copyWith(progress: progress, status: status);
    }
  }

  void revokeFileAccess(String fileId) {
    final idx = _files.indexWhere((f) => f.id == fileId);
    if (idx != -1) {
      _files[idx] = _files[idx].copyWith(isRevoked: true, status: FileTransferStatus.expired);
    }
  }

  void deleteFile(String fileId) {
    _files.removeWhere((f) => f.id == fileId);
  }

  Future<void> downloadFile(String filePath) async {
    // Simulated download / decryption action
    await Future.delayed(const Duration(milliseconds: 300));
  }
}