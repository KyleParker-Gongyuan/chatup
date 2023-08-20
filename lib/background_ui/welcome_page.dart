import 'package:flutter/material.dart';
import 'package:chatup/background_ui/expanded_ui.dart';
import 'package:chatup/background_ui/main_page.dart';



import 'package:chatup/background_ui/notifiers.dart';
import 'package:chatup/libV2/newdata/data_helpa.dart';
import 'package:chatup/libV2/newdata/registry.dart';
import 'package:chatup/main.dart';
import 'package:chatup/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'custom_widgets.dart';
import 'package:chatup/libV2/newdata/db_data_translation.dart';


final xUi = ExpandedUI();
//! INFO FOR LOGIN AND SHIT v1
//? need to use firebase or somthing like it for users(use in house somthing ideally)
class WelcomePage extends StatefulWidget {
  
  WelcomePage({super.key,});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}
class _WelcomePageState extends State<WelcomePage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  TextEditingController _emailController=TextEditingController();
  TextEditingController _passwordController= TextEditingController();
  

  @override
  void initState(){
    super.initState();
    //_loadValueFromSharedPreferences(); //! I feel like I should be able to do this in main but idk
  }

  void _loadValueFromSharedPreferences(userUuid) {
     // Replace 'my_key' with your key
      if (userUuid != null) {
      // Automatically navigate to SecondPage if myString is not null
      Future.delayed(Duration.zero, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MainPage(myUuid: userUuid!,)), // how to goto previous page?
        );
      });
    }
    
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32.0),
              Text(
                'Login with email and password',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _email = value!;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _password = value!;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          // TODO: Handle login with email and password
                          
                          await _loginUser(_emailController,_passwordController);
                        };
                      },
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32.0),
              Text(
                'Or create a new account',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // TODO: Handle create account
                  // TODO: MAKE NOTIFICATIONS WORK
                  //LocalNotifications.showNotification(title: 'title', body: 'body', fln: flutterLocalNotificationsPlugin);
                  Navigator.push(//! THIS goto 'X' page
                    
                    context,
                  //MaterialPageRoute(builder: (context) => HomePageZ()), 
                  MaterialPageRoute(builder: (context) => SettingsPage()), 
                  );
                },
                child: const Text('Create Account'),
              ),
              const SizedBox(height: 32.0),
              //! row of authocation buttons (google, apple, etc)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget> [
                  CustomCircularButton(
                    color: Colors.white,
                    imagePath: 'assets/icons/google-icon-logo-svgrepo-com.svg', 
                    press: () {},
                  ),
                  SizedBox(width: 10), // add spacing between the buttons
                  CustomCircularButton(
                    color: Colors.white,
                    imagePath: 'assets/icons/google-icon-logo-svgrepo-com.svg',
                    press: () {},
                  ),
                ],
                
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<bool> _loginUser(TextEditingController _emailController,TextEditingController _passwordController) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    final email = _emailController.text;
    final password = _passwordController.text;
    
    String userUuid = '';
    String sesToken = '';
    try {
      // sending it all at 1 time should only have 1 error not having to deal with making a user then adding a profile
      final AuthResponse res = await Supabase.instance.client.auth.signInWithPassword(
        email: email,//email,
        password: password,//password,

        //emailRedirectTo: 'io.supabase.aa://login',
      );
      final Session? session = res.session;
      final User? user = res.user;
      //session!.accessToken; //! we use this in prefs?
      final databaseHelper =  DatabaseHelper();
      userUuid=user!.id;
      sesToken=session!.accessToken;

      print("user ID ${user!.id}");
      try{
        
        final userlist = await Supabase.instance.client.from('profiles').select().eq('user_id',user.id);
        final myUser = userlist[0];
        print("My UserINFO: $myUser");

        final meuser = BigUser(id: 0, serverId: myUser['user_id'], username:myUser['username'], bio:myUser['bio'],
        gender: myUser['gender'],dob: myUser['dob'],onlineState: false, imageAvatar: myUser['avatar_url'],
        timeAtm: DateTime.now(), createdAt:  DateTime.parse(myUser['created_at']),);
        
        //! we need to make sure that this user can't logout and back in to insert a new id at 0
        if(await databaseHelper.insertUser(meuser)==-1){
          return false;
        }
        prefs.setString('loginToken',sesToken);
        prefs.setString('userUuid', userUuid);

        //setupServerFeedBack(user!.id, true);
        print('Please check your inbox for confirmation email.');
        xUi.showSnackbar("you might have to check your email before continuing", context);

      } catch (error){
        debugPrint("problem creating users profile: ${error.toString()}");
        xUi.showSnackbar("problem creating your profile: ${error.toString()}", context);
        
        return false;
      }
    
    }  on AuthException catch (error) {
        print("Login ERROR: ${error.message}");
        xUi.showSnackbar("Login ERROR: ${error.message}", context);
        return false;

    }  catch (error) {
        debugPrint("ERROR: ${error.toString()}");
        xUi.showSnackbar("ERROR: ${error.toString()}", context);
        
        return false;
    }
    setupServerFeedBack(userUuid, true);
    Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MainPage(myUuid: userUuid,)), // how to goto previous page?
        );
    return true;
  }
  

}
