import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:vehicle_tracking_system/pages/update_record.dart';
import 'package:vehicle_tracking_system/services/api.dart';
import 'package:vehicle_tracking_system/widgets/Button.dart';
import 'package:vehicle_tracking_system/widgets/TextFiled.dart';
import '../services/TodayList.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<FormState> _homeFormKey = GlobalKey<FormState>();
  Timer? homeTimer;
  String _timeString = '';
  List<TodayList> list = [];

  bool _isInAsyncCall = false;
  dynamic stateCode;
  dynamic rtoCode;
  dynamic vehicleNo;

  submit() async{
    if (!_homeFormKey.currentState!.validate()) {
      return;
    }else{
      _homeFormKey.currentState!.save();
      FocusScope.of(context).requestFocus(FocusNode());
      setState(() {
        _isInAsyncCall = true;
      });
      List response = await addData(stateCode,rtoCode,vehicleNo);
      if(response[0] == 200){
        final snackBar = SnackBar(
          content: const Text('Record Added Successfully.'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {},
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }else{
        final snackBar = SnackBar(
          content: const Text('Something went wrong. Please try again.'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {},
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
    _homeFormKey.currentState!.reset();
    todayList();
  }

  todayList() async{
    setState(() {
      _isInAsyncCall = true;
    });
    List<TodayList> data = [];
    List response = await getTodayList();
    if(response[0] == 200){
      for(var ff in response[1]){
        TodayList f = TodayList(ff['id'],ff['state_code'],ff['rto_code'],ff['vehicle_no'],ff['truck_no'],ff['created_at']);
        data.add(f);
      }
    }

    setState(() {
      list = data;
      _timeString = _formatDateTime(DateTime.now());
      homeTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
      _isInAsyncCall = false;
    });
  }

  @override
  void initState() {
    todayList();
    super.initState();
  }

  @override
  void dispose() {
    homeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Tracking System',style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
              onPressed:(){
                removeSecretKey().then((value) => {
                  if(value){
                    homeTimer?.cancel(),
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false)
                  }
                });
              },
              icon:const Icon(Icons.power_settings_new,color: Colors.white,),
          ),
        ],
      ),
      body: ModalProgressHUD(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(top: 20,left: 10,right: 10),
            child: buildHomeForm(context),
          ),
        ),
        inAsyncCall: _isInAsyncCall,
        // demo of some additional parameters
        opacity: 0.5,
        blur: 0,
        progressIndicator: const CircularProgressIndicator(),
      ),
    );
  }

  Widget buildHomeForm(BuildContext context){
    return Column(
      children: [
        Center(
          child: Text(_timeString,style: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 20),
        Form(
          key: _homeFormKey,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 100,
                child: TextFiled(
                  maxLength: 4,
                  minLength:4,
                  minValidateMsg:'Min 4 Char.',
                  labelAndHint: 'State Code',
                  saved:(value) => stateCode = value,
                ),
              ),

              SizedBox(
                width: 100,
                child: TextFiled(
                  maxLength: 2,
                  minLength:2,
                  minValidateMsg:'Min 3 Char.',
                  labelAndHint: 'RTO Code',
                  saved:(value) => rtoCode = value,
                ),
              ),

              SizedBox(
                width: 100,
                child: TextFiled(
                  maxLength: 4,
                  minLength:4,
                  minValidateMsg:'Min 4 Char.',
                  labelAndHint: 'Vehicle No.',
                  keyboardType: 'number',
                  saved:(value) => vehicleNo = value,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Button(onPressed: submit,buttonName: 'Submit',horizontal: 50.0,vertical: 16.0),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.only(top: 10),
          color: Colors.grey[200],
          width: MediaQuery.of(context).size.width,
          height: 50,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(" Today's List",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
            ],
          ),
        ),

        SizedBox(
          height: MediaQuery.of(context).size.height/2.1,
          child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: const Icon(Icons.fire_truck,size: 35,color: Colors.blueGrey),
                  title: Text(list[index].truckNo),
                  subtitle: Text(list[index].createdAt),
                  trailing: InkWell(
                    onTap: (){
                      homeTimer?.cancel();
                      Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateRecord(list[index].id)));
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const <Widget>[
                        Icon(Icons.edit_note,color: Colors.blue,size: 30,), // <-- Icon
                        Text("Edit",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),),
                      ],
                    ),
                  ),
                );
              }),
        ),
      ],
    );
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    setState(() {
      _timeString = formattedDateTime;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd-MM-yyyy hh:mm:ss').format(dateTime);
  }
}
