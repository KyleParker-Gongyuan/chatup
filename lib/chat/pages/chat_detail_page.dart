

import 'package:flutter/material.dart';


import '../../background_ui/chat_detail_page_appbar.dart';
import 'contacts_list.dart';


import '../components/chat_bubble.dart';

import '../model/chat_message.dart';
import '../model/send_menu_items.dart';


enum MessageType{
  Sender,
  Receiver,
}


//! THIS IS WHERE WE CAN PUT  

class ChatDetailPage extends StatefulWidget{
  String userName;
  String text;
  String userAvatar;
  bool isKnownUser;
  //final Function(Map<String, dynamic>) addUserCallback; // Add this line
  ChatDetailPage({required this.userName, required this.text,required this.userAvatar,required this.isKnownUser,});

  
  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  List<Map<String, dynamic>> _knownUsers = [];

  final msgController = TextEditingController();
  void _addUser(Map<String, dynamic> user) { //* how do I get this user?
    setState(() {
      _knownUsers.add(user);
    });
    
    // Save the updated list of known users to SharedPreferences
    // ...
  }

// probably need to add datetime aswell
  List<ChatMessage> chatMessages = [ // we need to do this differnetly if we do it in a group
    ChatMessage(message: "Hi John", time: DateTime.now(), type: MessageType.Receiver), 
    ChatMessage(message: "Hope you are doin good", time: DateTime.now(), type: MessageType.Receiver),
    ChatMessage(message: "Hello Jane, I'm good what about you", time: DateTime.now(), type: MessageType.Sender),
    ChatMessage(message: "I'm fine, Working from home", time: DateTime.now(), type: MessageType.Receiver),
    ChatMessage(message: "Oh! Nice. Same here man", time: DateTime.now(), type: MessageType.Sender), // we want to get the info from supabase
  ];

  List<SendMenuItems> menuItems = [ // dont do this its garbage
    SendMenuItems(text: "Photos & Videos", icons: Icons.image, color: Colors.amber),
    SendMenuItems(text: "Document", icons: Icons.insert_drive_file, color: Colors.blue),
    SendMenuItems(text: "Audio", icons: Icons.music_note, color: Colors.orange),
    SendMenuItems(text: "Location", icons: Icons.location_on, color: Colors.green),
    SendMenuItems(text: "Contact", icons: Icons.person, color: Colors.purple),
  ];

  void showModal(){ // dont use this its garbage (the menu for pics and things )
    showModalBottomSheet(
      context: context,
      builder: (context){
        return Container(
          height: MediaQuery.of(context).size.height/2,
          color: Color.fromARGB(255, 254, 0, 0),
          child: Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 195, 21, 21),
              borderRadius: BorderRadius.only(topRight: Radius.circular(820),topLeft: Radius.circular(20)),
            ),
            child: Column(
              children: <Widget>[
                SizedBox(height: 16,),
                Center(
                  child: Container(
                    height: 4,
                    width: 50,
                    color: Color.fromARGB(255, 246, 2, 2),
                  ),
                ),
                SizedBox(height: 10,),
                ListView.builder(
                  itemCount: menuItems.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index){
                    return Container(
                      padding: EdgeInsets.only(top: 10,bottom: 10),
                      child: ListTile(
                        leading: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: menuItems[index].color.shade50,
                          ),
                          height: 50,
                          width: 50,
                          child: Icon(menuItems[index].icons,size: 20,color: menuItems[index].color.shade400,),
                        ),
                        title: Text(menuItems[index].text),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatDetailPageAppBar(userName: widget.userName, userAvatar: widget.userAvatar,
       isOnline: false, preferredSize: Size.fromHeight(kToolbarHeight), isKnownUser: widget.isKnownUser),
      body: Stack(
        children: <Widget>[ // the bottom box
          ListView.builder(
            
            itemCount: chatMessages.length,
            shrinkWrap: true,
            padding: EdgeInsets.only(top: 10,bottom: 10),
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index){
              return ChatBubble(
                chatMessage: chatMessages[index],
              );
            },
         ),
          Align( //this is the bottom "chatbar" thing (the textarea?)
            alignment: Alignment.bottomLeft,
            child: Container( //!this is the msg box
              padding: EdgeInsets.only(left: 16,bottom: 10, right: 70),
              height: 80,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  GestureDetector( //! the far left button
                    onTap: (){
                      showModal();
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(Icons.add,color: Colors.white,size: 21,),
                    ),
                  ),
                  SizedBox(width: 16,),
                  Expanded( // this is the txt box
                    child: TextField(
                      controller: msgController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: "Type message...",
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        border: InputBorder.none
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              padding: const EdgeInsets.only(right: 10,bottom: 15),
              child: FloatingActionButton(
                onPressed: (){
                  
                  if (!widget.isKnownUser){ // we send nothing
                    print('pofgz');
                    widget.isKnownUser = true; // we need to put this in the
                    
                    // add to the list
                    //MyUserListHolder(); // Pass the _addUser function to the UserList widget
                    //we need to make it so we dont see the same user if you know this user 
                    
                    ChatMessage(message: msgController.text, type: MessageType.Sender, time: DateTime.now());
                  }
                  else{
                    print('pofg');
                  }
                },
                backgroundColor: Colors.pink,
                elevation: 0,
                child: const Icon(Icons.send,color: Colors.white,),
              ),
            ),
          )
        ],
      ),
    );
  }
}





//? can probably just add flutter chat ui and figgure out how ot get the messege icon stuff
//TODO msg options: audio msg, pics,
//TODO txt bubble button: copy, translate, reply, correct, sections(seperate into parts (ni-hao 你-好) with multiple colors (color picker?) )
//TODO more bub settings: txt to talk(try and get yellowbridge OR wikitonary), more(selecting multiple bubbles), fav txt(idk why?) 
//? need a way to play a game(generic (non learning) and learning(lvls/difficulty (scrabble? idk) ) )


