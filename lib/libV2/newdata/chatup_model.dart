

import 'package:flutter/material.dart';
class UsersInContactsSQL{
  //this is set as the primary key automatically vvv
  final int id; //! we get the id from the server
  final String userName; // this can be changed via a nickname (idk how to do this lol)
  final String bio;
  
  final int gender; // 0= male 1=fem 2=other? (we only need 3 options atm)

  final String dob; // date of birth // also a datetime string?
  final int onlineStatus;
  final String imageAvatar;
  final String createdAt; //we need to convert DateTime to string

  UsersInContactsSQL({required this.id, required this.userName, required this.bio, required this.gender, 
  required this.dob, required this.onlineStatus, required this.imageAvatar, required this.createdAt });

  factory UsersInContactsSQL.fromMap(Map<String, dynamic> map) => UsersInContactsSQL(
    id: map['id'], userName: map['username'], bio: map['bio'], gender: map['gender'], dob: map['dob'], onlineStatus: map['onlineStatus'], imageAvatar: map['imageAvatar'], createdAt: map['created_at']);

}


class MessagesSQL{
  final int localId;
  final int serverId;
  final String message;
  final int senderIsMe;
  final int receiverId;
  final String createdAt; //we need to convert DateTime to string
  MessagesSQL({required this.localId,required this.serverId,required this.message,required this.senderIsMe,
  required this.receiverId, required this.createdAt});

  factory MessagesSQL.fromMap(Map<String, dynamic> map) => MessagesSQL(
    localId: map['localId'],
    serverId: map['serverId'],
    message: map['message'],
    senderIsMe: map['senderIsMe'],
    receiverId: map['receiverId'],
    createdAt: map['createdAt']);

}

