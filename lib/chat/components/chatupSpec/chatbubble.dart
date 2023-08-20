import 'dart:math';

import 'package:flutter/material.dart';



import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:chatup/chat/model/chat_message.dart';

const double USER_BUBBLE_RADIUS = 16;

///basic chat bubble type
///
///chat bubble [BorderRadius] can be customized using [bubbleRadius]
///chat bubble color can be customized using [color]
///chat bubble tail can be customized  using [tail]
///chat bubble display message can be changed using [text]
///[text] is the only required parameter
///message sender can be changed using [isSender]
///[sent],[delivered] and [seen] can be used to display the message state
///chat bubble [TextStyle] can be customized using [textStyleMain]

class BubbleUserNormal extends StatelessWidget {
  final double bubbleRadius;
  final bool isSender;
  final Color color;
  final Color colorComplement;
  final String text;
  final bool tail;
  final bool sent;
  final bool delivered;
  final bool seen;

  final bool isReplying;
  final Message? associatedMessage;


  final TextStyle textStyleMain;
  final TextStyle textStyle1;
  final TextStyle textStyle2;

  BubbleUserNormal({
    Key? key,
    required this.text,
    this.bubbleRadius = USER_BUBBLE_RADIUS,
    this.isSender = true,
    this.color = Colors.white70,
    this.tail = true,
    this.sent = false,
    this.delivered = false,
    this.seen = false,

    this.isReplying = false,
    this.associatedMessage,


    this.textStyleMain = const TextStyle(
      color: Colors.black87,
      fontSize: 16,
    ),
    this.textStyle1 = const TextStyle(
      fontSize: 18.0,
      color: Colors.red,
    ),
    this.textStyle2 = const TextStyle(
      color: Colors.black87,
      fontSize: 16,
    ),
    this.colorComplement = Colors.white38
  }) : super(key: key);

  ///chat bubble builder method
  @override
  Widget build(BuildContext context) {
    bool stateTick = false;
    Icon? stateIcon;
    if (sent) {
      stateTick = true;
      stateIcon = Icon(
        Icons.done,
        size: 18,
        color: Color(0xFF97AD8E),
      );
    }
    if (delivered) {
      stateTick = true;
      stateIcon = Icon(
        Icons.done_all,
        size: 18,
        color: Color(0xFF97AD8E),
      );
    }
    if (seen) {
      stateTick = true;
      stateIcon = Icon(
        Icons.done_all,
        size: 18,
        color: Color(0xFF92DEDA),
      );
    }

    //if (parentMessage == null){
      return Row(
      children: <Widget>[
        isSender
            ? Expanded(
                child: SizedBox(
                  width: 5,
                ),
              )
            : Container(),
            //Container(child:CircleAvatar(radius: 16, backgroundColor: Colors.amber),),// this is the users avatar WIP
            /* Column(children: [
              if (parentMessage != null)
              Container(
                  color: color,
                  padding: EdgeInsets.all(16),
                  child: Text(
                    parentMessage!.text,
                    style: TextStyle(color: Colors.white),
                  ),
              ),
              Container(
                color: color,
                padding: EdgeInsets.all(16),
                child: Text(
                  text,
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],)
      ],
      ); */
    //}

    /* else{

      return Row(
        children: <Widget>[
          isSender 
              ? Expanded(
                  child: SizedBox(
                    width: 5,
                  ),
                )
              : Container(),
              //Container(child:CircleAvatar(radius: 16, backgroundColor: Colors.amber),),// this is the users avatar WIP
              Column(children: [
                if (parentMessage != null)
                Container(
                  color: color,
                  padding: EdgeInsets.all(16),
                  child: Text(
                    parentMessage!.text,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              
                Container(
                  color: color,
                  padding: EdgeInsets.all(16),
                  child: Text(
                    text,
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],)*/
              
              IntrinsicWidth(child: 
          Container(
            color: Colors.transparent,
            constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Column(
                children: [
                  ChatBubble(
                    padding: EdgeInsets.all(4.0),
                    backGroundColor: color,
                    clipper: ChatBubbleClipper6(
                      type: isSender? BubbleType.sendBubble:BubbleType.receiverBubble,
                      nipSize: 5.0,
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(
                          8.0,
                        ),
                      ),
                      child: Column( //TODO: FIGUREOUT WTF THIS IS EXACTLY!
                        children: [
                          if (isReplying) // the message the user is replying to/associated with
                            Container(
                              decoration: BoxDecoration(
                                color:colorComplement,
                                borderRadius: BorderRadius.circular(
                                  8.0,
                                ),
                              ),
                              child: Column( // wtf is this?
                                children: [
                                  IntrinsicHeight(
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: textStyle1.color,
                                            borderRadius: const BorderRadius.only(
                                              bottomLeft: Radius.circular(
                                                8.0,
                                              ),
                                              topLeft: Radius.circular(
                                                8.0,
                                              ),
                                            ),
                                          ),
                                          width: 7.0,
                                        ),
                                        
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(6.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Title",
                                                  style: textStyle1
                                                ),
                                                Text(
                                                  associatedMessage!.text,
                                                  style: textStyleMain
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Padding( //! the regular text goes here
                            padding: const EdgeInsets.all(4.0),
                            child: Column(
                              children: [
                                Text(text),
                                /* SizedBox( //? maybe where we put the information for sending?
                                  height: 5.0,
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text("12:56 PM"),
                                ) */
                              ],
                            ),
                          ),
                          ],
                      ),
                    ),
                  ),
                ],
              ),
              
              
            ),
          ),)
        ],
      );
    }
//  }


  List<TextSpan> correctionTextConfigurations(String originalText,String correctedText, bool isCorrectionTxt){
    List<TextSpan> textSpans = [];

    List<String> originalWords = originalText.split(' ');
    List<String> modifiedWords = correctedText.split(' ');

    int minLength = originalText.length > correctedText.length
        ? originalText.length
        : correctedText.length;

    for (int i = 0; i < minLength; i++) {
      if (i < originalText.length && i < correctedText.length) {
        if (originalText[i] != correctedText[i]) {
          textSpans.add(TextSpan(
            text: originalText[i],
            style: TextStyle(
              decoration:isCorrectionTxt? null: TextDecoration.lineThrough,
              decorationColor: isCorrectionTxt? null: Colors.black,
              color: isCorrectionTxt? Colors.green:Colors.red 
            ),
          ));
        }
        else {
        textSpans.add(TextSpan(text: originalText[i],style: TextStyle(color: Colors.black)));
        }
      } else if (i < originalText.length) {
        textSpans.add(TextSpan(text: originalText[i],
        style: TextStyle(
              decoration:isCorrectionTxt? null: TextDecoration.lineThrough,
              color:isCorrectionTxt? Colors.green:Colors.red,)));
      }/*  else if (i < correctedText.length) {
        textSpans.add(TextSpan(text: correctedText[i],
        style: TextStyle(
              color:Colors.black)));
      } */
    }
    return textSpans; /* RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.black, fontSize: 18),
        children: textSpans,
      ),
    ); */

  }
  
}