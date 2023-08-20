

import 'package:flutter/material.dart';

import 'package:chatup/chat/components/user_widget.dart';
import 'package:chatup/libV2/newdata/data_helpa.dart';
import 'package:chatup/libV2/newdata/db_data_translation.dart';
import 'package:chatup/libV2/newdata/registry.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

//import 'package:chatup/chat/chat_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//import '../backend/db/middle_db.dart' as mid;





class ContactsPage extends StatefulWidget{

  String myUuid;
  ContactsPage({required this.myUuid});

  //ContactsPage({required this.contacts, required this.messageDatabase});
  late Function(Map<String, dynamic>) addUserCallback; // Add this line

  //const KnownUsersPage({required this.addUserCallback});


  
  //late final Function(Map<String, dynamic>) addUserCallback;
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ContactsPage> {


  //?List<Message> msgFromUser = []; // List of most recent message from each known user
  //we want to put the chatUsers in a searchable list when ppl want to find (new) ppl //! (TXT will be a snippet of their bio)


  bool isLoading = false;

  // if user has 0 contacts none we should send a bot/replika type bot


  final database = registry.get<DatabaseHelper>(); 
  
  @override
  void initState() {
    //we need to get the last message in list from all users
    //database.getLastMessageFromUsers();
    super.initState();

    
    refreshUsers();
    
    
          //* the replika type shouldnt be the only person they talk with (probably)

    
    
    
  }

  Future refreshUsers() async{
    setState(() => isLoading = true); // loading from databse

    //this._knownUsers = await PrimeDataBase.instance.readAllUser();

    setState(() => isLoading = false); // finished
  }
  

  


  //TODO: per user chatUsers[index].userName
  // we really want all the messages to be seen all the time (in books, games, etc)
  
  RefreshController _refreshController = RefreshController(initialRefresh: false, );

  void _onRefresh() async{
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  

  void _onLoading() async{
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    //items.add((items.length+1).toString());
    
    //! we need to add the connection to the supabase server to this
    if(mounted){
      setState(() {});}
    _refreshController.loadComplete();
  }
  
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
                        const Text("Contacts",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
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
                FutureBuilder<List<BigUser>>(
                  future: database.getAllUsersNotSelf(localId: 0),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // Show a loading indicator while fetching users
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}'); // Show an error message if fetching users fails
                    } else if (!snapshot.hasData) {
                      return Text('No users found'); // Show a message when there are no users available
                    } else {
                      /* presenceChannel = Supabase.instance.client.channel("presence");
                      presenceChannel.subscribe();
                      presenceChannel.on("presence_state", (payload) {
                        var state = payload["data"]["state"];
                        var userId = payload["data"]["user_id"];
                        print("User $userId is $state");
                      }); */
                      // listen to presence states

                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        shrinkWrap: true,

                        itemBuilder: (context, index) {
                          BigUser user = snapshot.data![index];
                          return FutureBuilder<Message>(
                              future: database.getLastMessageForChatRoom(user.serverId),//fetchMessage(user),
                              //find a better way of doing this
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Text('Loading users...'); // Show a loading message while fetching the message
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}'); // Show an error message if fetching the message fails
                                } else if (!snapshot.hasData) {
                                  return Text('No Users found'); // Show a message when there is no message available
                                } else {
                                  bool isOnline = false;
                                  
                                  Supabase.instance.client.channel('channel_name').on(
                                    RealtimeListenTypes.postgresChanges,
                                    ChannelFilter(event: '', schema: '*'), // we need to get info form user(how to?)
                                    (payload, [ref]) {
                                      
                                      print("wtf is this data? ${payload['new']}");
                                      
                                    },
                                  ).subscribe();
                                  
                                  
                                  String recentMessage = snapshot.data!.message;
                                  return FutureBuilder<bool>(
                                    future: isUserOnline(user.id.toString()),
                                    builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                                      if (snapshot.connectionState == ConnectionState.done) {
                                        if (snapshot.hasError) {
                                          return Text('Error: ${snapshot.error}');
                                        } else {//if (snapshot.hasData) {
                                          isOnline = snapshot.data!;
                                          print(checkconncetion(user.id.toString())? "user is online: ${user.username}"
                                          :"user is offline: ${user.username}");
                                          

                                          //return Text('User is ${isOnline ? 'online' : 'offline'}');
                                          return UserCard(//TODO: will want to get this info from the sever
                                            userName: user.username,
                                            recentText: recentMessage,
                                            userAvatar: user.imageAvatar, // we also need to get the url from the server not from the app //*^____^*\\
                                            time: DateTime.now(), //message.createdAt, // wtf do we have to do this????
                                            isMessageRead: (index == 0 || index == 3) ? true : false, // index 0 = current msg, index = the past 3 texts(idk)?
                                            isMessageReplied: (index == 0 || index == 3) ? true : false, // a comment and reply (this doesnt matter at this stage?)
                                            isFixed: (index == 0 || index == 3) ? true : false, // fix a msg(translate the stuff)
                                            isKnownUser: true, // we 'know' this user if we have send a msg(or they send us a msg)
                                            userId: user.serverId,  // user.id,
                                            //isOnline: isOnline, // checkconncetion(user.id.toString())//isonline,
                                            dob: DateTime.parse(user.dob),  // user.id,

                                            isOnline: false, //checkconncetion(user.id.toString()),//isonline,
                                            unreadMessagesCount: 0, // need to make this beter
                                            myUuid: widget.myUuid, // need to make this beter

                                            //* we should be able to get some of the data later (async the bio,age,etc/ if they press the pfp then await)

                                          );
                                        }
                                      }
                                      return CircularProgressIndicator();
                                      
                                    },
                                  );

                                  
                                }
                              },
                            );
                          
                        },
                      );
                    }
                  },
                )
                
              ],
            ),
          ),
      
      ),
    );/* return FutureBuilder<List<mid.BigUser>>(
      future: database.getAllUsersNotSelf(userId: 25),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show a loading indicator while fetching users
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Show an error message if fetching users fails
        } else if (!snapshot.hasData) {
          return Text('No users found'); // Show a message when there are no users available
        } else {

          /* presenceChannel = Supabase.instance.client.channel("presence");
          presenceChannel.subscribe();
          presenceChannel.on("presence_state", (payload) {
            var state = payload["data"]["state"];
            var userId = payload["data"]["user_id"];
            print("User $userId is $state");
          }); */
          // listen to presence states
          

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              mid.BigUser user = snapshot.data![index];
              return FutureBuilder<mid.Message>(
                  future: database.getLastMessageForChatRoom(user.id),//fetchMessage(user),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('Loading users...'); // Show a loading message while fetching the message
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}'); // Show an error message if fetching the message fails
                    } else if (!snapshot.hasData) {
                      return Text('No Users found'); // Show a message when there is no message available
                    } else {
                      bool isOnline = false;
                      
                      Supabase.instance.client.channel('channel_name').on(
                        RealtimeListenTypes.postgresChanges,
                        ChannelFilter(event: '', schema: '*'), // we need to get info form user(how to?)
                        (payload, [ref]) {
                          
                          print("wtf is this data? ${payload['new']}");
                          
                        },
                      ).subscribe();
                      
                      String recentMessage = snapshot.data!.message;
                      return FutureBuilder<bool>(
                        future: isUserOnline(user.id.toString()),
                        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {//if (snapshot.hasData) {
                              isOnline = snapshot.data!;
                              print(checkconncetion(user.id.toString())? "user is online: ${user.username}"
                              :"user is offline: ${user.username}");
                              

                              //return Text('User is ${isOnline ? 'online' : 'offline'}');
                              return UserWidget(//TODO: will want to get this info from the sever
                                userName: user.username,
                                recentText: recentMessage,
                                userAvatar: user.imageAvatar, // we also need to get the url from the server not from the app //*^____^*\\
                                time: DateTime.now(), //message.createdAt, // wtf do we have to do this????
                                isMessageRead: (index == 0 || index == 3) ? true : false, // index 0 = current msg, index = the past 3 texts(idk)?
                                isMessageReplied: (index == 0 || index == 3) ? true : false, // a comment and reply (this doesnt matter at this stage?)
                                isFixed: (index == 0 || index == 3) ? true : false, // fix a msg(translate the stuff)
                                isKnownUser: true, // we 'know' this user if we have send a msg(or they send us a msg)
                                userId: user.id.toString(),  // user.id,
                                //isOnline: isOnline, // checkconncetion(user.id.toString())//isonline,
                                dob: DateTime.parse(user.dob),  // user.id,

                                isOnline: checkconncetion(user.id.toString()),//isonline,
                                usersLangs: ["eu"],
                                unreadMessagesCount: 0, // need to make this beter
                                //* we should be able to get some of the data later (async the bio,age,etc/ if they press the pfp then await)

                              );
                            }
                          }
                          return CircularProgressIndicator();
                          
                        },
                      );

                      
                    }
                  },
                );
              
            },
          );
        }
      },
    ); */*/*/
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
