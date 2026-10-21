import 'package:cloudinary_sdk/cloudinary_sdk.dart';

class UploadedAsset {
  final String publicId;
  final String secureUrl;
  final String? format;
  final String resourceType;
  final int? bytes;
  final int? width;
  final int? height;

  const UploadedAsset({
    required this.publicId,
    required this.secureUrl,
    required this.format,
    required this.resourceType,
    required this.bytes,
    required this.width,
    required this.height,
  });
}

/// Uploads straight from the device to Cloudinary using a signed upload
/// (signature generated client-side by cloudinary_sdk from the API secret).
/// There is no server in this flow — see admin_app/README.md for the
/// accepted risk of embedding these credentials in the compiled APK.
class CloudinaryService {
  static const _cloudName = String.fromEnvironment('CLOUDINARY_CLOUD_NAME');
  static const _apiKey = String.fromEnvironment('CLOUDINARY_API_KEY');
  static const _apiSecret = String.fromEnvironment('CLOUDINARY_API_SECRET');

  late final Cloudinary _cloudinary = Cloudinary.full(
    apiKey: _apiKey,
    apiSecret: _apiSecret,
    cloudName: _cloudName,
  );

  Future<UploadedAsset> uploadImage(String filePath, {String? folder}) =>
      _upload(filePath, CloudinaryResourceType.image, 'image', folder: folder);

  Future<UploadedAsset> uploadVideo(String filePath, {String? folder}) =>
      _upload(filePath, CloudinaryResourceType.video, 'video', folder: folder);

  Future<UploadedAsset> _upload(
    String filePath,
    CloudinaryResourceType resourceType,
    String resourceTypeLabel, {
    String? folder,
  }) async {
    final response = await _cloudinary.uploadResource(
      CloudinaryUploadResource(
          filePath: filePath, resourceType: resourceType, folder: folder),
    );

    if (!response.isSuccessful ||
        response.secureUrl == null ||
        response.publicId == null) {
      throw Exception('Cloudinary upload failed: ${response.error}');
    }

    return UploadedAsset(
      publicId: response.publicId!,
      secureUrl: response.secureUrl!,
      format: response.format,
      resourceType: resourceTypeLabel,
      bytes: response.bytes,
      width: response.width,
      height: response.height,
    );
  }
}
