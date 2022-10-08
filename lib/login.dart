import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'services/api.dart';
import 'widgets/Button.dart';
import 'widgets/TextFiled.dart';
import 'global.dart' as global;

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool _isInAsyncCall = false;
  dynamic mobileNo;
  var forceLogin = 'false';

  submit() async{
    if (!_loginFormKey.currentState!.validate()) {
      return;
    }else{
      _loginFormKey.currentState!.save();
      FocusScope.of(context).requestFocus(FocusNode());
      setState(() {
        _isInAsyncCall = true;
      });
      userLoginOrCheck(mobileNo,forceLogin);
    }
  }

  userLoginOrCheck(mobileNo,force) async{
    String deviceID = await global.getDeviceId();
    List response = await login(mobileNo,deviceID,force);
    if(response[0] == 200 || response[0] == 201){
      final SharedPreferences prefs = await _prefs;
      prefs.setString("mobile_no", mobileNo);
      prefs.setString("id", response[2]).then((bool success) async {
        Navigator.of(context).pushReplacementNamed('/home');
      });
    }else if(response[0] == 501){
      forceLoginPopup(context);
    }else{
      setState(() {
        _isInAsyncCall = false;
      });
      final snackBar = SnackBar(
        content: Text(response[1]),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {},
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
  checkUser() async{
    setState(() {
      _isInAsyncCall = true;
    });
    final SharedPreferences prefs = await _prefs;
    if (prefs.getString("mobile_no") != null) {
      userLoginOrCheck(prefs.getString("mobile_no"),forceLogin);
    }else{
      setState(() {
        _isInAsyncCall = false;
      });
    }
  }

  @override
  void initState() {
    checkUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: buildLoginForm(context),
          ),
        ),
        inAsyncCall: _isInAsyncCall,
        // demo of some additional parameters
        opacity: 0.5,
        blur: 0,
        progressIndicator: const CircularProgressIndicator(),
      ),
      // bottomNavigationBar: const SizedBox(
      //   height: 100.0,
      //   child: Center(
      //     child: Text('Vehicle Tracking System',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12)),
      //   ),
      // ),
    );
  }

  Widget buildLoginForm(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 120,left: 20,right: 20),
        child:Form(
          key: _loginFormKey,
          child: Column(
            children: [
              Text("Vehicle Tracking System",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
              Container(
                padding: const EdgeInsets.only(bottom: 15),
                child: Image.asset('images/logo.png',width: 150),
              ),
              const SizedBox(height: 20,),
              TextFiled(
                maxLength: 10,
                minLength:10,
                minValidateMsg:'Please enter valid mobile number.',
                keyboardType: 'number',
                labelAndHint: 'Mobile No.',
                prefixIcon: const Icon(Icons.phone_android),
                saved:(value) => mobileNo = value,
              ),
              const SizedBox(height: 10),
              Button(onPressed: submit,buttonName: 'Login',horizontal: 50.0,vertical: 18.0),
            ],
          ),
        ),
      ),
    );
  }

 forceLoginPopup(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Already Login another device.',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
            // content: Container(
            //   child: Text('Batch Name: ' + global.batchName),
            // ),
            actions: <Widget>[
              TextButton(
                onPressed: () => {Navigator.of(context).pop(false)},
                child:const Text(
                  'Skip',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () async{
                  final SharedPreferences prefs = await _prefs;
                  dynamic mobile =  prefs.getString('mobile_no') ?? mobileNo;
                  userLoginOrCheck(mobile,'true');
                },
                child: const Text(
                  'Force Login',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          );
        });
  }
}
