import '../pages/chat_detail_page.dart';
import '../model/chat_message.dart';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';


class ChatBubble extends StatefulWidget{
  ChatMessage chatMessage;
  ChatBubble({required this.chatMessage});

  

  @override
  _ChatBubbleState createState() => _ChatBubbleState();
}


class ItemModel {
  String title;
  IconData icon;

  ItemModel(this.title, this.icon);
}

// we will want to be able to change the color of the txts (by user(paid) and a var)
class _ChatBubbleState extends State<ChatBubble> {
  late List<ItemModel> menuItems;
  CustomPopupMenuController _controller = CustomPopupMenuController();
  
  void initState() {
    menuItems = [
      ItemModel('发起群聊', Icons.chat_bubble), // reply, 
      ItemModel('扫一扫', Icons.favorite_outline), // fav


      ItemModel('扫一扫', Icons.copy), // copy
      ItemModel('更多', Icons.list_outlined), // more (deleting/selecting multiple chat bubbles)
    ];
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16,right: 16,top: 10,bottom: 10),
      child: Align(
        alignment: (widget.chatMessage.type == MessageType.Receiver?Alignment.topLeft:Alignment.topRight),
        child: CustomPopupMenu( // the option
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: (widget.chatMessage.type  == MessageType.Receiver?Color.fromARGB(255, 157, 79, 79):Color.fromARGB(255, 50, 19, 45)),
            ),
            padding: EdgeInsets.all(16),
            child: Text(widget.chatMessage.message),
          ),
          menuBuilder: _chatOptionsMenu,
          pressType: PressType.singleTap,
          controller: _controller,
        ),
      ),
    );
  }

    Widget _chatOptionsMenu() { // we need a way to adjust the size of the menu (how many columns)
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Container(
        width: 250,
        color: const Color(0xFF4C4C4C),
        child: GridView.count(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          crossAxisCount: 5,
          crossAxisSpacing: 0,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: menuItems
              .map((item) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        item.icon,
                        size: 20,
                        color: Colors.white,
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 2),
                        child: Text(
                          item.title,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ))
              .toList(),
        ),
      ),
    );
  }

}