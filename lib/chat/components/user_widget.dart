
//? we will use the flyer stuff instead (it should be easier)


import 'package:flutter/material.dart';

import 'package:chatup/chat/components/imagefunctions.dart';
import 'package:chatup/chat/model/user_avatar.dart';
import 'package:chatup/chat/pages/user_page.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

//import 'package:screenshot/screenshot.dart';

import '../pages/new_chat_details.dart';
//import 'package:chatup/chat/pages/user_page';

import 'package:badges/badges.dart' as badges;
//import 'package:dash_flags/dash_flags.dart';



import 'dart:core';




//! VVV this is for when u and a user contact eachother VVV (the 2 users 'connected' by saying hi or whatever)
class UserCard extends StatefulWidget{
  String userName;
  String recentText;
  String? userAvatar;
  DateTime time;
  bool isMessageRead;
  bool isMessageReplied;
  bool isFixed;
  bool isKnownUser;
  String userId;
  bool isOnline;
  DateTime dob;

  int unreadMessagesCount;
  String myUuid;


  // if is connected to the server, check if still connected every 5-10 mins?
  
  UserCard({required this.userName, required this.recentText,required this.userAvatar, required this.time, required this.isOnline,
  this.isMessageRead = true, this.isMessageReplied = false, this.isFixed = false, required this.isKnownUser, required this.userId,
   required this.unreadMessagesCount, required this.dob, required this.myUuid});
  @override
  _User_widget createState() => _User_widget(); //* the widget that a person sees 
}

class _User_widget extends State<UserCard> { //* for selecting a user to chat with (send msgs with)
  
  final _supaQuery = Supabase.instance.client.from('user_image_gallery');


  @override
  void initState() {
  
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    print("the useravatar: ${widget.userAvatar}");
    
    // we need to 2 gesture detectors on the txt and the avatar
    return GestureDetector( //! Select a user to chat with 
      onTap: () async{ // need a way to goto the profile itself not to chat page
        print("clicked user ${widget.userName}");
        //final _supaQuery = Supabase.instance.client.from('user_image_gallary');

        //final gallaryList = await _supaQuery.select().eq('user_id', widget.userId);//(send those images to the userpage)
        //? I need to change this to uuid (but whatever)
        print("clicked user ${widget.userName}");
        // we are going to get a list 
        // ignore: use_build_context_synchronously
        Navigator.push(context, MaterialPageRoute(builder: (context){ //? goes to the chat page
        
          if (widget.isKnownUser){ //! we want to make sure the user selects the pfp on just wants to talk
            print("chat screen");
            return UserChatRoom(userName:widget.userName, userAvatar:widget.userAvatar, userId:widget.userId,
              isOnline: widget.isOnline,isKnownUser: widget.isKnownUser,myUuid: widget.myUuid);
            //return ChatScreen(userName:widget.userName, userAvatar:widget.userAvatar,
            // userId: widget.userId, isOnline: widget.isOnline,);
          }
          
          return UserProfile(userName:widget.userName, userAvatar:widget.userAvatar, userId:widget.userId,isOnline: widget.isOnline,
            isKnownUser: widget.isKnownUser, images:null, dob: widget.dob,
            myUuid: widget.myUuid, userBio: widget.recentText);
            //! we need to make the images in the user profile better (ie we need to get the users links to images)
          // WHY TF  ARE YOU CAUSING PROBLEMS!!! VVVVVVVV
          //return null;

          // or the abt users page
          //// TODO: preload pages
          
          //? use ChatUI(flyer) thing (ITS GARBAGE TBH)
          //? dash-chat flutter (it sucks or im bad)

        }));

      },//! move to the known user list
      child: Container(
        padding: const EdgeInsets.only(left: 16,right: 16,top: 10,bottom: 10), // maybe add a dividing line
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[

                  badges.Badge(
                    position: badges.BadgePosition.topEnd(top: 2, end: 5),
                    badgeContent: Text(widget.unreadMessagesCount.toString()),
                    showBadge: false,
                    child: CircleAvatar(
                      backgroundImage: widget.userAvatar!.isNotEmpty ? 
                      ((widget.isKnownUser) ? MemoryImage(Imagefunctions().dataFromBase64String(widget.userAvatar!)) 
                        as ImageProvider<Object> : NetworkImage(widget.userAvatar!)) : null,
                      // widget.userAvatar == null ? NetworkImage(widget.userAvatar) : ,
                      //AssetImage(widget.userAvatar), // we want to use an actual image(not only from local)
                      maxRadius: 30,

                        // MemoryImage(dataFromBase64String(widget.userAvatar!)), //TODO: ALLOW GIFS!!!!!
                      //! how big should this be, 25 or 30?
                      child: widget.userAvatar!.isEmpty ? letterImageWidget(widget.userName[0]) : null, 
                    ),
                     // get number of unread messages
                  ),
                  const SizedBox(width: 10,),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          badges.Badge(
                            position: badges.BadgePosition.topStart(top: -15, start: -0) ,//bottomEnd(bottom: -5, end: 0),
                            showBadge: false,

                            badgeStyle: const badges.BadgeStyle(
                              shape: badges.BadgeShape.square,
                              //! this should be dynamic depending on what flag and what theme, (if flag has white use black etc)
                              badgeColor: Color.fromARGB(255, 42, 16, 72),
                              
                              padding: EdgeInsets.all(1),
                              elevation: 0,
                            ),
                            child: Text(widget.userName),
                          ),
                          
                          const SizedBox(height: 6,),
                          Text(widget.recentText, style: TextStyle(fontSize: 14,color: Colors.grey.shade500),),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(widget.time.toString(),style: TextStyle(fontSize: 12,color: widget.isMessageRead? Colors.grey.shade500:Colors.pink),),
                      const SizedBox(height: 6,),
                      badges.Badge(showBadge: widget.isOnline, badgeStyle: badges.BadgeStyle(badgeColor: Colors.green),),
                      //Text("BAGE OF UNSEEN! (numebr of undseen)"),
                    ],
                  ),
                ],
              ),
            ),
            //Text(widget.time.toString(),style: TextStyle(fontSize: 12,color:Colors.grey.shade500),),
          ],
        ),
      ),
    );
  }

}





//! we should do somthing with the image to make sure it aint sus/allow ppl to report (for pics) and then put those pics in a list/AI


