

import 'package:chatup/background_ui/main_page.dart';
import 'package:chatup/chat/pages/newUserStart/picsAnBio.dart';
import 'package:chatup/chat/pages/newUserStart/register_page.dart';
import 'package:chatup/libV2/newdata/data_helpa.dart';
import 'package:chatup/libV2/newdata/db_data_translation.dart';
import 'package:chatup/libV2/newdata/registry.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
//import 'package:getworld/getworld.dart' as world;
class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final List<String> userInfo = [];
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  String _avatarUrl = '';
  TextEditingController _bio = TextEditingController();
  int _gender = 0;
  DateTime _dob = DateTime.now();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> picsformKey = GlobalKey<FormState>();


  late final List<Container> tabs = [
    //! vv(iside of this we need to somehow to get data to the big sqlite database)vv
    Container(child: RegisterPage(emailController: _emailController,passwordController: 
    _passwordController, usernameController: _usernameController, formKey: _formKey),),
    Container(child: PicsAnBio(avatarUrl:_avatarUrl,bio:_bio,gender:_gender,dob:_dob, formKey: picsformKey),),
    
  ];


  
  //final messageData = AsyncSnapshot.nothing();
  void _onItemTapped(int index) {
    print(index);
    setState(() {
      _currentPageIndex = index;
      //_pageController.jumpToPage(_selectedIndex);
    });
    //_pageController.jumpToPage(_selectedIndex);
    
    
    _pageController.animateToPage(_currentPageIndex, duration: Duration(microseconds: 50), curve: Curves.bounceIn);
  }

  //AuthException //! we need a token for after the first login (so they dont have to login again)
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  bool _validateForm() {
    if (_formKey.currentState!.validate()) {
      return true; // Form is valid
    } else {
      _showSnackbar('Please fix errors in previous forms');
      
      
      return false; // Form is invalid
    }
  }

  //! VERSION 2!!!! 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const Text('Signup'),
          const Spacer(),
          Text("${_currentPageIndex+1}/${tabs.length}"),
        ],)
      ),
      
      body: PageView.builder(
        physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index){
            final tab = tabs[index];
            return tab;
          },
          
          itemCount: tabs.length,
          controller: _pageController,
        ),
        
        
      
      

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(children: [
          Flexible(child: ElevatedButton(onPressed: (){_previousPage();}, child: const Text('previous'),),),
          Flexible(child: ElevatedButton(onPressed: (){
            print("we got here");
            if (_currentPageIndex+1 == tabs.length){
              _submit();
              /* Navigator.push(//! THIS goto 'X' page
                context, 
                MaterialPageRoute(builder: (context) => MainPage()), //TODO: user shouldnt be able to go back to this page
              
              ); */
            }
            _nextPage();
          }, child: _currentPageIndex+1 == tabs.length ? const Text( 'submit') : const Text( 'next'),),)
        ],),
      ),
    
    );
  }


  // Navigation functions

  void _nextPage() {
    if (_currentPageIndex+1 < tabs.length) {
      setState(() {
        _currentPageIndex++;
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPageIndex > 0) {
      setState(() {
        _currentPageIndex--;
      });
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  void verifyForm() {
    if (_formKey.currentState!.validate()) {
      // All form fields are valid, proceed with your logic
      // Access the form field values using:
      // widget.usernameController.text
      // widget.emailController.text
      // widget.passwordController.text
    }
  }

  Future<void> _submit() async {
    // Perform any additional validation before adding to the list
    if (_currentPageIndex+1 == tabs.length) {
      
      if(_validateForm()){
        if (await _validateAndSignUp()) {
        print("signedup");
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? userUuid = prefs.getString('userUuid');
        Navigator.push(//! THIS goto 'X' page
          context, 
          MaterialPageRoute(builder: (context) => MainPage(myUuid: userUuid!,))
        ); //TODO: user shouldnt be able to go back to this page
      }
      }
      //print("signup failed");
      //_signUp();
      // Add the user information to the list
      // You can perform any other actions here, like making an API call
      print(userInfo);
    }
  }
  Future<bool> _validateAndSignUp() async {
    
    
    final email = _emailController.text;
    final password = _passwordController.text;
    final username = _usernameController.text;
    
    final bio = _bio.text;
    
    final dobString = _dob.toIso8601String();
    bool isallowed = false;

    if (_formKey.currentState!.validate()) {
      isallowed = true; // Form is valid
    } else {
      _showSnackbar('Please fix errors in previous forms');
      
      
      isallowed = false; // Form is invalid
    }

    print("all the stuff for signup: $email, $username, $password, $bio, $dobString, $_gender");
    if (isallowed){
      try {
        // sending it all at 1 time should only have 1 error not having to deal with making a user then adding a profile
        final AuthResponse res = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
          //emailRedirectTo: 'io.supabase.aa://login',
        );
        final Session? session = res.session;
        final User? user = res.user;
        //session!.accessToken; //! we use this in prefs?

        final databaseHelper =  DatabaseHelper();


        final SharedPreferences prefs = await SharedPreferences.getInstance();

        prefs.setString('loginToken',session!.accessToken);
        prefs.setString('userUuid', user!.id);

        print("user ID ${user!.id}");
        try{
          await Supabase.instance.client.from('profiles').insert({
            'user_id': user.id,
            'username': username,
            'avatar_url': _avatarUrl,
            'bio': bio,
            'gender': _gender,
            'dob': dobString,
            
          });

          final meuser = BigUser(id: 0, serverId: user.id, username:username, bio:bio, imageAvatar: _avatarUrl,
          gender: _gender, dob: dobString, timeAtm: DateTime.now(),createdAt: DateTime.now(),onlineState: false,);
          final z = await databaseHelper.insertUser(meuser);
          
          

          setupServerFeedBack(user!.id, true);

          print('Please check your inbox for confirmation email.');
          return true;

        } catch (error){
          debugPrint("problem adding users profile: ${error.toString()}");
          return false;
        }

      
      }  on AuthException catch (error) {
          print("Signup ERROR: ${error.message}");
          _showSnackbar(error.message);
          return false;

      }  catch (error) {
        debugPrint("ERROR: ${error.toString()}");
        return false;

        /* context.showErrorSnackBar(
          message: unexpectedErrorMessage); */
      }
    }
    return false;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}