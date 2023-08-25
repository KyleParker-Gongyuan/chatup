
//? we will use the flyer stuff instead (it should be easier)


import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:carousel_slider/carousel_slider.dart';

 
import 'package:chatup/chat/components/imagefunctions.dart';
import 'package:chatup/chat/model/user_avatar.dart';
import 'package:chatup/libV2/newdata/data_helpa.dart';
import 'package:chatup/libV2/newdata/db_data_translation.dart';
import 'package:chatup/libV2/newdata/registry.dart';


class MyHomePage extends StatefulWidget{
  const MyHomePage({Key? key}) : super(key: key);



  @override
  _UserProfile createState() => _UserProfile(); //* the widget that a person sees 

}

class _UserProfile extends State<MyHomePage> { //* for selecting a user to chat with (send msgs with)
  String userIntroduction = 'I am a passionate developer with experience in Flutter and Dart.';
  final double coverHeight = 140;
  final double profileHeight = 144;
  final database = registry.get<DatabaseHelper>();

  // Save today's date.
  final today = DateTime.now();
  

  final List<List<PointsType>> pointList = [
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


  int currentIndex = 1;
  int itemsPerPage = 5;
  CarouselController carouselController = CarouselController();

  
  @override
  void initState() {
    super.initState();

    

  }
  
  @override
  Widget build(BuildContext context) {
      return Scaffold(
      appBar: userAppbar(),
      body: FutureBuilder(
                  future: database.getUser('0',false),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // Show a loading indicator while fetching users
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}'); // Show an error message if fetching users fails
                    } else if (!snapshot.hasData) {
                      return Text('No users found'); // Show a message when there are no users available
                    } else {
                      return Column(
        //alignment: Alignment.center,
        children: [
          buildCoverImage(),
          buildProfileImage(snapshot.data!),
          
          //buildProfilespoints(),
          Container(
            height: 1,
            width: 300,
            color: Colors.grey,
          ),
          buildProfilesbio(snapshot.data!.bio),
          Spacer(),

        ],
      );
                    }
                  },
                )
      
      
    );
  }

  //the background img for this user 
  Widget buildCoverImage() => Container(
    color: Colors.grey,
    child: CachedNetworkImage(
      imageUrl: 
      'https://images.unsplash.com/photo-1661956601030-fdfb9c7e9e2f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDF8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1942&q=80', 
      width: double.infinity,
      height: coverHeight,
      fit: BoxFit.cover,
    ),
  );


  // the location of this user 
  Widget buildProfilesMap() => Container(
    color: Colors.grey,
    child: CachedNetworkImage(
      imageUrl:'https://images.unsplash.com/photo-1661956601030-fdfb9c7e9e2f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDF8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1942&q=80',
      width: double.infinity,
      height: coverHeight,
      fit: BoxFit.cover,
    ),
  );
  Widget buildProfileImage(BigUser profileInfo) => Container(
    child: Row(children: [

      CircleAvatar( // user image
        radius: profileHeight / 4,
        backgroundColor: Colors.grey,
        backgroundImage: profileInfo.imageAvatar.isNotEmpty ? 
          MemoryImage(Imagefunctions().dataFromBase64String(profileInfo.imageAvatar)) 
          as ImageProvider<Object> : null,
        child: profileInfo.imageAvatar.isEmpty ? letterImageWidget(profileInfo.username[0]) : null,
      ),
      
      Expanded(
        flex: 1,
        child: Container(
          color: Colors.amber,
          child: Row(children: [
            Column(children: [ //* A G N-i (AGE, GENDER, NAME, id )
              ageGenderContainer(Icons.female, (today.year - DateTime.parse(profileInfo.dob).year)), // age and gender
              Text(profileInfo.username),
              Text('${profileInfo.username}-${profileInfo.serverId.split('-')[3]}', style: TextStyle(fontSize: 10,color: Colors.grey.shade500),),

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
                currentIndex = index;
              });
              
              
            },
            scrollDirection: Axis.vertical,

            ),
          carouselController:carouselController,
          items: pointList.map((i) {
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
          for (int i = 0; i < pointList.length; i++)
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

  Widget buildProfilesbio(String bio) => Container(
    padding: EdgeInsets.all(10),
    child: Column(children: [
      Row(children: [
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
            Text(bio),
          ]),
    ],),
  );
  
  AppBar userAppbar(){
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.blue[400],
      flexibleSpace: SafeArea(
        child: Container(
          padding: EdgeInsets.only(right: 16),
          child: const Row(
            children: <Widget>[
              Text("my profile", style: TextStyle(fontSize: 32),)

            ],
          ),
        ),
      ),
    );}
}
  

//! we should do somthing with the image to make sure it aint sus/allow ppl to report (for pics) and then put those pics in a list/AI


class PointsType{ // probably want the senders image if we do groups
  String text;
  IconData icon;
  int points; // maybe make htis a double?
  PointsType({required this.text, required this.icon, required this.points });
}
