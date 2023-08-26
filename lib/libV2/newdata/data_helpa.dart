import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:chatup/chat/components/imagefunctions.dart';

import 'db_data_translation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:get/get.dart';
import 'package:sqlbrite/sqlbrite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


  

  

class DatabaseHelper{
  static final DatabaseHelper instance = DatabaseHelper._init();
  
  DatabaseHelper();
  Future<Database> get database async {

    
    //String _filePath = 'database.db';
    String _filePath = 'nez.db'; // we are changing this
    int _version = 2 ;

    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, _filePath);
    
    
    return await openDatabase(path, version: _version, 
      onCreate: (Database db, int version) async{

        // we will get the id from the database

        const localIdType = 'INTEGER PRIMARY KEY AUTOINCREMENT'; //maybe change it to the Discord model? (Name + id)
        const userIdType = 'INTEGER NOT NULL'; //maybe change it to the Discord model? (Name + id)
        const boolType = 'BOOLEAN NOT NULL';
        const intType = 'INTEGER NOT NULL';
        const intNullableType = 'INTEGER';

        const textType = 'TEXT NOT NULL';
        const textNullableType = 'TEXT';
        const blob = 'BLOB';

        print("START TABLEZ");
        //! known users
        await db.execute('''
          CREATE TABLE $contactsTable(
            ${BigUsersColumn.id} $localIdType,
            ${BigUsersColumn.serverId} $userIdType,
            ${BigUsersColumn.username} $textType,
            ${BigUsersColumn.bio} $textType,
            ${BigUsersColumn.gender} $userIdType,
            ${BigUsersColumn.dob} $textType,
            ${BigUsersColumn.onlineState} $boolType,
            ${BigUsersColumn.imageAvatar} $blob, 
            ${BigUsersColumn.timeAtm} $textType,
            ${BigUsersColumn.createdAt} $textType
          )
        '''); //!* how do we actually get the image? *!/

        //! messages //? NOTE: senderID is this user, the receiverID is the user we want to send to
        await db.execute('''
          CREATE TABLE $messagesTable(
            ${MessagesColumn.id} $localIdType,
            ${MessagesColumn.serverId} $intNullableType,
            ${MessagesColumn.message} $textType,
            ${MessagesColumn.senderId} $boolType,
            ${MessagesColumn.receiverId} $intType, 
            ${MessagesColumn.extraContent} $textNullableType, 
            ${MessagesColumn.repliedToId} $intNullableType, 
            ${MessagesColumn.createdAt} $textType
            
          )
        ''');
        
    });

      
      //return db; //might want to just do this //openDatabase(path, version: _version, onCreate: _createDB);


    
  }
  DatabaseHelper._init();


  //final _dbFuture = databaseStartup().then((db) => BriteDatabase(db));

  
  
  Future<Message> insertMessage(Message message,) async{
    final db = await instance.database;
    
    // we get the unique id from our insert
    final id = await db.insert(messagesTable, message.toJson());

    //! we need to asosiate this message with the contact (from user2 goes to user2)

    // the current message
    return message.copy(id: id); // idk exactly, but i think this is (id++) BUT IDK

  }

  Future<Message> getMessage(int id) async{
    final db = await instance.database;

    final maps = await db.query(
      messagesTable,
      columns: MessagesColumn.values,
      where: '${MessagesColumn.id} = ?',
      whereArgs: [id], // dont fully understand tbh
      //whereArgs: [id, username, bio, gender, dob, onlineState, imageAvatar, timeAtm, createdAt], // dont fully understand tbh
    );

    //return knownUser.copy(id: id); //delete the shit
    if (maps.isNotEmpty) {
      return Message.fromJson(maps.first);
    }
    else{
      throw Exception('ID $id not found');
    }
  }

  Future<List<Message>> getAllMessagesInConvo(String myUuid,String othersUuid) async{

    final db = await instance.database;
    //!* we probably want to reorder users(by date, last txt, gender, etc)
    print("pog zuzz $myUuid");

    final allMessages =await db.rawQuery( // we just want to get the last msg

      '''
      SELECT * FROM $messagesTable
      WHERE 
      (? IN (sender_id, reciver_id) AND ? IN (sender_id, reciver_id))
      OR
      (? IN (sender_id, reciver_id) AND ? IN (sender_id, reciver_id));
      ORDER BY _local_id DESC;
      ''',
      [myUuid,othersUuid,othersUuid,myUuid]
    );
        List<Message> messageList = allMessages.isNotEmpty ? allMessages.map((e) => Message.fromJson(e)).toList() : [];

    return messageList;
  }
  Future<List<Message>> getAllMessagesFromUser(String uuid) async{
    final db = await instance.database;
    //!* we probably want to reorder users(by date, last txt, gender, etc)
    print("pog zuzz $uuid");

    final allMessages = await db.query(messagesTable, columns: MessagesColumn.values,
      where: '${MessagesColumn.senderId} = ?', whereArgs: [uuid]);
    print("all messages from user $allMessages");
    List<Message> messageList = allMessages.isNotEmpty
    ? allMessages.map((e) => Message.fromJson(e)).toList() : [];

    return messageList;
  }

  Future<List<Message>> getAllMessages() async{

    final db = await instance.database;
    //!* we probably want to reorder users(by date, last txt, gender, etc)

    final allMessages = await db.query(messagesTable);

    List<Message> messageList = allMessages.isNotEmpty
    ? allMessages.map((e) => Message.fromJson(e)).toList() : [];
    int i=0;
    print("all messages in db:");
    messageList.forEach((message) {i++;print("num $i: ${message.toJson()}");});
    return messageList; //allMessages.map((json) => Message.fromJson(json)).toList();
  }

  Future<Message> getLastMessageForChatRoom(String contactId) async{
    final db = await instance.database;
    //!* we probably want to reorder users(by date, last txt, gender, etc)
    print("this existed");
    print(contactId);
    final maps = await db.rawQuery( // we just want to get the last msg
      '''
      SELECT * FROM $messagesTable
      WHERE ? IN (sender_id, reciver_id)
      ORDER BY _local_id DESC
      LIMIT 1;
      ''',
      [contactId]
    );
    if (maps.isNotEmpty) {
      print("last message in chat :${maps.first}");
      return Message.fromJson(maps.first);
    }
    else{
      throw Exception('User ID $contactId not found'); // I dont think this will be needed
      //! we need to make sure we arent getting our own id
    }
    
  }

  Future<void> addMessageServerId( int id, String serverId) async {
    final db = await instance.database;
    print("added ServerId to message");
    int rowAffected = await db.rawUpdate(
                'UPDATE $messagesTable SET server_id = ? WHERE _local_id = ?',
                [serverId, id],
              ); // ideally we should be able to get the output but whatever
    
    // // Close the database
    // await db.close();

  }

  Future<int> deleteMessage(int id) async { //WIP
    
    final db = await instance.database;
    
    return await db.delete(
      messagesTable,
      
      where: '${MessagesColumn.id} = ?',
      whereArgs: [id], // dont fully understand tbh
    );

  }
  /// creates a new (user)row to the known user list
  Future<int> insertUser(BigUser knownUser,) async{
    final db = await instance.database;
    try{

    final id = await db.insert(contactsTable, knownUser.toJson(), conflictAlgorithm: ConflictAlgorithm.abort);
    
    return id;
    } catch (e){
      print("error: $e");
      return -1;
    }

  }
  

  Future<BigUser?> getUser(String id, bool usingServerId) async{
    final db = await instance.database;
    final newid = usingServerId? id : int.parse(id); 
    final maps = await db.query(
      contactsTable,
      columns: BigUsersColumn.values,
      where: usingServerId? '${BigUsersColumn.serverId} = ?' : '${BigUsersColumn.id} = ?',
      whereArgs: [newid], // dont fully understand tbh
      //whereArgs: [id, username, bio, gender, dob, onlineState, imageAvatar, timeAtm, createdAt], // dont fully understand tbh
    );

    //return knownUser.copy(id: id); //delete the shit
    if (maps.isNotEmpty) {
      return BigUser.fromJson(maps.first);
    }
    else{
      final idType = usingServerId? 'serverID' : 'ID';
      print("$idType on local DB: $id not found");
      return null;
    }
  }

  Future<void> addUserToLocalDb(String newUsersContactId) async {
    var thisUserInfo;

    await getAllUsers().then((users) async {
      final lastuser = users.length;
      
      await Supabase.instance.client.from('profiles').select().eq('user_id', '$newUsersContactId').then((value) async {

        print("user from server: ${value}");
        
        var thisuser = value[0];
        var created_at = DateTime.parse(thisuser['created_at']);
        var last_online = DateTime.parse(thisuser['last_online']);
      
        //what is the best way of doing this?

        //Uint8List avatarImage = await Supabase.instance.client.storage.from("avatars").download(thisuser['avatar_url']);
        

        String avatarImage = "";
        if (thisuser['avatar_url'] != null){

          try{
            final imagebytes = await Supabase.instance.client.storage.from("avatars").download(thisuser['avatar_url']);
            avatarImage = Imagefunctions().image2Base64String(imagebytes);

          }catch (error){
            print("some error: $error");
          }
        }
        //! PLEASE OFFEND ME 我狠jaydid人， 是ovius  我们可以(有) buy 冰激凌在冰激凌餐厅, what else are we gonna do!?!??!
        // im a jayded person

        thisUserInfo = BigUser(
          id: lastuser, serverId: thisuser['user_id'],username: thisuser['username'],imageAvatar: avatarImage,
          bio: thisuser['bio'], onlineState: thisuser['online_status'], dob: thisuser['dob'],
          gender: thisuser['gender'],timeAtm: last_online, createdAt: created_at);
        print("the user going into the local db: $thisUserInfo");
        insertUser(thisUserInfo);
        
      },
      onError: (error){
      print("some error: $error");
    });});

  
    print("added user to local db");
  }

  //we need this users id
  Future<List<BigUser>> getAllUsersNotSelf({required int localId}) async{
    final db = await instance.database;
    //!* we probably want to reorder users(by date, last txt, gender, etc)
    final List<Map<String, dynamic>> allUsersNotSelf = await db.rawQuery(
    'SELECT * FROM $contactsTable WHERE _id <> ?',
    [localId],
    ); // BTW '?' is means exclude from X table
    allUsersNotSelf.map((json) => BigUser.fromJson(json)).toList();
    return allUsersNotSelf.map((json) => BigUser.fromJson(json)).toList();

  }
  Future<List<BigUser>> getAllUsers() async{ // causes a problem if you never have sent a msg
    final db = await instance.database;
    //!* we probably want to reorder users(by date, last txt, gender, etc)
    final allUsers = await db.query(contactsTable);

    // final oderbyX = '${BigUsersColumn.gender} ASC'; //! get users in asending order 
    //final allUsers = await db.query(conntactsTable, orderBy: orderbyX); //
    
    allUsers.map((json) => BigUser.fromJson(json)).toList();
    return allUsers.map((json) => BigUser.fromJson(json)).toList();
  }

  Future<void> updateUser(int id) async {
    final db = await instance.database;
    print("updating Message");
    int rowAffected = await db.rawUpdate(
      'UPDATE $contactsTable SET server_id = ? WHERE _local_id = ?',
      [id],
    ); // ideally we should be able to get the output but whatever
    print("row changed: $rowAffected");
    
    
  }


  Future<int> deleteUser(int id) async { //WIP
    
    final db = await instance.database;
    
    return await db.delete(
      contactsTable,
      where: '${BigUsersColumn.id} = ?',
      whereArgs: [id], // dont fully understand tbh
    );

  }

  Future close() async{
    final db = await instance.database;
    db.close();
  }

  
  /// un-registored users [userId]=0, a new User is created and [newUserInfo] is sent to the DB.
  /// else it will update the [userId] to a selected [customId]
  Future<String?> createCustomId(int userId, BigUser? newUserInfo, int? customId) async {
    // W.I.P //* this will be used for making a new/custom(when a pro user) ID
    String newId;
    if (userId == 0){ // we need to make sure a user cant set their user id to 0 (0 == new registoring user)
      // if they set it to 0 they might cause a problem (idk what tho （*゜ー゜*）)
      
      print("Creating new user id ");
      int? idvalue;

      await Supabase.instance.client.from('users').insert({
        'created_at': newUserInfo!.createdAt.toIso8601String(),
        'username': newUserInfo.username,
        'avatar_url': newUserInfo.imageAvatar,
        'bio': newUserInfo.bio,
        'gender': newUserInfo.gender,
        'dob': newUserInfo.dob,
        'online_status': newUserInfo.onlineState,
        'last_online': newUserInfo.timeAtm.toIso8601String(), // we will need to make this better idk how tho .·´¯`(>▂<)´¯`·. 

      }).select('id').then((value) {idvalue = value[0]['id'];});
      print("added user: $idvalue");
      // this feels stupid tbh
      
      

      return idvalue.toString();
    }
    else{
      print("changing user Id to custom Id: $customId");
      // so eq = the row we are editing
      await Supabase.instance.client.from('users').update({'id': customId}).eq('id', userId).select('id').then((value) {return value[0]['id'] as String;});
      
    }
    
    
  }

  Future<int> getLastMessageId() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT MAX(${MessagesColumn.id}) FROM $messagesTable',);
  
  // Retrieve the last message ID from the result
  final lastLocalId = result[0]['MAX(${MessagesColumn.id})'] as int;
  
  
  return lastLocalId;
  }

  Future<void> updateProfileImage(imageBytes, id) async {
    final db = await instance.database;

    await db.delete(BigUsersColumn.imageAvatar, where: 'id = ?', whereArgs: [id]);

    // Insert the image bytes into the database
    await db.insert(BigUsersColumn.imageAvatar, {'image': imageBytes});
  }
  
  
  Future<int> addImage(Uint8List imageBytes) async {
    final Database db = await database;
    return await db.insert('images', {'image': imageBytes});
  }

  Future<List<Map<String, dynamic>>> getAllImages() async {
    final Database db = await database;
    return await db.query('images');
  }

  Future<int> deleteImage(int id) async {
    final Database db = await database;
    return await db.delete('images', where: 'id = ?', whereArgs: [id]);
  }



}



// verical vs horizontal intergratoin
// hor == SaSS buys a SaSS (aws and linode(? is this how its spelled?))
// vert == unity buys steam(where games are bought) or valve (where games are made)

// A weird thing my brain did (for valve)
//   1990     C(reate) game engine,  
// C engine, 

//create computer, create modulare bit engine, game engine on top, 

