
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pdf/widgets.dart';
import 'package:rekodi/model/account.dart';

class PdfApi {
  static Future<String> saveInvoice({required String name, required Document pdf, required Account account}) async {
    final bytes = await pdf.save();

    //final metadata = SettableMetadata(contentType: )//todo
    
    final storageRef = FirebaseStorage.instance.ref();
    
     UploadTask uploadTask = storageRef.child("Invoices/${account.userID}/$name").putData(bytes);

     TaskSnapshot snapshot = await uploadTask;

    return snapshot.ref.getDownloadURL();
  }

  static Future<String> saveReport({required String name, required Document pdf, required Account account}) async {
    final bytes = await pdf.save();

    //final metadata = SettableMetadata(contentType: )//todo
    
    final storageRef = FirebaseStorage.instance.ref();
    
     UploadTask uploadTask = storageRef.child("Reports/${account.userID}/$name").putData(bytes);

     TaskSnapshot snapshot = await uploadTask;

    return snapshot.ref.getDownloadURL();
  }

}