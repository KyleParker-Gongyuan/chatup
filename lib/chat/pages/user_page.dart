
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:carousel_slider/carousel_slider.dart';

import 'package:chatup/chat/components/imagefunctions.dart';
import 'package:chatup/chat/model/user_avatar.dart';
import 'package:chatup/chat/pages/new_chat_details.dart';




class UserProfile extends StatefulWidget{

  String userName;
  String? userAvatar;

  String userId; // if == self get local data on
  bool isOnline;
  bool isKnownUser;
  List<String>? images;
  DateTime dob;
  String myUuid;
  String userBio;


  // if is connected to the server, check if still connected every 5-10 mins?
  
  //! if user in local db: else user in server db
  // we will always have the user Id right? so we should just have to search if we have that id else 
  

  UserProfile({required this.userName, required this.isOnline, required this.userAvatar, required this.userId, 
  required this.isKnownUser, required this.images, required this.dob,required this.myUuid, required this.userBio});

  @override
  _UserProfile createState() => _UserProfile(); //* the widget that a person sees 

}

class _UserProfile extends State<UserProfile> { //* for selecting a user to chat with (send msgs with)
  String userIntroduction = 'I am a passionate developer with experience in Flutter and Dart.';
  final double coverHeight = 140;
  final double profileHeight = 144;
  
  // Save today's date.
  final today = DateTime.now();

  final List<List<PointsType>> items = [
    [
      PointsType(icon: Icons.home, text: 'Home', points: 1),
      PointsType(icon: Icons.data_saver_on, text: 'Search', points: 2),
      PointsType(icon: Icons.person, text: 'Favorites', points: 3),
      PointsType(icon: Icons.ac_unit, text: 'Settings', points: 4),
      PointsType(icon: Icons.business, text: 'personz', points: 5),
    ],
    [
      PointsType(icon: Icons.ac_unit, text: 'Settings', points: 4),
      PointsType(icon: Icons.business, text: 'personz', points: 5),
    ],
  ];

  int currentIndex = 0;
  int itemsPerPage = 5;
  late final List<String>showableUuid;

  @override
  void initState() {
    showableUuid = widget.userId.split('-');
    super.initState();
    
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
      ), 
      body: Column(
        //alignment: Alignment.center,
        children: [
          // the cover image will be 1: a user selectable image (think myspace or twitter), 2: a map of where this user is in the world (for local meetups?)
          buildCoverImage(),
          buildProfileImage(), // the info that we have in this row
          
          buildProfilespoints(),
          // we need to have a
         /*  Divider(
            color: Colors.grey,
            thickness: 1,
            height: 1,
          ), */
          /* Row(children: [
            Container(
              padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: Text("BIO:", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
              )
          ],), */
           Container(
            height: 1,
            width: 300,
            color: Colors.grey,
          ),
          buildProfilesbio(),
          Spacer(), // this is as it says its a spacer (it space between from last widget(top) and next widget(bottom))
          followOrMessage(), // do we even want to follow the user?????(why would we????)

        ],
      ),
      
    );
  }

  //we probably want to show a photogallary at the top and then show location after wared
  //IE veritcal scroll for pics then hor scroll for map and itll show user location

  //the background img for this user 
  Widget buildCoverImage() => Container(
    color: Colors.grey, // replace with place in world (location used for local contacting? and things like volunteering)
    child: widget.isKnownUser ?
    Image(image: MemoryImage(Imagefunctions().dataFromBase64String(widget.userAvatar!)))
    :  CachedNetworkImage(// change this to the map (maybe make it so that only if ur a pro user u can change ur background?)
      imageUrl: widget.images != null ? widget.images![0] : 'https://images.unsplash.com/photo-1661956601030-fdfb9c7e9e2f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDF8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1942&q=80', 
      width: double.infinity,
      height: coverHeight,
      fit: BoxFit.cover,
    ),  //! We could use 2 tables (user  and userImageGallary, query userImages)
  );



  //! we can do it as a if profile then use the list else use a single(will this cause a problem?)

  // the location of this user 
  Widget buildProfilesMap() => Container(
    color: Colors.grey, // replace with place in world (location used for local contacting? and things like volunteering)
    child: CachedNetworkImage(
      imageUrl:'https://images.unsplash.com/photo-1661956601030-fdfb9c7e9e2f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDF8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1942&q=80',
      width: double.infinity,
      height: coverHeight,
      fit: BoxFit.cover,
    ),
  );
  Widget buildProfileImage() => Container(
    child: Row(children: [

      CircleAvatar( // user image
        radius: profileHeight / 4,
        backgroundColor: Colors.grey,
        backgroundImage: widget.userAvatar!.isNotEmpty ? 
          ((widget.isKnownUser) ? MemoryImage(Imagefunctions().dataFromBase64String(widget.userAvatar!)) 
          as ImageProvider<Object> : NetworkImage(widget.userAvatar!)) : null,
        child: widget.userAvatar!.isEmpty ? letterImageWidget(widget.userName[0]) : null,
      ),
      
      Expanded(
        flex: 1,
        child: Container(
          color: Colors.amber,
          child: Row(children: [
            Column(children: [ //* A G N-i (AGE, GENDER, NAME, id )
              ageGenderContainer(Icons.female, (today.year - widget.dob.year)), // age and gender
              Text(widget.userName),
              Text('${widget.userName}-${showableUuid[3]}', style: TextStyle(fontSize: 10,color: Colors.grey.shade500),),

            ],),
            
          ],),
        ),
      ),

    ],
    
    ),
  );


  
  Widget pointTypeWidget(List<PointsType> pointinfo) =>Container(
    margin: EdgeInsets.all(5),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.blueAccent)
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: pointinfo.map((a) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              child: Column(
                children: [
                  Icon(a.icon),
                  Text(a.text),
                  Text(a.points.toString()),
                ],

          ),
        );
      }).toList(),
    )
  );
  
  
   //* A G Ni (AGE, GENDER, NAME (i)d)
  Widget ageGenderContainer(IconData icon,int age,) => Container( //* A G Ni (AGE, GENDER, N(i)AME)
    padding: EdgeInsets.fromLTRB(0, 1, 6, 1),
    decoration: BoxDecoration(
      color: Color.fromARGB(255, 221, 153, 233),
      border: Border.all(
        
      ),
      borderRadius: BorderRadius.all(Radius.circular(20))
    ),
    child: Row(
      children: [
        Icon(icon, size: 18,),
        Text(age.toString()),
      ],
    ),
  );
  // do we even want to follow the user?????(why would we????)
  Widget followOrMessage() => Container( // do we even want to follow the user?????(why would we????)
    color: Colors.green,
    child: Align(
      alignment: Alignment.bottomCenter,
      //child: Row(children: [

        /* ElevatedButton.icon( //? i dont think we are gonna have the follow feat or the social media type beat system
          icon: Icon(
            Icons.add_circle_outline
          ),
          onPressed: () {
            Navigator.push(//! THIS goto 'X' page
                    context,
                  MaterialPageRoute(builder: (context) => 
                    UserChatRoom(userName: widget.userName, userAvatar: widget.userAvatar, userId: widget.userId,
                      isOnline: widget.isOnline, isKnownUser: widget.isKnownUser, myUuid: widget.myUuid)
                  ),
                  );
            return ;
          },
          label: const Text('Message this user')
        ) */
        child: ElevatedButton.icon( 
          icon: const Icon(
            Icons.message
          ),
          onPressed: () {
            Navigator.push(//! THIS goto 'X' page
                    context,
                  MaterialPageRoute(builder: (context) => 
                    UserChatRoom(userName: widget.userName, userAvatar: widget.userAvatar, userId: widget.userId,
                      isOnline: widget.isOnline, isKnownUser: widget.isKnownUser, myUuid: widget.myUuid)
                  ),
                  );
            return ;
          },
          label: const Text('Message this user')
        )
      //],)
    )


    
  );

  Widget buildProfilespoints() => Container(
    // foreach point type add new item
    
    child: Row(children: [
      Expanded(
        child:CarouselSlider(
          options: CarouselOptions(
            viewportFraction: 1, // how much of the item('s) you see in carousel window(viewport) (0.5 would show 2 items)
            height: 80.0,
            enableInfiniteScroll: true,
            onPageChanged:(index, reason) {
              setState(() {
                print(reason.toString());
                currentIndex = index;
              });
            },
            scrollDirection: Axis.vertical,

            ),
          items: items.map((i) {
            return Builder(
              builder: (BuildContext context) {
                return pointTypeWidget(i);
              },
            );
          }).toList(),
        ),
      ),
      Column( // dot index 
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < items.length; i++)
            Container(
              height: 13,
              width: 13,
              margin: EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: currentIndex == i ? Colors.blue : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 2,
                    blurRadius: 3,
                    offset: Offset(2, 2)
                  )
                ]),
              )
        ]
      )
    ],)
  );

  Widget buildProfilesbio() => Container(
    padding: EdgeInsets.all(10),
    child: Column(children: [
      Row(children: [ //we could do it as another carousel (bio, games(user has played), pics, etc etc)
            Container(
              
              child: Text("BIO:", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
              )
          ],),
          Container(
            height: 1,
            width: 300,
            color: Colors.grey,
          ),
          Row(children:  [
            const Divider(
              height: 40,
            ), 
            Text(widget.userBio),
          ]),
    ],),
  );
}



//! we should do somthing with the image to make sure it aint sus/allow ppl to report (for pics) and then put those pics in a list/AI


class PointsType{ // probably want the senders image if we do groups
  String text;
  IconData icon;
  int points; // maybe make htis a double?
  PointsType({required this.text, required this.icon, required this.points });
}