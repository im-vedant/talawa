import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:talawa/locator.dart';
import 'package:talawa/services/database_mutation_functions.dart';
import 'package:talawa/utils/post_queries.dart';


/// ImageService class provides different functions as service in the context of Images.
///
/// Services include:
/// * `cropImage`
/// * `convertToBase64`
/// * `calculateFileHash`
class ImageService {
  /// Global instance of ImageCropper.
  final ImageCropper _imageCropper = locator<ImageCropper>();
  final _dbFunctions = locator<DataBaseMutationFunctions>();

  /// Crops the image selected by the user.
  ///
  /// **params**:
  /// * `imageFile`: the image file to be cropped.
  ///
  /// **returns**:
  /// * `Future<File?>`: the image after been cropped.
  ///
  /// **throws**:
  /// - `Exception`: If an error occurs during the image cropping process.
  Future<File?> cropImage({required File imageFile}) async {
    // try, to crop the image and returns a File with cropped image path.
    try {
      final CroppedFile? croppedImage = await _imageCropper.cropImage(
        sourcePath: imageFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: const Color(0xff18191A),
            toolbarWidgetColor: Colors.white,
            backgroundColor: Colors.black,
            cropGridColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            cropStyle: CropStyle.rectangle,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          IOSUiSettings(
            minimumAspectRatio: 1.0,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
        ],
      );

      if (croppedImage != null) {
        return File(croppedImage.path);
      }
    } catch (e) {
      throw Exception(
        "ImageService : $e.",
      );
    }

    return null;
  }

  /// Converts the image into Base64 format.
  ///
  /// **params**:
  /// * `file`: Image as a File object.
  ///
  /// **returns**:
  /// * `Future<String>`: image in string format
  Future<String> convertToBase64(File file) async {
    try {
      final List<int> bytes = await file.readAsBytes();
      final String base64String = base64Encode(bytes);
      return base64String;
    } catch (error) {
      return '';
    }
  }

  /// Calculates SHA-256 hash of the given file.
  ///
  /// **params**:
  /// * `file`: File object to calculate hash for.
  ///
  /// **returns**:
  /// * `Future<String>`: hexadecimal string representation of the file's SHA-256 hash
  ///
  /// **throws**:
  /// * `Exception`: If an error occurs during hash calculation
  Future<String> calculateFileHash(File file) async {
    try {
      final List<int> bytes = await file.readAsBytes();
      final Digest hash = sha256.convert(bytes);
      return hash.toString();
    } catch (e) {
      throw Exception('ImageService: Error calculating file hash: $e');
    }
  }

  /// Generates a presigned URL for file upload.
  ///
  /// **params**:
  /// * `fileName`: Name of the file to be uploaded
  /// * `fileHash`: SHA-256 hash of the file
  /// * `organizationId`: Id of the organization
  /// * `objectName`: Optional custom object name for the file
  ///
  /// **returns**:
  /// * `Future<Map<String, dynamic>?>`: Response containing presignedUrl, objectName, and requiresUpload
  ///
  /// **throws**:
  /// * `Exception`: If the backend call fails
  Future<Map<String, dynamic>?> generatePresignedUrl({
    required String fileName,
    required String fileHash,
    required String organizationId,
    String? objectName,
  }) async {
    try {
      final variables = {
        'fileHash': fileHash,
        'fileName': fileName,
        'objectName': objectName,
        'organizationId': organizationId,
      };

      final result = await _dbFunctions.gqlAuthMutation(
        PostQueries().createPresignedUrl(),
        variables: variables,
      );

      if (result.data != null) {
        return result.data!['createPresignedUrl'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to generate presigned URL: $e');
    }
  }
    /// Determines the MIME type of the file based on its extension.
  ///
  /// **params**:
  /// * `fileName`: Name of the file including extension
  ///
  /// **returns**:
  /// * `String`: The MIME type as defined in PostAttachmentMimeType enum
  String getMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'avif':
        return 'IMAGE_AVIF';
      case 'jpg':
      case 'jpeg':
        return 'IMAGE_JPEG';
      case 'png':
        return 'IMAGE_PNG';
      case 'webp':
        return 'IMAGE_WEBP';
      case 'mp4':
        return 'VIDEO_MP4';
      case 'webm':
        return 'VIDEO_WEBM';
      default:
        return 'IMAGE_JPEG'; // Default to JPEG if unknown
    }
  }
}
