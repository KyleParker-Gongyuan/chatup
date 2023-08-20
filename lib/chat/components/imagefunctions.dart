import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class Imagefunctions {
  Image imageFromBase64String(String base64String) {
    return Image.memory(base64Decode(base64String));
  }

  Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String);
  }

  String image2Base64String(Uint8List imageData) {
    return base64Encode(imageData);
  }
}