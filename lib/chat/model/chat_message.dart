import '../pages/chat_detail_page.dart';
import 'package:flutter/cupertino.dart';

class ChatMessage{
  String message;
  MessageType type;
  DateTime time;
  ChatMessage({required this.message,required this.type, required this.time});
}


class Message {// probably want the senders image if we do groups
  final int id;
  final String text;
  final bool isSender; // if we do some sort of weird group system we might need to sender Id's
  final DateTime timestamp;
  final Message? parentMessage;// we might want to a list of parentMessage(for multiple replies/translations/literations, etc)
  //final List<Message> replies; 
  final String explanation; // idk why tf we have this tbh
  final InfoType infoType;
  final List<String> imageUrls;
  final String audioUrl; // URL or path to the audio file
  bool translated;
  bool transliterated;
  bool isReplying;

  Message({
    required this.id,
    required this.text,
    this.isSender = false, // if we do some sort of weird group system we might need to sender Id's
    required this.timestamp,
    this.parentMessage,
    this.explanation = '',
    this.infoType = InfoType.normal,
    this.imageUrls = const [],
    this.audioUrl = '', // Initialize with an empty string
    this.translated = false,
    this.transliterated = false,

    this.isReplying = false,
  });
}

enum InfoType {
  normal,
  reply,
  translate,
  transliterate,
  // Add more reply types as needed
}