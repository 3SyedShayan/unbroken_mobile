part of '../configs.dart';

/// Extension on [String?] to add URL normalization, image validation, and launching features.
extension StringUrlX on String? {
  /// Returns `true` if this URL is a valid network image address suitable for
  /// image decoders (rejects empty, non-HTTP, and HTML-serving Google preview links).
  bool get isValidImageUrl {
    final url = this;
    if (url == null || url.trim().isEmpty) return false;
    final cleanUrl = url.trim();

    final lowercase = cleanUrl.toLowerCase();
    if (lowercase.contains('share.google') ||
        lowercase.contains('drive.google.com') ||
        lowercase.contains('photos.app.goo.gl') ||
        lowercase.contains('photos.google.com') ||
        lowercase.contains('docs.google.com')) {
      return false;
    }

    return cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://');
  }

  /// Normalizes a URL by trimming it and ensuring it has a valid scheme (protocol).
  /// If it doesn't already have a scheme (e.g. website.com or www.website.com),
  /// it prepends `https://`. Custom schemes like `mailto:`, `tel:`, and `sms:` are preserved.
  String get normalizeUrl {
    final trimmed = this?.trim() ?? '';
    if (trimmed.isEmpty) return '';

    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.hasScheme) {
      return trimmed;
    }

    return 'https://$trimmed';
  }

  /// Safely attempts to launch the string as an external application URL.
  /// Pre-normalizes the URL to ensure it has a valid protocol.
  Future<bool> launchAsUrl() async {
    final normalized = normalizeUrl;
    if (normalized.isEmpty) return false;

    final uri = Uri.tryParse(normalized);
    if (uri != null && await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
