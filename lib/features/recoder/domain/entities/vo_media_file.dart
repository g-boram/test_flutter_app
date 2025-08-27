class VoMediaFile {
  final String path;
  final DateTime createdAt;
  final String? mimeType;
  const VoMediaFile({required this.path, required this.createdAt, this.mimeType});
}
