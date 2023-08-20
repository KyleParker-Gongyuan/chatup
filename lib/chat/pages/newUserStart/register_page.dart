import 'dart:async';

import 'package:flutter/material.dart';


import 'package:country_list_picker/country_list_picker.dart';



import 'dart:math' as math;

import 'package:supabase_flutter/supabase_flutter.dart';




class RegisterPage extends StatefulWidget {

  TextEditingController emailController;
  TextEditingController passwordController;
  TextEditingController usernameController;
  final GlobalKey<FormState> formKey;


  RegisterPage({required this.emailController, required this.passwordController,
  required this.usernameController, required this.formKey,});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>{
  final bool _isLoading = false;



  

  late final StreamSubscription<AuthState>
      _authSubscription;

  @override
  void initState() {
    super.initState();

    bool haveNavigated = false;
    // Listen to auth state to redirect user when the user clicks on confirmation link
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null && !haveNavigated) {
        haveNavigated = true;
        /* Navigator.of(context)
            .pushReplacement(RoomsPage.route()) */ print("goto roompage!");
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    // Dispose subscription when no longer needed
    _authSubscription.cancel();
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body:  Container(
          padding: EdgeInsets.symmetric(horizontal: 44),
          //height: MediaQuery.of(context).size.height-150,
          child: Align(alignment: Alignment.center,
          child: Form(
            key: widget.formKey, // Assign the GlobalKey to the Form
            child: Column(
            
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
            
              
              TextFormField(
                controller: widget.usernameController,
                decoration: const InputDecoration(
                  label: Text('Username'),
                  enabledBorder: OutlineInputBorder(
                    borderSide:BorderSide(color: Colors.pink),
                    borderRadius: BorderRadius.all(Radius.circular(4.0))
                  ),
                ),
                
              ),
              //SizedBox(height: 15),
              TextFormField(
                controller: widget.emailController,
                decoration: const InputDecoration(
                  label: Text('Email'),
                  enabledBorder: OutlineInputBorder(
                    borderSide:BorderSide(color: Colors.pink),
                    borderRadius: BorderRadius.all(Radius.circular(4.0))
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              //SizedBox(height: 15),
              TextFormField(
                controller: widget.passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  label: Text('Password'),
                  enabledBorder: OutlineInputBorder(
                    borderSide:BorderSide(color: Colors.pink),
                    borderRadius: BorderRadius.all(Radius.circular(4.0))
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    
                    return 'Required';
                  }
                  if (val.length < 6) {
                    
                    return '6 characters minimum';
                  }
                  return null;
                },
              ),
              
              
              
            ],),
            ),)
        ),
      );
  }
  
  
}