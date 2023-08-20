import 'package:flutter/material.dart';
import 'dart:math' as math;

enum AvatarType { IMAGE, IMAGE_LETTER, UNKNOWN}

Image avatarImage(String url){

    switch (getAvatarType(url)) {
      case AvatarType.IMAGE:
        return NetworkImage(url) as Image;
        

      case AvatarType.IMAGE_LETTER:
        return NetworkImage(url) as Image;
        
      default:
        return NetworkImage(url) as Image;
    }
    
  }
  AvatarType getAvatarType(String url) {
    
      Uri uri = Uri.parse(url);
      String typeString = uri.path.substring(uri.path.length - 3).toLowerCase();
      if (typeString == "jpg" || typeString == "png") {
        return AvatarType.IMAGE;
      }
      
      if (url == url[0]) {
        
        return AvatarType.IMAGE_LETTER;
      }

      else {
        return AvatarType.UNKNOWN;
      }
  }
  Widget letterImageWidget(String letter) {
    return Container(
    
    width: 100,
    height: 100,
    //margin: EdgeInsets.all(10),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Color((math.Random().nextDouble() * 0xFFFFFF).toInt()),
    ),
      //color: Colors.blue,
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }