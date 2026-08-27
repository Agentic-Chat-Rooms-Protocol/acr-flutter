class FileAttachment {
  const FileAttachment({
    required this.id,
    required this.filename,
    required this.size,
    required this.mimeType,
    required this.url,
  });

  factory FileAttachment.fromJson(Map<String, dynamic> json) {
    return FileAttachment(
      id: json['id'] as String? ?? '',
      filename: json['filename'] as String? ?? '',
      size: (json['size'] as num?)?.toInt() ?? 0,
      mimeType: json['mime_type'] as String? ?? 'application/octet-stream',
      url: json['url'] as String? ?? '',
    );
  }

  final String id;
  final String filename;
  final int size;
  final String mimeType;
  final String url;

  bool get isImage => mimeType.startsWith('image/');

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'filename': filename,
        'size': size,
        'mime_type': mimeType,
        'url': url,
      };
}
