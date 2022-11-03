import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../model/account.dart';
import '../model/property.dart';

class FileManager {
  Future<List<XFile>> pickMultiImages() async {
    final ImagePicker _picker = ImagePicker();

    final List<XFile>? images = await _picker.pickMultiImage();

    return images!;
  }

  Future<XFile> pickPhoto(
      {BuildContext? context,
      ImageSource? imageSource,
      CameraDevice? cameraDevice}) async {
    final ImagePicker _picker = ImagePicker();

    // Pick an image
    final XFile? photo = await _picker.pickImage(
        source: imageSource!, preferredCameraDevice: cameraDevice!);

    // CroppedFile? croppedFile = await ImageCropper().cropImage(
    //   sourcePath: photo!.path,
    //   cropStyle: CropStyle.rectangle,
    //   aspectRatio: CropAspectRatio(ratioX: 16, ratioY: 9),
    //   aspectRatioPresets: [
    //     //CropAspectRatioPreset.square,
    //     //CropAspectRatioPreset.ratio3x2,
    //     CropAspectRatioPreset.original,
    //     //CropAspectRatioPreset.ratio4x3,
    //     CropAspectRatioPreset.ratio16x9
    //   ],
    //   uiSettings: [
    //     AndroidUiSettings(
    //         toolbarTitle: 'Crop Image',
    //         toolbarColor: Colors.pink,
    //         toolbarWidgetColor: Colors.white,
    //         initAspectRatio: CropAspectRatioPreset.original,
    //         lockAspectRatio: false),
    //     IOSUiSettings(
    //       title: 'Crop Image',
    //     ),
    //     WebUiSettings(
    //         context: context!,
    //         enableZoom: true,
    //         showZoomer: true,
    //         mouseWheelZoom: true,
    //         viewPort: CroppieViewPort(height: 400, width: 1000),
    //         //boundary: CroppieBoundary(),
    //         presentStyle: CropperPresentStyle.page),
    //   ],
    // );

    // Uint8List? finalData = await croppedFile!.readAsBytes();

    return photo!; //XFile.fromData(finalData);
  }

  Future<String> uploadProfilePhoto(String userID, XFile pickedFile) async {
    Uint8List data = await pickedFile.readAsBytes();
    // Create the file metadata
    final metadata = SettableMetadata(contentType: "image/jpg");

    // Create a reference to the Firebase Storage bucket
    final storageRef = FirebaseStorage.instance.ref();

    // Upload file and metadata to the path 'images/mountains.jpg'
    UploadTask uploadTask = storageRef
        .child("ProfilePhotos/$userID/photo_$userID.jpg")
        .putData(data, metadata);

    TaskSnapshot snapshot = await uploadTask;

    return snapshot.ref.getDownloadURL();
  }

  Future<String> uploadIDPhoto(
      String userID, String name, XFile pickedFile) async {
    Uint8List data = await pickedFile.readAsBytes();
    // Create the file metadata
    final metadata = SettableMetadata(contentType: "image/jpg");

    // Create a reference to the Firebase Storage bucket
    final storageRef = FirebaseStorage.instance.ref();

    // Upload file and metadata to the path 'images/mountains.jpg'
    UploadTask uploadTask = storageRef
        .child("ProfilePhotos/$userID/$name.jpg")
        .putData(data, metadata);

    TaskSnapshot snapshot = await uploadTask;

    return snapshot.ref.getDownloadURL();
  }

  Future<String> uploadPropertyVideo(
      Property property, PlatformFile pickedFile) async {
    // Create the file metadata
    final metadata =
        SettableMetadata(contentType: "video/${pickedFile.extension}");

    // Create a reference to the Firebase Storage bucket
    final storageRef = FirebaseStorage.instance.ref();

    String videoName = Uuid().v4();

    // Upload file and metadata to the path 'images/mountains.jpg'
    UploadTask uploadTask = storageRef
        .child(
            "PropertyPhotos/${property.propertyID}/$videoName.${pickedFile.extension}")
        .putData(pickedFile.bytes!, metadata);

    TaskSnapshot snapshot = await uploadTask;

    return snapshot.ref.getDownloadURL();
  }

  Future<String> uploadPropertyPhoto(
      Property property, PlatformFile pickedFile) async {
    // Create the file metadata
    final metadata =
        SettableMetadata(contentType: "image/${pickedFile.extension}");

    // Create a reference to the Firebase Storage bucket
    final storageRef = FirebaseStorage.instance.ref();

    String imageName = Uuid().v4();

    // Upload file and metadata to the path 'images/mountains.jpg'
    UploadTask uploadTask = storageRef
        .child(
            "PropertyPhotos/${property.propertyID}/$imageName.${pickedFile.extension}")
        .putData(pickedFile.bytes!, metadata);

    TaskSnapshot snapshot = await uploadTask;

    return snapshot.ref.getDownloadURL();
  }
}
