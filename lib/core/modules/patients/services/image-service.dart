import 'dart:io';

import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  /// Pick image from Camera or Gallery
  Future<File?> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1920,
    );

    if (image == null) return null;

    return File(image.path);
  }

  /// Upload image to your Laravel server
  Future<String?> uploadImage(File image) async {
    FormData formData = FormData.fromMap({
      "avatar": await MultipartFile.fromFile(
        image.path,
        filename: image.path.split('/').last,
      ),
    });
    final response = await sl.patient.updateProfilePicture(formData);

    switch (response) {
      case Success(:final data):
        return data; // Return the URL of the uploaded image
      case Failure(:final exception):
        throw Exception('Failed to upload image: ${exception.message}');
    }
  }
}
