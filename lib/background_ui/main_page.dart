

import 'package:chatup/chat/pages/all_users_list.dart';
import 'package:chatup/chat/pages/contacts_list.dart';
import 'package:chatup/chat/pages/home_page.dart';
import 'package:chatup/libV2/newdata/data_helpa.dart' as db;
import 'package:chatup/libV2/newdata/registry.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';





  final supabaseClient = Supabase.instance.client;


class MainPage extends StatefulWidget {
  //const MyStatefulWidget({super.key});

  String myUuid;
  

  MainPage({required this.myUuid, super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  late PageController _pageController;

  late List<User> users;
  
  //late List<db.Message> allmessages;
  final database = registry.get<db.DatabaseHelper>();

  
  
  

    // Persist the stream in a local variable to prevent refetching upon rebuilds
  final nonStreamMes = supabaseClient.from('messages');



  //final usltrastream = supabaseClient.from('messages').select().eq('receiver_id',1).eq('received', false).asStream(); 
  //! we can use this 2 times or use 2 streams
  

  late final RealtimeChannel _lobbyChannel;
  List<String> _userids = [];



  
  @override
  void initState(){
    super.initState();
    _pageController = PageController();
    //! we want somthing like if on pageX subscribe to 
    //const myid=2;
    _lobbyChannel = Supabase.instance.client.channel(
      'public:profiles',//OLD: 'lobby',
      opts: const RealtimeChannelConfig(self: true),
      

      ); // this should be to say this user is online( if i know what im doing)
    
    //! we might even want to setup this even sooner(on splash screen?) because if we're in a game it might cause a problem
    //? need to test it
    _lobbyChannel.on(RealtimeListenTypes.presence, ChannelFilter(event: 'sync', schema: 'public', table: 'profiles'), 
      (payload, [ref]) {
        // Update the lobby count
        final presenceState = _lobbyChannel.presenceState();
        print("who tf is u? $presenceState"); // presencestate is the uuid of this users presence
        final isonline = (_lobbyChannel.isJoined || _lobbyChannel.isJoining); //gets if user is online or coming online

        setState(() { //! not sure if i need this tbh
        
        _userids = presenceState.values // we probably want to use this in contacts and all users list
            .map((presences) =>
                // OLD: (presences.first as Presence).payload['user_id'] as String)
                (presences.first as Presence).payload['user_id'].toString())
            .toList();
        });// ok 0 idea whats the dif from presencestate and .values
        print("all users in the 'lobby': $_userids"); //! we might just want to do this in the tabs (why have)
    })
    /* .on(RealtimeListenTypes.broadcast, ChannelFilter(event: 'game_start'), 
      //! I think we can use this for a typing indicator(idk guessing)
        (payload, [_]) {
      // Start the game if someone has started a game with you
      final participantIds = List<String>.from(payload['participants']);
      if (participantIds.contains(myUserId)) {
        final gameId = payload['game_id'] as String;
        widget.onGameStarted(gameId);
        Navigator.of(context).pop();
      }
    }) */
    .subscribe(//! says we are on/offline
      (status, [ref]) async {
        if (status == 'SUBSCRIBED') { // how to get user id?
          await _lobbyChannel.track({'user_id': widget.myUuid}); // we will get myUserId from sql
        }
      },
    );
    /* _lobbyChannel.subscribe( 
      (status, [ref]) async {
        if (status == 'SUBSCRIBED') { // how to get user id?
          await _lobbyChannel.track({'id': widget.userUuid}); // we will get myUserId from sql
        }
      },
    ); */

  }
  @override
  void dispose() {
    // TODO: implement dispose
    _pageController.dispose();
    Supabase.instance.client.removeChannel(_lobbyChannel);
    super.dispose();
  }
  late final tabs = [
    //! vv(iside of this we need to somehow to get data to the big sqlite database)vv
    ContactsPage(myUuid: widget.myUuid), //Chat (get messages)
    FindUsersPage(myUuid: widget.myUuid), //new People (get users) (if getting a signal from supabase(server) )
    const MyHomePage(), //new People (get users) (if getting a signal from supabase(server) )
    /* Container(child: const MiniGameHandler()), //games V1 (get upates?)
    Container(child: BookStore()), */ //Books (books)
    //Container(child: const MyHomePage()),
    //Container(child: dataviewer.DatabaseList()), //games V2 (we want to know which icon ppl like more) //!using for database atm CHANGE AT THE END
    
    //Container(child: RobotPage()), //Robot/IRL
  ];


  //final messageData = AsyncSnapshot.nothing();
  void _onItemTapped(int index) {
    print(index);
    setState(() {
      _selectedIndex = index;
      //_pageController.jumpToPage(_selectedIndex);
    });
    //_pageController.jumpToPage(_selectedIndex);
    
    
    _pageController.animateToPage(_selectedIndex, duration: Duration(microseconds: 50), curve: Curves.bounceIn);
  }
  //! IDK if you can do a generic controller for each page (maybe you can idk)

  RefreshController _refreshController = RefreshController(initialRefresh: false, );

  void _onRefresh() async{
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
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



  //! VERSION 2!!!! 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: /* SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: WaterDropHeader(),
        
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child:  */PageView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index){
            final tab = tabs[index];
            return tab;
          },
          /* onPageChanged: (index) {
            const myid =2;
            if(index == 0){//? known contacts
              _lobbyChannel.on(RealtimeListenTypes.presence, ChannelFilter(event: 'sync', schema: 'public', table: 'users'), 
                (payload, [ref]) {
              // Update the lobby count
              final presenceState = _lobbyChannel.presenceState();
              print("who tf is u?$presenceState");
              final isonline = (_lobbyChannel.isJoined || _lobbyChannel.isJoining); //gets if user is online or coming online

              setState(() { //! not sure if i need this tbh
                
                _userids = presenceState.values // we probably want to use this in contacts and all users list
                    .map((presences) =>
                        // OLD: (presences.first as Presence).payload['user_id'] as String)
                        (presences.first as Presence).payload['id'].toString())
                    .toList();
              });
              print("all users in the 'lobby': $_userids");
            })
            /* .on(RealtimeListenTypes.broadcast, ChannelFilter(event: 'game_start'), 
              //! I think we can use this for a typing indicator(idk guessing)
                (payload, [_]) {
              // Start the game if someone has started a game with you
              final participantIds = List<String>.from(payload['participants']);
              if (participantIds.contains(myUserId)) {
                final gameId = payload['game_id'] as String;
                widget.onGameStarted(gameId);
                Navigator.of(context).pop();
              }
            }) */
            .subscribe(
              (status, [ref]) async {
                if (status == 'SUBSCRIBED') { // how to get user id?
                  await _lobbyChannel.track({'id': myid}); // we will get myUserId from sql
                }
              },
            );

            }
            else if (index ==1){ //? users we can contact that aint in local db

            }
            else{ //we are online but we dont need info from the other pages
              _lobbyChannel.subscribe( //! says we are on/offline
                (status, [ref]) async {
                  if (status == 'SUBSCRIBED') { // how to get user id?
                    await _lobbyChannel.track({'id': myid}); // we will get myUserId from sql
                  }
                },
              );
            }
          }, */ //! just do it in the init
          itemCount: tabs.length,
          controller: _pageController,
          //)
          
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: "Chat",
            backgroundColor: Colors.blue,

          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "People",
            backgroundColor: Colors.purple,

          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "profile",
            backgroundColor: Colors.red,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  } 
  
}


