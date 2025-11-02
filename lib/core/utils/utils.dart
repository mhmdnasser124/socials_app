import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';

class Utils {
  // Arabic Checker
  static bool isArabicText(String text) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]');
    return arabicRegex.hasMatch(text);
  }

  static bool intToBool(int value) {
    return value == 1 ? true : false;
  }

  static int boolToInt(bool value) {
    return value ? 1 : 0;
  }

  static bool isValidPositiveNonZeroNumber(String input) {
    final regex = RegExp(r'^(?:[1-9]\d*|[1-9]\d*\.\d+|0\.[1-9]\d*)$');
    return regex.hasMatch(input);
  }

  static bool? intToBoolOrNull(int? value) {
    if (value == null) return null;
    return value == 1 ? true : false;
  }

  static int? boolToIntOrNull(bool? value) {
    if (value == null) return null;
    return value ? 1 : 0;
  }

  static Color hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // add alpha if not provided
    }
    return Color(int.parse(hex, radix: 16));
  }

  // Date Picker
  static Future<DateTime?> selectDate(
    BuildContext context, {
    DateTime? firstDate,
  }) async {
    DateTime currentDateTime = DateTime.now();
    final result = await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: Column(
            children: [
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground.resolveFrom(context),
                  border: Border(
                    bottom: BorderSide(
                      color: CupertinoColors.separator.resolveFrom(context),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoButton(
                      child: const Text('Done'),
                      onPressed: () =>
                          Navigator.of(context).pop(currentDateTime),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: DateTime.now(),
                  minimumDate: firstDate ?? DateTime(1900, 8),
                  maximumDate: DateTime(2101),
                  onDateTimeChanged: (DateTime newDateTime) {
                    currentDateTime = newDateTime;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    return result;
  }

  static Future<XFile?> imagePicker(
    ImageSource imageSource, {
    bool withCropper = true,
    bool withCustomCropper = true,
  }) async {
    final pickedImage = await ImagePicker().pickImage(source: imageSource);
    _printImageInfo(pickedImage);
    if (!withCropper) return pickedImage;
    final imageCropped = await _cropImage(
      pickedImage,
      withCustom: withCustomCropper,
    );
    _printImageInfo(imageCropped);
    return imageCropped;
  }

  static Future<XFile?> videoPicker(ImageSource source) async {
    final picker = ImagePicker();
    try {
      return await picker.pickVideo(source: source);
    } catch (e) {
      return null;
    }
  }

  static Future<XFile?> _cropImage(
    XFile? image, {
    bool withCustom = true,
  }) async {
    if (image == null) return null;
    // final imageCropped = await ImageCropper().cropImage(
    //   sourcePath: image.path,
    //   compressQuality: 75,
    //   uiSettings: [
    //     AndroidUiSettings(
    //       initAspectRatio:
    //           withCustom
    //               ? CropAspectRatioPresetCustom()
    //               : CropAspectRatioPreset.ratio7x5,
    //       toolbarTitle: 'Cropper',
    //       toolbarColor: ColorManager.colorPrimary,
    //       toolbarWidgetColor: ColorManager.colorWhite,
    //       aspectRatioPresets: [
    //         if (withCustom) CropAspectRatioPresetCustom(),
    //         CropAspectRatioPreset.ratio7x5,
    //         CropAspectRatioPreset.square,
    //       ],
    //     ),
    //     IOSUiSettings(
    //       title: 'Cropper',
    //       aspectRatioPresets: [
    //         if (withCustom) CropAspectRatioPresetCustom(),
    //         CropAspectRatioPreset.ratio7x5,
    //         CropAspectRatioPreset.square,
    //       ],
    //     ),
    //   ],
    // );
    // if (imageCropped == null) return null;
    // return XFile(imageCropped.path);
    return image;
  }

  static Future<void> _printImageInfo(XFile? imageFile) async {
    if (imageFile == null) return;
    try {
      // 1. Get file size
      final sizeInBytes = await imageFile.length();
      final sizeInKB = sizeInBytes / 1024;
      final sizeInMB = sizeInKB / 1024;

      // 2. Get file extension
      final extension = path.extension(imageFile.path).toLowerCase();

      // 3. Get other image info
      final name = path.basename(imageFile.path);
      final file = File(imageFile.path);
      final lastModified = await file.lastModified();

      // Print all information
      debugPrint('📄 Image Information:');
      debugPrint('----------------------');
      debugPrint('📌 Name: $name');
      debugPrint('📁 Extension: $extension');
      debugPrint('📏 Size:');
      debugPrint('  - ${sizeInBytes.toStringAsFixed(0)} bytes');
      debugPrint('  - ${sizeInKB.toStringAsFixed(2)} KB');
      debugPrint('  - ${sizeInMB.toStringAsFixed(2)} MB');
      debugPrint('⏱️ Last Modified: $lastModified');
      debugPrint('📍 Path: ${imageFile.path}');
      debugPrint('----------------------');
    } catch (e) {
      debugPrint('❌ Error getting image info: $e');
    }
  }

  // Multi Image Picker
  static Future<List<XFile>> multiImagePicker() async {
    List<XFile> files = [];
    final pickedImage = await ImagePicker().pickMultiImage();
    for (var image in pickedImage) {
      _printImageInfo(image);
      final imageCropped = await _cropImage(image);
      _printImageInfo(imageCropped);
      if (imageCropped != null) {
        files.add(imageCropped);
      }
    }
    return files;
  }

  // WhatsApp Function
  static Future<void> openWhatsApp({
    required String phoneNumber,
    String? message,
  }) async {
    try {
      String cleanedPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      if (!cleanedPhoneNumber.startsWith('+')) {
        cleanedPhoneNumber = '+963$cleanedPhoneNumber';
      }

      final phoneForUrl = cleanedPhoneNumber.replaceFirst('+', '');

      final Uri whatsappUri = Uri(
        scheme: 'https',
        host: 'wa.me',
        path: phoneForUrl,
        queryParameters: message != null ? {'text': message} : null,
      );

      debugPrint('WhatsApp URI: $whatsappUri');

      // Try to launch WhatsApp
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: Try WhatsApp app directly
        final Uri whatsappAppUri = Uri(
          scheme: 'whatsapp',
          path: 'send',
          queryParameters: {
            'phone': phoneForUrl,
            if (message != null) 'text': message,
          },
        );

        debugPrint('WhatsApp App URI: $whatsappAppUri');

        if (await canLaunchUrl(whatsappAppUri)) {
          await launchUrl(whatsappAppUri, mode: LaunchMode.externalApplication);
        } else {
          // CustomToasts(
          //   message: "CouldNotOpenWhatsApp".tr,
          //   type: CustomToastType.error,
          // ).show();
        }
      }
    } catch (e) {
      // CustomToasts(
      //   message: "CouldNotOpenWhatsApp".tr,
      //   type: CustomToastType.error,
      // ).show();
    }
  }

  // Phone Call Function
  static Future<void> openPhoneCall({required String phoneNumber}) async {
    try {
      String cleanedPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      final Uri phoneUri = Uri(scheme: 'tel', path: cleanedPhoneNumber);

      debugPrint('Phone URI: $phoneUri');

      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
      } else {
        // CustomToasts(
        //   message: "CouldNotOpenPhone".tr,
        //   type: CustomToastType.error,
        // ).show();
      }
    } catch (e) {
      //   CustomToasts(
      //     message: "CouldNotOpenPhone".tr,
      //     type: CustomToastType.error,
      //   ).show();
    }
  }

  // static void openFullScreenImage(String? image) {
  //   if (image == null) return;
  //   final imageUrl = image.toUrl ?? '';
  //   final heroTag = 'product_image_$image';
  //
  //   Get.to(
  //     () => FullScreenImageViewer(imageUrl: imageUrl, heroTag: heroTag),
  //     transition: Transition.fadeIn,
  //     duration: const Duration(milliseconds: 300),
  //   );
  // }

  /// Time Picker

  // static Future<DateTime?> selectTime({TimeOfDay? initialTime}) async {
  //   DateTime initialDateTime = DateTime.now();
  //   if (initialTime != null) {
  //     initialDateTime = DateTime(
  //       DateTime.now().year,
  //       DateTime.now().month,
  //       DateTime.now().day,
  //       initialTime.hour,
  //       initialTime.minute,
  //     );
  //   }
  //
  //   DateTime currentDateTime = initialDateTime;
  //
  //   final result = await showDialog<DateTime>(
  //     context: Get.context!,
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(16),
  //         ),
  //         child: Container(
  //           width: Get.width * 0.7,
  //           height: Get.height * 0.4,
  //           padding: const EdgeInsets.all(16),
  //           child: Column(
  //             children: [
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   CupertinoButton(
  //                     child: Text('Cancel'.tr),
  //                     onPressed: () => Get.back(),
  //                   ),
  //                   CupertinoButton(
  //                     child: Text('Done'.tr),
  //                     onPressed:
  //                         () => Navigator.of(context).pop(currentDateTime),
  //                   ),
  //                 ],
  //               ),
  //               const SizedBox(height: 16),
  //               Expanded(
  //                 child: Localizations.override(
  //                   context: context,
  //                   locale: const Locale('en', 'US'),
  //                   child: CupertinoDatePicker(
  //                     mode: CupertinoDatePickerMode.time,
  //                     initialDateTime: initialDateTime,
  //                     use24hFormat: false,
  //                     onDateTimeChanged: (DateTime newDateTime) {
  //                       currentDateTime = newDateTime;
  //                     },
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  //
  //   if (result != null) {
  //     return DateTime(
  //       DateTime.now().year,
  //       DateTime.now().month,
  //       DateTime.now().day,
  //       result.hour,
  //       result.minute,
  //     );
  //   }
  //   return null;
  // }

  // Image Picker
}

// class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
//   @override
//   (int, int)? get data => (5, 7);
//
//   @override
//   String get name => '5x7';
// }
