

//the middleWare is used for converting the sql and drift data

const String contactsTable = 'conntacts';
const String messagesTable = 'messages';


class MessagesColumn{
  static final List<String> values = [
    // add all columns(fields)
    id,serverId, message, senderId, receiverId, createdAt, extraContent,
    repliedToId,
  ];
  
  static const String id = '_local_id';
  static const String serverId = 'server_id';
  static const String message = 'message';
  static const String senderId = 'sender_id';
  static const String receiverId = 'reciver_id'; //receiver_id // the room id
  static const String createdAt = 'created_at';
  


  static const String extraContent = 'extra_content';
  static const String repliedToId = 'replied_id';

}

class BigUsersColumn{
  static final List<String> values = [
    // add all columns(fields)
    id, serverId, username, bio, gender, dob, onlineState, imageAvatar, timeAtm, createdAt,
  ];
  static const String id = '_id';
  static const String serverId = 'serverId';
  static const String username = 'username';
  static const String bio = 'bio';
  static const String gender = 'gender';
  static const String dob = 'dob';
  static const String onlineState = 'online_status';
  static const String imageAvatar = 'image_Avatar';
  static const String timeAtm = 'time_atm';
  static const String createdAt = 'created_at';


}


class Message{
  final int? id; // this is the local id (ie this users 100th message in local db)
  final int? serverId; // this is the id on the server we referance (the 1 mil message on the server)
  final String message;
  final String senderId; // the senders uuid (we need to make a better uuid system like discord)
  final String receiverId; // the receivers uuid (we need to make a better uuid system like discord)
  final DateTime createdAt; // we get this from the server
  final String? extraContent;
  final int? repliedToMsgId;

  const Message({
    this.id,
    this.serverId,
    required this.message,
    required this.senderId,
    required this.receiverId,
    required this.createdAt,
    this.repliedToMsgId,
    this.extraContent,
    });

  ///idk exatly what this is tbh
  Message copy({ 
    int? id,
    int? serverId,
    String? message,
    String? senderId,
    String? receiverId,
    int? repliedToId,
    String? extraContent,


    DateTime? createdAt,

    }) => Message( // copying info (im confused figure it out?) //* ? == (can be a null var). //* ?? == (return if not null)
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      message: message ?? this.message,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      createdAt: createdAt ?? this.createdAt,
      repliedToMsgId: repliedToId ?? this.repliedToMsgId,

      extraContent: extraContent ?? this.extraContent,
      );
    static Message fromJson(Map<String, Object?> json) => Message(
      id: json[MessagesColumn.id] as int?,
      serverId: json[MessagesColumn.serverId] as int?,
      message: json[MessagesColumn.message] as String,
      senderId: json[MessagesColumn.senderId] as String, //true,
      receiverId: json[MessagesColumn.receiverId] as String,

      extraContent: json[MessagesColumn.extraContent] as String?,
      repliedToMsgId: json[MessagesColumn.repliedToId] as int?,

      createdAt: DateTime.parse(json[MessagesColumn.createdAt] as String)
    );
    Map<String, Object?> toJson() =>{
      MessagesColumn.id: id,
      MessagesColumn.serverId: serverId,
      MessagesColumn.message: message,

      MessagesColumn.extraContent: extraContent,
      MessagesColumn.repliedToId: repliedToMsgId,

      MessagesColumn.senderId: senderId,
      MessagesColumn.receiverId: receiverId,
      MessagesColumn.createdAt: createdAt.toIso8601String(), //convert from datatime to string
    };
  
  
}


class BigUser{
  /// user info for the offline functionality (txt/profile info (bio, age, pic, etc) )
  
  final int id; // on create we will not have an id
  final String serverId; // on create we will not have an id
  final String username;
  //final String messages;
  final String bio; 
  final int gender; // 0= fem, 1= mal, 2= other
  final String dob; // date of birth
  final bool onlineState;
  final String imageAvatar; // when do we get an updated version of the users image
  final DateTime timeAtm; // last online/current time in timezone
  final DateTime createdAt; // we get this from the server
  //final String? location; // this is the location of the current user

  const BigUser({
    required this.id,
    required this.serverId,
    required this.username,
    required this.bio,
    required this.gender,
    required this.dob,
    required this.onlineState,
    required this.imageAvatar,
    required this.timeAtm,
    required this.createdAt,
  });

  
  ///idk exatly what this is tbh
  BigUser copy({ 
    int? id,
    String? serverId,
    String? username,
    String? bio,
    int? gender,
    String? dob,
    bool? onlineState,
    String? imageAvatar,
    DateTime? timeAtm,
    DateTime? createdAt,
    
    }) => BigUser( // copying info (im confused figure it out?) 
    // ? == (can be a null var). // ?? == (return if not null)
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      onlineState: onlineState ?? this.onlineState,
      imageAvatar: imageAvatar ?? this.imageAvatar,
      timeAtm: timeAtm ?? this.timeAtm,
      createdAt: createdAt ?? this.createdAt,
      );
  
  ///this is actually going to the server I think?
  static BigUser fromJson(Map<String, Object?> json) => BigUser(
    id: json[BigUsersColumn.id] as int,
    serverId: json[BigUsersColumn.serverId] as String,
    username: json[BigUsersColumn.username] as String,
    bio: json[BigUsersColumn.bio] as String,
    gender: json[BigUsersColumn.gender] as int,// as int, //! why tf doesnt this work?
    dob: json[BigUsersColumn.dob] as String,
    onlineState: json[BigUsersColumn.onlineState] == 1, //true
    imageAvatar: json[BigUsersColumn.imageAvatar] as String, // string turns into a 'blob' in the database
    timeAtm: DateTime.parse(json[BigUsersColumn.timeAtm] as String),
    createdAt: DateTime.parse(json[BigUsersColumn.createdAt] as String)
  ); 
    
  
  Map<String, Object?> toJson() =>{
    BigUsersColumn.id: id,
    BigUsersColumn.serverId: serverId,
    BigUsersColumn.username: username,
    BigUsersColumn.bio: bio,
    BigUsersColumn.gender: gender,
    BigUsersColumn.dob: dob,
    BigUsersColumn.onlineState: onlineState ? 1 : 0, //changing to a boolean
    BigUsersColumn.imageAvatar: imageAvatar,
    BigUsersColumn.timeAtm: timeAtm.toIso8601String(), //to a datetime string
    BigUsersColumn.createdAt: createdAt.toIso8601String(), //to a datetime string
  };
}


