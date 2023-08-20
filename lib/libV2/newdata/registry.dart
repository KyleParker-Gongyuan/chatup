
//import 'package:chatup/background_ui/main_pagev.dart';




import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:chatup/libV2/newdata/data_helpa.dart';
import 'package:chatup/libV2/newdata/db_data_translation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


// This is our global ServiceLocator (I think)
final registry = GetIt.instance;
late Message _messageData;
//final mydatabase =  MyDatabase();
final databaseHelper =  DatabaseHelper();

BigUser? ad;
void setupDb(String? userUuid) {
  WidgetsFlutterBinding.ensureInitialized();
  print("init startup db");
  registry.registerSingleton<DatabaseHelper>(databaseHelper);

  
  
  print("user exist, $userUuid");
  if (userUuid == null){
    debugPrint("no user local");
    return;
  }
  setupServerFeedBack(userUuid, true);
  
  print("database ready?");

}


Future<void> setupServerFeedBack(String uuid, bool initStart) async {
  
  registry.registerSingleton<String>(uuid); // set the user's server id for use other places

  WidgetsFlutterBinding.ensureInitialized();
  // initally get all messages from that havent been recieved from the server to get rid of backlogs

  //! we will want to dynamically change limit if the user has alot of un recived messages
  //var localDatabase = registry.get<MyDatabase>();
  print('asdpj');
  final localDatabase = registry.get<DatabaseHelper>();
  //var localDatabase = registry.get<AppDb>();
  late List<Message> localMessages;
  
  int limitamount = initStart? 1000 : 25;
  String serverId = uuid; // we need to get the uuid of me(this user)


  try {
    
    Supabase.instance.client.from('messages').stream(primaryKey: ['id']).eq('receiver_id', serverId)
    .order('received', ascending: false).limit(limitamount).listen((serverMessages) { //? this is for dm-ing(I think)
      //TODO:  we need to get the  recieverid(ie our id to make sure we only get our messages)
      print("minaz: $serverMessages"); // all messages from server

      localDatabase.getAllMessages().then((value) { //get local messsages
        localMessages = value;
        print("daz emtpy ${localMessages.isEmpty}");

        // make sure we have all the messages

        serverMessages.forEach((serverMessage) async {
          //? check if user exists
          final senderId = serverMessage['sender_id'];
          final userexists = await localDatabase.getUser(senderId,true);

          
          if(userexists==null){
            print("user not exists: $senderId");
            await databaseHelper.addUserToLocalDb(senderId);
          }
          
          print("fungus2:");
        
          var convertedServerMsg = Message(serverId: serverMessage['id'],createdAt: DateTime.parse(serverMessage['created_at']),message: serverMessage['message'],
          senderId: serverMessage['sender_id'],receiverId: serverMessage['receiver_id']);
          //TODO: we need to make sure in the future that we can change order of messages 
          //! if we send a message but it doesnt go to the server we wont get a server id
          //? might cause a problem because the sever id (same msg with null server id)

          bool msgIdExists = localMessages.any((message) => message.serverId == convertedServerMsg.serverId);
          if (!msgIdExists) {
            print("message aint in local db");
            
            
            localMessages.add(convertedServerMsg);
            var zz = await localDatabase.insertMessage(convertedServerMsg);
            print("added: '${zz.toJson()}' message tiz zz!");
          }
          else{
            print("we have message '${convertedServerMsg.toJson()}' in local db");
          }
            print("user Got ${localMessages.length} messages");

        });

      });
      localDatabase.getAllUsers().then((value) {
        print("all uzers: $value");
      });
      if(initStart){
        print("ur a gamer johny");
        limitamount = 25;
        initStart = false;
      }
    });
    
  }
  catch(error){
    print("error: $error");
  }

  
}
