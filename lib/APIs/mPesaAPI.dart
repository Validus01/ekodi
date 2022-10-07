import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:rekodi/commonFunctions/requestAssistant.dart';
import 'package:rekodi/model/account.dart';

class MPesaAPI {
  final String consumerKey = "RGoMy1vA3dGzwO67rVvDGvv0IsEPECAF";
  final String consumerSecret = "6oCXL9IkEpTteqry";

  final String authEndpoint = "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials";
  final String processRequestUrl = "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest";

  //Generate base64 code
  String getBasicAuthorization() {

    var bytes = utf8.encode("$consumerKey:$consumerSecret");
    var base64Encode = base64.encode(bytes);

    return base64Encode;
  }

  String password({String? shortCode, String? passKey, String? timestamp}) {
    var bytes = utf8.encode(shortCode!+passKey!+timestamp!);
    var base64Encode = base64.encode(bytes);

    return base64Encode;
  }

  Map<String, String> buildBasicHeaders() {
    String basicAuth = getBasicAuthorization();

    return {
      //"Content-Type": "application/json",
      "Authorization": 'Basic $basicAuth',
      // "Access-Control-Allow-Origin": "*", // Required for CORS support to work
      // //"Access-Control-Allow-Credentials": true, // Required for cookies, authorization headers with HTTPS
      // "Access-Control-Allow-Headers": "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
      // "Access-Control-Allow-Methods": "GET, POST, OPTIONS"
    };
  }

  //Obtain access token
  Future<String> accessToken() async {
    Map<String, String> headers = buildBasicHeaders();

    var result = await RequestAssistant.getRequest(authEndpoint, headers: headers);

    print(result);

    return result["access_token"];
  }


  //build bearer headers
  Future<Map<String, String>> buildBearerHeaders() async {
    String generatedAccessToken = await accessToken();

    return {
      "Content-Type": "application/json",
      "Authorization": 'Bearer $generatedAccessToken',
      // "Access-Control-Allow-Origin": "*", // Required for CORS support to work
      // //"Access-Control-Allow-Credentials": true, // Required for cookies, authorization headers with HTTPS
      // "Access-Control-Allow-Headers": "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
      // "Access-Control-Allow-Methods": "GET, POST, OPTIONS"
    };
  }

  //Make request

  Future<String> performTransactionMobile(Account account, String amount, String phone) async {
    Map<String, String> bearerHeaders = await buildBearerHeaders();

    String timestamp = DateFormat("yyyyMMddHHmmss").format(DateTime.now());

    //TODO: Obtain passkey
    String generatedPassword = password(
      shortCode: "174379",
      passKey: "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919",
      timestamp: timestamp
    );

    Map<String, String> requestBody = {
      "BusinessShortCode": "174379",
      "Timestamp": timestamp,
      "Password": generatedPassword,
      "TransactionType": "CustomerPayBillOnline",
      "Amount": "1",
      "PartyA": phone,
      "PartyB": "174379",
      "PhoneNumber": phone,
      "CallBackURL": "https://us-central1-e-kodi-202ba.cloudfunctions.net/callback",
      "AccountReference": phone,
      "TransactionDesc": "Payment fo Rent",
    };

    final body = jsonEncode(requestBody);

    try {
      var result = await RequestAssistant.postRequest(processRequestUrl, headers: bearerHeaders, body: body);

      print(result);//this is the result
      // {
      //   MerchantRequestID: 10773-26624833-2,
      //   CheckoutRequestID: ws_CO_05052022185635000706951310,
      //   ResponseCode: 0,
      //   ResponseDescription: Success. Request accepted for processing,
      //   CustomerMessage: Success. Request accepted for processing
      // }

      //Timer(const Duration(seconds: 10), () {});

      return "Failed";//TODO
    } catch (exp) {

      print(exp.toString());

      return "transactionFailed";
    }


  }

  Future<String> performTransactionWeb(Account account, String amount, int phone) async {
    //Map<String, String> bearerHeaders = await buildBearerHeaders();

    String timestamp = DateFormat("yyyyMMddHHmmss").format(DateTime.now());

    //TODO: Obtain passkey
    // String generatedPassword = password(
    //   shortCode: "174379",
    //   passKey: "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919",
    //   timestamp: timestamp
    // );


    Map<String, dynamic> requestBody = {
      "BusinessShortCode": 174379,
      "Timestamp": timestamp,
      "TransactionType": "CustomerPayBillOnline",
      "Amount": 1,
      "PartyA": phone,
      "PartyB": 174379,
      "PhoneNumber": phone,
      "CallBackURL": "https://us-central1-e-kodi-202ba.cloudfunctions.net/callback",
      "AccountReference": phone,
      "TransactionDesc": "Payment fo Rent",
      "passKey": "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919",
      "isSuccess": "false",
      "userID": account.userID,
    };

    await FirebaseFirestore.instance.collection("users").doc(account.userID).collection("paymentRequest").doc(timestamp).set(requestBody);

    return "failed";//todo

    // final body = jsonEncode(requestBody);

    // try {
    //   var result = await RequestAssistant.postRequest(processRequestUrl, headers: bearerHeaders, body: body);

    //   print(result);//this is the result
    //   // {
    //   //   MerchantRequestID: 10773-26624833-2,
    //   //   CheckoutRequestID: ws_CO_05052022185635000706951310,
    //   //   ResponseCode: 0,
    //   //   ResponseDescription: Success. Request accepted for processing,
    //   //   CustomerMessage: Success. Request accepted for processing
    //   // }

    //   Timer(const Duration(seconds: 10), () {});

    //   return "success";
    // } catch (exp) {

    //   print(exp.toString());

    //   return "transactionFailed";
    // }
  }

}