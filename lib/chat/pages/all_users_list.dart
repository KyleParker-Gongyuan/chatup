


import 'dart:async';


import 'package:flutter/material.dart';

import 'package:chatup/chat/components/user_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



//! all user s and known users will just be a switch statement cuz it only has like 5 different things i think?



class FindUsersPage extends StatefulWidget{
  //bool onKnownUsersPage;
  //final Function(Map<String, dynamic>) addUserCallback; // Add this line

  String myUuid;
  //const FindUsersPage({required this.addUserCallback});
  FindUsersPage({required this.myUuid});


  //List<Map<String, dynamic>> messages;

  //FindUsersPage();
  //FindUsersPage({required this.allUsers});
//  FindUsersPage({required this.allUsers, required this.messages});

  @override
  //FindUsersPage({required this.onKnownUsersPage}); // to do 1 class for both known and unknown users might cause problems
  
  _FindUsersPageState createState() => _FindUsersPageState();
}

class _FindUsersPageState extends State<FindUsersPage> {
  
  
  List<Map<String, dynamic>> allUsers = [];

  final _supabaseFromProfilesTable = Supabase.instance.client.from('profiles').stream(primaryKey: ['id']);
  //late List<Map<String, dynamic>> allusers;

  //we want to put the chatUsers in a searchable list when ppl want to find (new) ppl //! (TXT will be a snippet of their bio)
  

  

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    
    super.dispose();
  }

  
  Future<void> _fetchData() async {
    // we dont need to fetch any data atm (what will we need to fetch with async?)
    //* hobbies, and anything that isnt put into the "recentText" section
    }
  RefreshController _refreshController = RefreshController(initialRefresh: false, );

  void _onRefresh() async{
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  

  void _onLoading() async{
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    //items.add((items.length+1).toString());
    
    //! we need to add the connection to the supabase server to this
    if(mounted){
      setState(() {});}
    _refreshController.loadComplete();
  }


  //TODO: per user chatUsers[index].userName
  
  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(),
      
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: Scaffold(
        body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16,right: 16,top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const Text("People",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
                          /* Container(
                            padding: EdgeInsets.only(left: 8,right: 8,top: 2,bottom: 2),
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.pink,
                            ),
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.add,color: Color.fromARGB(255, 71, 68, 69),size: 20,),
                                SizedBox(width: 2,),
                                Text("dont need?",style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),),
                              ],
                            ),
                          ) */ //! adding a specsific user/group (TBD)
                        ],
                      ),
                    ),
                  ),
                  /* Padding( // this is the stuff for the searching
                    padding: EdgeInsets.only(top: 16,left: 16,right: 16),
                    child: TextField(
                      style: TextStyle(color: Colors.black), // we should be able to just do this in the color scheme
                      decoration: InputDecoration(
                        hintText: "Search...",
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        prefixIcon: Icon(Icons.search,color: Colors.grey.shade400,size: 20,),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: EdgeInsets.all(8),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.grey.shade100
                          )
                        ),
                      ),
                    ),
                  ), */ //! add searching for a user
                  StreamBuilder(
                    stream: _supabaseFromProfilesTable,
                    builder: (context, snapshot) {
                      if(!snapshot.hasData){
                        return Center(child: CircularProgressIndicator());
                      }
                      

                      allUsers = snapshot.data!;
                      //allUsers = snapshot.data!;
                      allUsers.removeWhere((user) => user["user_id"] == widget.myUuid);
                      //allUsers = inz;

                      //inz.firstWhere((item) => item.removeWhere((key, value) => key == 'user_id'));

                      return ListView.builder( // all users on server //TODO: (options so that it doesnt give u ger with u want chi)
                        itemCount: allUsers.length,
                        shrinkWrap: true,
                        padding: EdgeInsets.only(top: 16),
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index){
                          final user = allUsers[index];
                          //final recentMessage = msgFromUser[index]; //! cuz dis dosent exist it causes problems
                          // we actually want all of this on local device(sqlite etc)......
                          
                          String pathToImage = user['avatar_url'];
                          print("IDOIT : $pathToImage");
                          if (pathToImage.isNotEmpty){
                            
                            pathToImage = Supabase.instance.client.storage.from("avatars").
                              getPublicUrl(user['avatar_url']);

                          }
                          /* Supabase.instance.client.channel('test').on( // test goes to all clients (users)
                            RealtimeListenTypes.postgresChanges,
                            ChannelFilter(event: 'sync'), // we need to get info form user(how to?)
                            (payload, [ref]) {
                              
                              print("wtf is this data? ${payload['new']}");
                              
                            },
                          ).subscribe(); */
                          /* Supabase.instance.client.channel('*').on(
                            RealtimeListenTypes.postgresChanges,
                            ChannelFilter(event: '*', schema: '*'),
                            (payload, [ref]) {
                              print('Change received: ${payload.toString()}');
                            },
                          ).subscribe(); */
                          Supabase.instance.client.channel('public:profiles:user_id=eq.user[user_id]').on(
                              RealtimeListenTypes.postgresChanges,
                              ChannelFilter(
                                event: 'UPDATE',
                                schema: 'public',
                                table: 'profiles',
                                filter: 'user_id=eq.user[user_id]',
                              ), (payload, [ref]) {
                            print('Change received: ${payload.toString()}');
                          }).subscribe();

                          //print(checkconncetion(user['id'])? "user is online: ${user['username']}"
                          //        :"user is offline: ${user['username']}");

                            // If has image, get image from storage. Else, create a letter image (W.I.P)

                            return UserCard( //TODO: will want to get this info from the sever
                              userName: user["username"],
                              recentText: user["bio"],
                              // we also need to get the url from the server not from the app //*^____^*\\
                              userAvatar: pathToImage,
                              //(user['avatar_url'] !="" || user['avatar_url']=="")? user['avatar_url']: user['avatar_url'], 
                              time: DateTime.now(),
                              dob: DateTime.parse(user["dob"]),
                              
                              isKnownUser: false, // we 'know' this user if we have send a msg(or they send us a msg)
                              userId: user["user_id"].toString(),
                              isOnline: false,
                              
                              unreadMessagesCount: 0, // need to make this beter
                              myUuid: widget.myUuid
                              //randomColor: Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
                            );
                        },
                      );
                    }
                  )
                ],
              ),
            ),
        ),
    );
  }


}


bool checkconncetion(String userid){
  bool isonline = false;
  var userchannel=Supabase.instance.client.channel('user_active');
  userchannel.on(
    RealtimeListenTypes.presence,
    ChannelFilter(event: 'sync'),
    (payload, [ref]) {
      final status = userchannel.track({'user_id': userid});
      print("pofzs: $status");
      
      
      
    },
  );

  userchannel.subscribe((status, [_]) {
    if (status == 'SUBSCRIBED') {
      final status = userchannel.track({'online_at': DateTime.now().toIso8601String()});
      print("otherpoz: $status");
      isonline=true;  
    }
  });
  return isonline;
}

Future<bool> isUserOnline(String userId) async {
  final channel = Supabase.instance.client.channel('online-users',opts: RealtimeChannelConfig(key: 'user1'));
  // You can replace 'userId' with the actual user ID you want to check
  
  //*String userId = 'your_user_id';
  Map<String, dynamic> presenceState = await channel.presenceState();
  return presenceState.containsKey(userId);
}