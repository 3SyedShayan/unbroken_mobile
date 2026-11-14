import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Domains known to return HTML pages instead of raw image bytes.
/// URLs from these domains should never be fed to an image decoder.
const _nonImageDomains = <String>{
  'share.google',
  'docs.google.com',
  'drive.google.com',
  'bit.ly',
  'tinyurl.com',
  'goo.gl',
  't.co',
};

/// Returns `true` when [url] looks like it can be decoded as an image.
///
/// This is intentionally lenient — it only rejects URLs that are
/// *definitely* not direct image links (redirect services, empty strings,
/// obviously non-HTTP schemes).
bool isPlausibleImageUrl(String? url) {
  if (url == null || url.isEmpty) return false;

  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  if (!uri.hasScheme || (!uri.isScheme('https') && !uri.isScheme('http'))) {
    return false;
  }

  // Reject known redirect/sharing domains that return HTML, not images.
  final host = uri.host.toLowerCase();
  for (final domain in _nonImageDomains) {
    if (host == domain || host.endsWith('.$domain')) return false;
  }

  return true;
}

/// A [CircleAvatar] that safely loads a network image.
///
/// If [imageUrl] is empty, null, or points to a known non-image domain
/// (e.g. `share.google`), the avatar falls back to [fallbackChild]
/// without ever attempting to decode the response as image data.
class SafeCachedAvatar extends StatelessWidget {
  /// The URL of the avatar image.
  final String imageUrl;

  /// Radius of the [CircleAvatar].
  final double radius;

  /// Background colour when no image is loaded.
  final Color? backgroundColor;

  /// Widget shown when the image cannot be loaded (or URL is empty).
  final Widget? fallbackChild;

  const SafeCachedAvatar({
    super.key,
    required this.imageUrl,
    required this.radius,
    this.backgroundColor,
    this.fallbackChild,
  });

  @override
  Widget build(BuildContext context) {
    final showImage = isPlausibleImageUrl(imageUrl);
    final cacheDim = (radius * 3).round().clamp(120, 300);
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      backgroundImage: showImage
          ? CachedNetworkImageProvider(
              imageUrl,
              maxWidth: cacheDim,
              maxHeight: cacheDim,
            )
          : null,
      onBackgroundImageError: showImage ? (_, _) {} : null,
      child: showImage ? null : fallbackChild,
    );
  }
}
