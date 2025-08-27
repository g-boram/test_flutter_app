class DtoMediaMeta {
  final String path;
  final int createdAtMs;
  final String? mime;
  DtoMediaMeta({required this.path, required this.createdAtMs, this.mime});

  Map<String, dynamic> toJson() =>
      {'path': path, 'createdAtMs': createdAtMs, 'mime': mime};

  factory DtoMediaMeta.fromJson(Map<String, dynamic> j) =>
      DtoMediaMeta(path: j['path'] as String,
          createdAtMs: j['createdAtMs'] as int,
          mime: j['mime'] as String?);
}
