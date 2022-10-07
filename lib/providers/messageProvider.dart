import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:rekodi/chat/models/chat.dart';
import 'package:rekodi/chat/models/message.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/account.dart';


class MessageProvider with ChangeNotifier {

  Future<List<Message>>? _futureMessages;
  Future<List<Chat>>? _futureChats;

  Future<List<Message>> get futureMessages => _futureMessages!;
  Future<List<Chat>> get futureChats => _futureChats!;

  changeDMMessages(Account account, Account receiver) {
    _futureMessages = getDMMessages(account, receiver);

    notifyListeners();
  }

  updateChats(Account account) {
    _futureChats = getChats(account);

    notifyListeners();
  }

  clearMessages() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.clear();
  }

  updateMessagesDB(Account account) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String messagesString = prefs.getString("${account.userID}_messages") ?? "";

    List<Message> prefList = Message.decode(messagesString);

    prefList.sort((a, b)=> a.timestamp!.compareTo(b.timestamp!));

    var messagesTimestamp = prefList.isEmpty ? 0 : prefList.last.timestamp;

    await FirebaseFirestore.instance.collection("users").doc(account.userID)
        .collection("messages").where("timestamp", isGreaterThan: messagesTimestamp)
        .orderBy("timestamp", descending: false).get().then((querySnapshot) async {
          querySnapshot.docs.forEach((element) {
            prefList.add(Message.fromDocument(element));
          });

          final String encodedData = Message.encode(prefList);

          await prefs.setString("${account.userID}_messages", encodedData);

          notifyListeners();
    });
  }

  Future<List<Message>> getDMMessages(Account account, Account receiver) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String messagesString = prefs.getString("${account.userID}_messages") ?? "";

    List<Message> prefList = Message.decode(messagesString);

    prefList.sort((a, b)=> a.timestamp!.compareTo(b.timestamp!));

    return prefList.where((message) => message.chatID!.split("_").toList().contains(receiver.userID)).toList();
  }

  Future<List<Chat>> getChats(Account account) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String messagesString = prefs.getString("${account.userID}_messages") ?? "";

    List<Message> prefList = Message.decode(messagesString);

    //sort
    prefList.sort((a, b)=> a.timestamp!.compareTo(b.timestamp!));

    var newMap = prefList.groupListsBy((element) => element.chatID);

    List<Chat> chats = newMap.entries.map((e) => Chat(chatID: e.key, messages: e.value)).toList();

    chats.sort((a, b) => a.messages!.last.timestamp!.compareTo(b.messages!.last.timestamp!));

    return chats.reversed.toList();
  }

}