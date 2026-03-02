import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class CameraService {
  static final ImagePicker _picker = ImagePicker();
  static final Dio _dio = Dio();

  // Request camera permission
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // Request gallery permission
  static Future<bool> requestGalleryPermission() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  // Check if camera permission is granted
  static Future<bool> hasCameraPermission() async {
    return await Permission.camera.isGranted;
  }

  // Check if gallery permission is granted
  static Future<bool> hasGalleryPermission() async {
    return await Permission.photos.isGranted;
  }

  // Take photo from camera
  static Future<File?> takePhoto({
    int quality = 80,
    bool enableAudio = false,
  }) async {
    try {
      if (!await hasCameraPermission()) {
        final granted = await requestCameraPermission();
        if (!granted) {
          throw Exception('Camera permission denied');
        }
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: quality,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to take photo: $e');
    }
  }

  // Pick image from gallery
  static Future<File?> pickImage({
    int quality = 80,
    bool allowMultiple = false,
  }) async {
    try {
      if (!await hasGalleryPermission()) {
        final granted = await requestGalleryPermission();
        if (!granted) {
          throw Exception('Gallery permission denied');
        }
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: quality,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  // Pick multiple images from gallery
  static Future<List<File>> pickMultipleImages({
    int quality = 80,
    int maxImages = 10,
  }) async {
    try {
      if (!await hasGalleryPermission()) {
        final granted = await requestGalleryPermission();
        if (!granted) {
          throw Exception('Gallery permission denied');
        }
      }

      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: quality,
      );

      return images.map((image) => File(image.path)).toList();
    } catch (e) {
      throw Exception('Failed to pick multiple images: $e');
    }
  }

  // Record video
  static Future<File?> recordVideo({
    Duration maxDuration = const Duration(minutes: 10),
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    try {
      if (!await hasCameraPermission()) {
        final granted = await requestCameraPermission();
        if (!granted) {
          throw Exception('Camera permission denied');
        }
      }

      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: maxDuration,
        preferredCameraDevice: preferredCameraDevice,
      );

      if (video != null) {
        return File(video.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to record video: $e');
    }
  }

  // Pick video from gallery
  static Future<File?> pickVideo({
    Duration maxDuration = const Duration(minutes: 10),
  }) async {
    try {
      if (!await hasGalleryPermission()) {
        final granted = await requestGalleryPermission();
        if (!granted) {
          throw Exception('Gallery permission denied');
        }
      }

      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: maxDuration,
      );

      if (video != null) {
        return File(video.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick video: $e');
    }
  }

  // Compress image
  static Future<File> compressImage(File imageFile, {int quality = 80}) async {
    try {
      final XFile compressedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: quality,
      ) as XFile;
      
      return File(compressedImage.path);
    } catch (e) {
      throw Exception('Failed to compress image: $e');
    }
  }

  // Get file size in MB
  static double getFileSizeInMB(File file) {
    final bytes = file.lengthSync();
    return bytes / (1024 * 1024);
  }

  // Check if file size is within limit
  static bool isFileSizeValid(File file, double maxSizeMB) {
    return getFileSizeInMB(file) <= maxSizeMB;
  }

  // Upload file to server
  static Future<String> uploadFile(
    File file, {
    String endpoint = '/upload',
    String fieldName = 'file',
    Map<String, dynamic>? additionalData,
    ProgressCallback? onProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(file.path),
        if (additionalData != null) ...additionalData,
      });

      final response = await _dio.post(
        endpoint,
        data: formData,
        onSendProgress: onProgress,
      );

      return response.data['url'] ?? response.data['file_url'];
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  // Upload multiple files
  static Future<List<String>> uploadMultipleFiles(
    List<File> files, {
    String endpoint = '/upload-multiple',
    String fieldName = 'files',
    Map<String, dynamic>? additionalData,
    ProgressCallback? onProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: files.map((file) async {
          return await MultipartFile.fromFile(file.path);
        }).toList(),
        if (additionalData != null) ...additionalData,
      });

      final response = await _dio.post(
        endpoint,
        data: formData,
        onSendProgress: onProgress,
      );

      return List<String>.from(response.data['urls'] ?? []);
    } catch (e) {
      throw Exception('Failed to upload multiple files: $e');
    }
  }

  // Save file to local storage
  static Future<File> saveFileToLocal(File file, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final savedFile = File('${directory.path}/$fileName');
      await file.copy(savedFile.path);
      return savedFile;
    } catch (e) {
      throw Exception('Failed to save file: $e');
    }
  }

  // Delete local file
  static Future<void> deleteLocalFile(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  // Get local file
  static Future<File?> getLocalFile(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get local file: $e');
    }
  }

  // Convert file to base64
  static Future<String> fileToBase64(File file) async {
    try {
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      throw Exception('Failed to convert file to base64: $e');
    }
  }

  // Convert base64 to file
  static Future<File> base64ToFile(String base64String, String fileName) async {
    try {
      final bytes = base64Decode(base64String);
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      throw Exception('Failed to convert base64 to file: $e');
    }
  }

  // Get image dimensions
  static Future<Map<String, int>> getImageDimensions(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      
      return {
        'width': image.width,
        'height': image.height,
      };
    } catch (e) {
      throw Exception('Failed to get image dimensions: $e');
    }
  }

  // Resize image
  static Future<File> resizeImage(
    File imageFile, {
    int? maxWidth,
    int? maxHeight,
    int quality = 80,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      
      // Calculate new dimensions
      int newWidth = image.width;
      int newHeight = image.height;
      
      if (maxWidth != null && image.width > maxWidth) {
        newWidth = maxWidth;
        newHeight = (image.height * maxWidth / image.width).round();
      }
      
      if (maxHeight != null && newHeight > maxHeight) {
        newHeight = maxHeight;
        newWidth = (newWidth * maxHeight / newHeight).round();
      }
      
      // Create a new image with the calculated dimensions
      final resizedImage = await _resizeImage(image, newWidth, newHeight);
      
      // Save to temporary file
      final directory = await getTemporaryDirectory();
      final resizedFile = File('${directory.path}/resized_${DateTime.now().millisecondsSinceEpoch}.jpg');
      
      final byteData = await resizedImage.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();
      await resizedFile.writeAsBytes(pngBytes);
      
      return resizedFile;
    } catch (e) {
      throw Exception('Failed to resize image: $e');
    }
  }

  // Generate thumbnail
  static Future<File> generateThumbnail(
    File imageFile, {
    int width = 150,
    int height = 150,
    int quality = 80,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      
      // Create thumbnail
      final thumbnail = await _resizeImage(image, width, height);
      
      // Save to temporary file
      final directory = await getTemporaryDirectory();
      final thumbnailFile = File('${directory.path}/thumbnail_${DateTime.now().millisecondsSinceEpoch}.jpg');
      
      final byteData = await thumbnail.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();
      await thumbnailFile.writeAsBytes(pngBytes);
      
      return thumbnailFile;
    } catch (e) {
      throw Exception('Failed to generate thumbnail: $e');
    }
  }

  // Helper method to resize image
  static Future<ui.Image> _resizeImage(ui.Image image, int width, int height) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    
    canvas.drawImageRect(
      image,
      ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      ui.Paint(),
    );
    
    final picture = recorder.endRecording();
    return await picture.toImage(width, height);
  }

  // Check if file is image
  static bool isImageFile(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  // Check if file is video
  static bool isVideoFile(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    return ['mp4', 'avi', 'mov', 'wmv', 'flv', 'webm', 'mkv'].contains(extension);
  }

  // Get file extension
  static String getFileExtension(File file) {
    return file.path.split('.').last.toLowerCase();
  }

  // Get file name without extension
  static String getFileNameWithoutExtension(File file) {
    final path = file.path;
    final fileName = path.split('/').last;
    return fileName.split('.').first;
  }

  // Generate unique file name
  static String generateUniqueFileName(String originalName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = originalName.split('.').last;
    return '${timestamp}_$originalName';
  }
}

// Helper function for base64 encoding
String base64Encode(List<int> bytes) {
  return base64.encode(bytes);
}

// Helper function for base64 decoding
List<int> base64Decode(String base64String) {
  return base64.decode(base64String);
}


