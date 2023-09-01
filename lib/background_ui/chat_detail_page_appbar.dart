import 'dart:convert';
import 'dart:typed_data';

import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';

import 'package:flutter/material.dart';
import 'package:chatup/chat/components/imagefunctions.dart';
import 'package:chatup/chat/model/app_service.dart';
import 'package:chatup/chat/model/user_avatar.dart';

//! this is the top appbar UI for the pic and setting etc 


class ChatDetailPageAppBar extends StatefulWidget implements PreferredSizeWidget{
  final Size preferredSize;
  final String userName;
  final String? userAvatar;
  final bool isOnline;
  final bool isKnownUser;
  

  ChatDetailPageAppBar({required this.preferredSize, required this.userName, required this.userAvatar,
   required this.isOnline, required this.isKnownUser});

  @override
  _ChatDetailPageAppBar createState() => _ChatDetailPageAppBar();
}
class _ChatDetailPageAppBar extends State<ChatDetailPageAppBar> {
  late List<ItemModel> menuItems;
  CustomPopupMenuController _controller = CustomPopupMenuController();
  
  @override
  void initState() {
    menuItems = [
      ItemModel(title: 'block', icon: Icons.copy), // block
      ItemModel(title: 'ban', icon: Icons.list_outlined), // ban
    ];
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      flexibleSpace: SafeArea(
        child: Container(
          padding: EdgeInsets.only(right: 16),
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back,color: Colors.grey,),
              ),
              SizedBox(width: 2,),
              GestureDetector(
                onTap: () => print("Goto users page"),
                child: CircleAvatar( // user image

                  backgroundColor: Colors.grey,
                  maxRadius: 20,
                  backgroundImage: widget.userAvatar!.isNotEmpty ? 
                    ((widget.isKnownUser) ? MemoryImage(Imagefunctions().dataFromBase64String(widget.userAvatar!)) 
                    as ImageProvider<Object> : NetworkImage(widget.userAvatar!)) : null,
                  child: widget.userAvatar!.isEmpty ? letterImageWidget(widget.userName[0]) : null,
                ),
              ),
              const SizedBox(width: 12,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                 
                    Text(widget.userName,style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),), // get the name
                    const SizedBox(height: 6,),
                    
                    Text(widget.isOnline ? "online":"offline", style: TextStyle(color: widget.isOnline ? Colors.green : Colors.grey ,fontSize: 12),), //get the status
                  ],
                ),
              ),
              CustomPopupMenu( // the option
                menuBuilder: _chatOptionsMenu,
                pressType: PressType.singleTap,
                controller: _controller,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Icon(Icons.more_vert,color: Colors.grey.shade700,),
                ),
              ),
              
            ],
          ),
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
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          crossAxisCount: 5,
          crossAxisSpacing: 0,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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
                        margin: const EdgeInsets.only(top: 2),
                        child: Text(
                          item.title,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ))
              .toList(),
        ),
      ),
    );
  }


  @override
  // TODO: implement preferredSize

  @override // updating widget (idk understand)
  void didUpdateWidget(ChatDetailPageAppBar oldWidget) {//! idk what this is tbh
    super.didUpdateWidget(oldWidget);

    if (widget.preferredSize != oldWidget.preferredSize) {
      setState(() {});
    }
  }
}


