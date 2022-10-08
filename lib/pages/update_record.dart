import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:vehicle_tracking_system/pages/home.dart';
import 'package:vehicle_tracking_system/services/api.dart';
import 'package:vehicle_tracking_system/widgets/Button.dart';
import 'package:vehicle_tracking_system/widgets/TextFiled.dart';
import '../services/TodayList.dart';

class UpdateRecord extends StatefulWidget {
  final int id;
  const UpdateRecord(this.id, {Key? key}) : super(key: key);

  @override
  State<UpdateRecord> createState() => _UpdateRecordState();
}

class _UpdateRecordState extends State<UpdateRecord> {
  final GlobalKey<FormState> _homeFormKey = GlobalKey<FormState>();
  List<TodayList> list = [];
  bool _isInAsyncCall = false;
  bool loading = true;
  dynamic stateCode;
  dynamic rtoCode;
  dynamic vehicleNo;

  todayList() async{
    List<TodayList> data = [];
    List response = await getIdList(widget.id);
    if(response[0] == 200){
      for(var ff in response[1]){
        TodayList f = TodayList(ff['id'],ff['state_code'],ff['rto_code'],ff['vehicle_no'],ff['truck_no'],ff['created_at']);
        data.add(f);
      }
    }
    setState(() {
      list = data;
      loading = false;
    });
  }

  submit() async{
    if (!_homeFormKey.currentState!.validate()) {
      return;
    }else{
      _homeFormKey.currentState!.save();
      FocusScope.of(context).requestFocus(FocusNode());
      setState(() {
        _isInAsyncCall = true;
      });
      List response = await updateData(stateCode,rtoCode,vehicleNo,widget.id);
      if(response[0] == 200){
        final snackBar = SnackBar(
          content: const Text('Record Added Successfully.'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {},
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
      }else{
        final snackBar = SnackBar(
          content: const Text('Something went wrong. Please try again.'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {},
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {
          _isInAsyncCall = false;
        });
      }
    }
  }

  @override
  void initState() {
    todayList();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Record',style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: ModalProgressHUD(
        child: loading ? const Center(child: CircularProgressIndicator()):SingleChildScrollView(
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
        const SizedBox(height: 20),
        Form(
          key: _homeFormKey,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 100,
                child: TextFiled(
                  initialValue: list[0].stateCode,
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
                  initialValue: list[0].rtoCode,
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
                  initialValue: list[0].vehicleNo,
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
        Button(onPressed: submit,buttonName: 'Update',horizontal: 50.0,vertical: 16.0),
      ],
    );
  }
}
