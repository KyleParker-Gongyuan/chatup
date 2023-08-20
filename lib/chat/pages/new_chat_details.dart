

import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:audioplayers/audioplayers.dart';
import "package:cached_network_image/cached_network_image.dart";
import 'package:flutter/services.dart';

import 'package:chatup/background_ui/chat_detail_page_appbar.dart';
import 'package:chatup/chat/components/chatupSpec/chatbubble.dart';
import 'package:chatup/chat/components/chatupSpec/message_bar.dart';
import 'package:chatup/chat/model/app_service.dart';
import 'package:chatup/chat/model/chat_message.dart' as msgmain;
import 'package:chatup/libV2/newdata/data_helpa.dart';
import 'package:chatup/libV2/newdata/db_data_translation.dart' as middleware;
import 'package:chatup/libV2/newdata/registry.dart';

import 'package:supabase_flutter/supabase_flutter.dart';




import 'package:swipe_to/swipe_to.dart';





class UserChatRoom extends StatefulWidget {
  

  String userName;
  String? userAvatar;
  String userId;
  bool isOnline;
  bool isKnownUser;
  String myUuid;

  //List<Message> messages; //TODO ideally we will pre load some page's
  
  UserChatRoom({required this.userName, required this.userAvatar, required this.userId, required this.isOnline,
  required this.isKnownUser, required this.myUuid});
  //MyHomePage({required this.userName, required this.userAvatar, required this.userId, required this.messages});

  @override
  _UserChatRoomState createState() => _UserChatRoomState();
}

class _UserChatRoomState extends State<UserChatRoom> {
  AudioPlayer audioPlayer = new AudioPlayer();
  Duration duration = new Duration();
  Duration position = new Duration();
  bool isPlaying = false;
  bool isLoading = false;
  bool isPause = false;
  

  final newdatabase = registry.get<DatabaseHelper>();
  //final database = registry.get<db.MyDatabase>();
  final _supabaseClient = Supabase.instance.client;




  //change from this to the messages
  final List<msgmain.Message> _messages = [
  ];
  //TODO: add the data from database into this list
  bool _replying = false;

  int _controllerIndex = 0;
  msgmain.Message? _selectedMessage;

  bool idExists = false;


  late List<ItemModel> menuItems;
  List<CustomPopupMenuController> _controllers = []; //* special menu stuff






  @override
  void initState() {
    super.initState();

    newdatabase.getAllUsers().then((users) { // I feel like there is a better way of doing this tbh  
      setState(() {
        
        idExists = users.any((user) => user.serverId == widget.userId);
      });
      
      if(idExists){
        newdatabase.getAllMessagesInConvo(widget.myUuid, widget.userId).then((messages) { //widget.userId
          print("this is the thing 11");
          messages.forEach((msg){
            var sender= false;
            if (msg.senderId == widget.myUuid){ // how we get if we sent the message
              sender= true;
              print("is the sender: $sender");
            }
                        print("aint no gama");
            msgmain.Message? convertedParent;

            middleware.Message? _parentMsg;

            if (msg.repliedToMsgId!=null){

              _parentMsg = messages.firstWhere(
                (m) => m.id == msg.repliedToMsgId,
              );

              convertedParent =
              msgmain.Message(id: _parentMsg.id!, text:_parentMsg.message,timestamp:_parentMsg.createdAt,
              isSender: _parentMsg.senderId == widget.myUuid? true:false); 
              // might want to make it sooo we can show the whole txt 
              //! (ie  (pers1.txtId1.txt="I love u"); (pers2.txtId2.replied2Id=txtId1, txtId2.txt="<3");
              //! (pers1.txtId3.replied2Id=txtId2, txtId3.txt="say it back" );)
              //? it will only go 1 layer deep (should we have more layers)
              
            }
            
            /* if (msg.repliedToId!=null){
              parentmsg = msg.repliedToId;
            } */
            print("we got her?");
            
            
            var convertedMsg = msgmain.Message/* (id: msg.id!, text:msg.message,timestamp:msg.createdAt,isSender:sender, 
            parentMessage:convertedParent ); */
            (id: msg.id!, timestamp: msg.createdAt, 
            text: msg.message, isSender: sender, parentMessage: convertedParent, isReplying: msg.repliedToMsgId!=null?true:false,
            );

            if (!_messages.contains(convertedMsg)) {

              print("printz: ${convertedMsg.text}");
              setState(() {
                _messages.add(convertedMsg); // SHIT ING WORKS
                //_controllers.add(CustomPopupMenuController());
              });
            }
            
          });
          
        });
      }
    });
    

    print("pogz");
    
    menuItems = [
      ItemModel(title: 'reply', icon: Icons.chat_bubble, function: (){// reply, 
                          setState(() {
                            _replying = true;
                          });
                          print("replying to msg: ${_selectedMessage!.text}");
                          _controllers[_controllerIndex].toggleMenu();
                          }), 
      ItemModel(title: 'copy', icon: Icons.copy, function: () async {
        
        await Clipboard.setData(ClipboardData(text: _selectedMessage!.text));
        _controllers[_controllerIndex].toggleMenu();

      }), // copy
      ItemModel(title: 'more', icon: Icons.list_outlined), // more (deleting/selecting multiple chat bubbles)
      //! Message stays on the server incase [Y̸̝͗Ö̵̲́U] say somthing incriminating (ㆆ_ㆆ)  (D̶O̶N̶T̶ ̶B̶E̴ ̵A S̴N̷I̸TCH!!!1!!)
      
    ];
    
  }

  @override
  Widget build(BuildContext context) {

  return Scaffold(
    appBar: ChatDetailPageAppBar(userName: widget.userName, userAvatar: widget.userAvatar, isOnline: widget.isOnline, 
    preferredSize: Size.fromHeight(kToolbarHeight), isKnownUser: widget.isKnownUser),
    body: 

        Column(
          children: [
            /// add a menu to the background
            Expanded(
              child: ListView.builder(
                reverse: true, // reverse to start at the bottom
                shrinkWrap: true,
                itemCount: _messages.length,

                itemBuilder: (context, index) {

                  final message = _messages[_messages.length - index -1];
                  _controllers.add(CustomPopupMenuController());

                    return SwipeTo(
                      onLeftSwipe: (){
                        setState(() {
                            _replying = true;
                            _selectedMessage = message;
                          });
                      },
                      // it has to 'reload' msgs every time you do this(has to be a better way)
                        
                      child: CustomPopupMenu(  
                        controller: _controllers[index],
                        pressType: PressType.singleTap,
                        menuOnChange: (isOpen) {
                          setState(() {
                            print("selected message: ${message.text}");
                            
                            _controllerIndex = index;
                            
                            _selectedMessage = message;});
                          
                        },
                        
                        menuBuilder: _chatOptionsMenuz,
                        showArrow: false,
                        child: Container(
                          child: BubbleUserNormal(text: message.text,isSender: message.isSender,
                            associatedMessage: message.parentMessage,isReplying: message.isReplying,
                            color: message.isSender? Color.fromARGB(255, 168, 216, 255) : Color.fromARGB(255, 255, 255, 255),
                            colorComplement: message.isSender? Color.fromARGB(255, 41, 153, 245): Colors.white38,
                          ),
                        ),
                      ),
                      
                    );

                },
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(0,8.0,0,0),
              
              child: MessageBar( //! we need to switch up the the app bar to make somthing more better
                replying: _replying,
                replyingTo: _selectedMessage,
                onTextChanged: _onTextChanged,
                onSend: _onPressSend,
                onTapCloseReply: _onTapCloseReply,
                //! we want to get the text from the text field
                
                actions: [
                  InkWell(
                    child: Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 24,
                    ),
                    onTap: () {},
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8, right: 8),
                    child: InkWell(
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.green,
                        size: 24,
                      ),
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              
            ),
          ],
        ),

  );
  
  

  }

  Widget _image() {
    return Container(
      constraints: BoxConstraints(
        minHeight: 20.0,
        minWidth: 20.0,
      ),
      child: CachedNetworkImage(
        imageUrl: 'https://i.ibb.co/JCyT1kT/Asset-1.png',
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            CircularProgressIndicator(value: downloadProgress.progress),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    );
  }

  void _changeSeek(double value) {
    setState(() {
      audioPlayer.seek(new Duration(seconds: value.toInt()));
    });
  }

  void _playAudio() async {
    final url =
        'https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_700KB.mp3';
    if (isPause) {
      await audioPlayer.resume();
      setState(() {
        isPlaying = true;
        isPause = false;
      });
    } else if (isPlaying) {
      await audioPlayer.pause();
      setState(() {
        isPlaying = false;
        isPause = true;
      });
    } else {
      setState(() {
        isLoading = true;
      });
      await audioPlayer.play(url as Source);
      setState(() {
        isPlaying = true;
      });
    }

    audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        duration = d;
        isLoading = false;
      });
    });
    audioPlayer.onDurationChanged.listen((Duration p) {
      setState(() {
        position = p;
      });
    });
    audioPlayer.onPlayerStateChanged.listen((event) {
      setState(() {
        isPlaying = false;
        duration = new Duration();
        position = new Duration();
      });
    });
  }

  // we need a way to adjust the size of the menu (how many columns)
  Widget _chatOptionsMenu(String title, IconData icon) { 
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        icon,
                        size: 20,
                        color: Colors.white,
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 2),
                        child: Text(
                          title,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  )
              
    );
  }

  Widget _chatOptionsMenuz() { // we need a way to adjust the size of the menu (how many columns)
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Container(
        width: 300,
        color: const Color(0xFF4C4C4C),
        child: GridView.count(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          crossAxisCount: 5,
          crossAxisSpacing: 0,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: menuItems
              .map((item) => InkWell(
                onTap: () {
                  item.function!.call();
                  
                },
                child: Column(
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
                  )),
              )
              
              .toList(),
        ),
      ),
    );
  }

  void _onTextChanged(String text) {

    print(text);
  }

  void _onPressSend(String text) {

    
    if (!idExists){ // we could check what the previous page was (new users or known users)?
      databaseHelper.addUserToLocalDb(widget.userId);
      print("added user: ${widget.userId}");
      
      //! DUMBASS TANGENT!!
      // "zombie process" is a process that that isnt cleaned up before X, (X=sleep, or other process)
      // if press button{goto page, laod ads, delete previous page: VS goto page, delete previous page, load ads}
    }
    
    _sendMsg(text, false, _replying);

  }
  void _sendMsg(String text, bool isCorrecting, bool isreplying) async {
    var curDateTime = DateTime.now();

    int localMsgId = 0;
    

    var convertedMsg = middleware.Message(message:text, createdAt:curDateTime, senderId: widget.myUuid, 
    receiverId: widget.userId,repliedToMsgId: isreplying? _selectedMessage!.id:null, 
    ); //! translated/literated booleans
    
    
    
    newdatabase.insertMessage(convertedMsg).then((msg){
      if (msg.id!=null){
        localMsgId = msg.id!;
        final isReplying= msg.repliedToMsgId!= null? true:false;
        
        final localmsg = msgmain.Message(id: localMsgId, timestamp: msg.createdAt, 
        text: msg.message, isSender: true, parentMessage: _selectedMessage, isReplying: isReplying,); 

        messageCreate(localmsg);}
    });


    try { 
      
      final messageserverInfo = await newdatabase.getMessage(_selectedMessage!.id);

      await _supabaseClient.from('messages').insert(
        {
          
          'message': text,
          'sender_id':widget.myUuid,// 38,

          'replied_id': isreplying? messageserverInfo.serverId:null, // we need to get server uuid
          'receiver_id':  widget.userId,
          'created_at': curDateTime.toIso8601String() // have to convert to json before sending it 
        },

      ).select('id').then((value){
        int serverMessageId = value[0]['id'];

         // a dumbass work around
          newdatabase.addMessageServerId(localMsgId, serverMessageId.toString()); // we want to add the servers ID after we add to local db
          
        print("update completed");
        
      },
      onError: (error){
        print(error);
      }); 

      if(_selectedMessage!=null){
        
        print("replying to: ${_selectedMessage!.id} - ${_selectedMessage!.text}");
      }
      setState(() {
        
        _replying = false;
        _selectedMessage = null;
      });
      
      // You can perform additional actions here, such as updating the UI
    } catch (error) {
      // Handle any errors that may occur
      print('Error sending message: $error');
      /* holdMessage = db.MessagesCompanion(createdAt: drift.Value(curDateTime), message: drift.Value(text), receiverId: drift.Value(sendToId),
       senderIsMe: drift.Value(true)); */
    }
  }

  void _onTapCloseReply() { // wtf does this do??? (OOH. stop repling to this a txt msg)
    setState(() {
      _replying = false;
      _selectedMessage = null;
    });
  }

  // Function to add a new message to the _messages list, 
  ////? we need a way to make sure that the message was sent and not just in local db
  void messageCreate(msgmain.Message message) {
    // idk how to use message type atm ＞﹏＜
    
    setState(() {
      _messages.add(message);
    });
    
  }
  
  void messageRead(MessageTypes message) {
    setState(() {
      _messages.last;
    });
  }

  void messageRecent(MessageTypes message) {
    setState(() {
      _messages.last;
    });
  }
  
  void messageUpdate(MessageTypes message) {
    // we dont want to allow users to edit/update their txts, idk if itll help with learning(think it o)
    setState(() {
      _messages.add(_messages.last); //TODO: FIX THIS!!!
    });
  }

  void messageDelete(MessageTypes message) {
    setState(() {
      //_messages.remove(); // we need to get the 'selected' message
    });
  }
  

  // Helper method to determine if a message is an image message
  bool isImageMessage(MessageTypes message) {
    // Replace with your logic to determine if the message is an image message
    return message.type == MessageType.Image;
  }

  // Helper method to determine if a message is an audio message
  bool isAudioMessage(MessageTypes message) {
    // Replace with your logic to determine if the message is an audio message
    return message.type == MessageType.Audio;
  }

  


  
}






enum MessageType {
  Text,
  Image,
  Audio,
}

class MessageTypes {
  String? text;
  String? imageUrl;
  String? audioUrl; // this is actually an audio msg
  MessageType type;
  bool isMe;

  MessageTypes({this.text, this.imageUrl, this.audioUrl, required this.type, this.isMe = false});
}

