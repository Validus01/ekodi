import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  Future<XFile> pickSinglePhoto() async {
    final ImagePicker _picker = ImagePicker();

    // Pick an image
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    return image!;
  }

  Future<String> uploadProfilePhoto(
      String userID, PlatformFile pickedFile) async {
    // Create the file metadata
    final metadata =
        SettableMetadata(contentType: "image/${pickedFile.extension}");

    // Create a reference to the Firebase Storage bucket
    final storageRef = FirebaseStorage.instance.ref();

    // Upload file and metadata to the path 'images/mountains.jpg'
    UploadTask uploadTask = storageRef
        .child("ProfilePhotos/$userID/photo_$userID.${pickedFile.extension}")
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
