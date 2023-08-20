import 'package:flutter/material.dart';




import 'package:chatup/backend/images_data.dart';
import 'package:chatup/chat/components/animatied_avatar.dart';



class PicsAnBio extends StatefulWidget {
  String avatarUrl;
  TextEditingController bio = TextEditingController();
  int gender;
  DateTime dob;
  final GlobalKey<FormState> formKey;

  PicsAnBio({required this.avatarUrl,required this.bio,required this.gender,required this.dob, required this.formKey,});

  

  @override
  State<PicsAnBio> createState() => _PicsAnBioState();
}

class _PicsAnBioState extends State<PicsAnBio>{




  DateTime selectedDate = DateTime.now(); // Variable to store the selected date

  //final _formKey = GlobalKey<FormState>(); // key for form


  //final List<IconData> genderList = [Icons.female,Icons.male,Icons.transgender];

  List<DropdownMenuItem<int>> genderList = [
    DropdownMenuItem(
      value: 0,
      child: Icon(Icons.female),
      alignment: AlignmentDirectional.center,
      
    ),
    DropdownMenuItem(
      value: 1,
      child: Icon(Icons.male),
      alignment: AlignmentDirectional.center
        
    ),
    DropdownMenuItem(
      value: 2,
      child: Icon(Icons.transgender),
      alignment: AlignmentDirectional.center
        
    ),
  ];


  


  @override
  void dispose() {

    
    super.dispose();
  }
  
  @override
  void initState() {

    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: widget.formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.photo),
                      onPressed: () async {
                        widget.avatarUrl = //! this is for adding an image (we want to steal this)
                            await ImageData().saveImage(context) ?? '';
                        setState(() {});
                      },
                    ),
                    AnimatedAvatar(imageSrc: widget.avatarUrl),
                    IconButton(
                      onPressed: () async {
                        widget.avatarUrl = //! this is for adding an image (we want to steal this)
                            await ImageData().savePhoto(context) ?? '';
                        setState(() {});
                      },
                      icon: const Icon(Icons.camera_alt),
                    )
                  ],
                ),
                //const hr(),
                const Text(
                  'information',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                
                
                Container(child: genderDrop()),
                SizedBox(height: 20,),
                //! we need a gender wheel?
                
                
                TextField(
                  controller: widget.bio,
                  decoration: InputDecoration(
                  hintText: 'bio' 
                ),),
                SizedBox(height: 10,),

                Row(children: [//! the dob picker
                  Container( 
                    alignment: Alignment.center,
                    height:24, width: 90, decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(3)
                    ),
                    
                    child: Text(
                    selectedDate == null
                      ? 'No date selected'
                      : '${selectedDate.toString().split(' ')[0]}',
                    )),
                  
                  Container(height:34, width: 150, child: ElevatedButton(
                    child: Text('Select Date of birth'),
                    onPressed: () => _selectDate(context),
                  )),
                  

                ],)

  
                //*  bio: user.bio, gender: user.gender, dob: user.dob, 
                //* imageAvatar: user.imageAvatar, timeAtm: user.timeAtm, createdAt: user.createdAt);

              ],
            ), 
          ),
        ),
      ),
    
    );
    
  }

   Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Initial date to display in the calendar
      firstDate: DateTime(DateTime.now().year -150), // Start date of the calendar
      lastDate: DateTime.now(), // End date of the calendar
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        widget.dob = selectedDate; // we can probably just use dob
      });
      print(widget.dob.toIso8601String());
    }
  }
  
  

  Widget genderDrop() => Container(
    child: DropdownButton<int>(
      value: widget.gender,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (int? value) {
        // This is called when the user selects an item.
        setState(() {
          widget.gender = value!;
        });
      },
      items: genderList,
      


      
    )
  );





}




